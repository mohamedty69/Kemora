using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Kemora.Infrastructure.Services
{
    public class GooglePlacesSyncService : IPlacesSyncService
    {
        private readonly IUnitOfWork _uow;
        private readonly IPlacesDataService _placesDataService;
        private readonly IImageService _imageService;
        private readonly HttpClient _httpClient;
        private readonly ILogger<GooglePlacesSyncService> _logger;
        private readonly Kemora.Infrastructure.Data.ApplicationDbContext _dbContext;
        private readonly string? _apiKey;

        private static readonly string[] SyncCategories = {
            "museums", "historical places ancient sites", "beaches", "restaurants",
            "cafes coffee shops", "parks gardens", "shopping malls markets", "hotels",
            "entertainment amusement", "tourist attractions"
        };

        public GooglePlacesSyncService(
            IUnitOfWork uow,
            IPlacesDataService placesDataService,
            IImageService imageService,
            IHttpClientFactory httpClientFactory,
            ILogger<GooglePlacesSyncService> logger,
            Microsoft.Extensions.Configuration.IConfiguration configuration,
            Kemora.Infrastructure.Data.ApplicationDbContext dbContext)
        {
            _uow = uow;
            _placesDataService = placesDataService;
            _imageService = imageService;
            _httpClient = httpClientFactory.CreateClient();
            _logger = logger;
            _dbContext = dbContext;
            _apiKey = configuration["MapsPlatformDemo:ApiKey"] ?? configuration["Google:ApiKey"] ?? configuration["GoogleMaps:ApiKey"];
        }

        public async Task<SyncResultDto> SyncGovernorateAsync(int governorateId, CancellationToken ct = default)
        {
            var result = new SyncResultDto { GovernorateId = governorateId };

            var gov = await _uow.Repository<Governorate>()
                .FirstOrDefaultAsync(g => g.GovernorateID == governorateId);

            if (gov == null)
            {
                result.Errors.Add($"Governorate with ID {governorateId} not found.");
                return result;
            }

            result.GovernorateName = gov.Name;
            var allFetchedPlaces = new Dictionary<string, Domain.Models.FetchedPlaceDto>();

            // 1. Clear existing mock data first for this governorate
            var mockPlaces = (await _uow.Repository<Place>()
                .FindAsync(p => p.GovernorateID == governorateId && p.Source == "seed")).ToList();
            
            if (mockPlaces.Any())
            {
                foreach (var mp in mockPlaces)
                {
                    _uow.Repository<Place>().Remove(mp);
                }
                await _uow.CommitAsync();
                _logger.LogInformation("Deleted {Count} mock places from governorate {GovName}", mockPlaces.Count, gov.Name);
            }

            // 2. Fetch from Google
            foreach (var category in SyncCategories)
            {
                try
                {
                    var searchRes = await _placesDataService.SearchPlacesByAreaAsync($"{gov.Name}, Egypt", new[] { category }, limit: 20);
                    foreach (var p in searchRes)
                    {
                        if (!string.IsNullOrEmpty(p.ExternalId) && !allFetchedPlaces.ContainsKey(p.ExternalId))
                        {
                            allFetchedPlaces[p.ExternalId] = p;
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error searching category {Cat} in {Gov}", category, gov.Name);
                    result.Errors.Add($"Search error [{category}]: {ex.Message}");
                }
            }

            // 3. Process each place
            var placeTypes = (await _uow.Repository<PlaceType>().GetAllAsync()).ToList();
            var touristType = placeTypes.FirstOrDefault(t => t.GoogleType == "tourist_attraction");

            foreach (var fetched in allFetchedPlaces.Values)
            {
                if (ct.IsCancellationRequested) break;

                try
                {
                    var existingPlacesList = await _uow.Repository<Place>()
                        .FindAsync(p => p.GoogleDataId == fetched.ExternalId, p => p.Photos, p => p.Reviews);
                    var existingPlace = existingPlacesList.FirstOrDefault();

                    if (existingPlace != null && existingPlace.LastEnrichedAt.HasValue && existingPlace.LastEnrichedAt.Value.AddDays(30) > DateTime.UtcNow)
                    {
                        result.PlacesSkipped++;
                        continue;
                    }

                    // Get full details
                    var details = await _placesDataService.GetPlaceDetailsAsync(fetched.ExternalId!);
                    if (details == null)
                    {
                        result.Errors.Add($"Could not get details for {fetched.ExternalId}");
                        continue;
                    }

                    // Process Photos via Cloudinary
                    string? mainImageUrl = null;
                    var additionalUrls = new List<string>();

                    if (details.AllPhotoNames != null && details.AllPhotoNames.Any())
                    {
                        // To avoid long sync times and quota usage, upload max 5 photos per place
                        var photosToUpload = details.AllPhotoNames.Take(5).ToList();
                        
                        foreach (var photoName in photosToUpload)
                        {
                            var tempUrl = $"https://places.googleapis.com/v1/{photoName}/media?key={GetGoogleApiKey()}&maxWidthPx=800";
                            var permUrl = await UploadToCloudinary(tempUrl);
                            if (permUrl != null)
                            {
                                if (mainImageUrl == null) mainImageUrl = permUrl;
                                else additionalUrls.Add(permUrl);
                            }
                        }
                    }

                    bool isNew = existingPlace == null;
                    var place = existingPlace ?? new Place { GoogleDataId = fetched.ExternalId, Source = "google_v1" };

                    place.Name = details.Name ?? fetched.Name;
                    place.Address = details.Address ?? fetched.Address;
                    place.Description = details.Description ?? fetched.Description;
                    place.Latitude = (decimal)(details.Latitude != 0 ? details.Latitude : fetched.Latitude);
                    place.Longitude = (decimal)(details.Longitude != 0 ? details.Longitude : fetched.Longitude);
                    place.Rating = (decimal)(details.Rating ?? fetched.Rating ?? 0);
                    place.PriceLevel = int.TryParse(details.PriceLevel, out var pl) ? pl : 0;
                    place.Phone = details.Phone;
                    place.Website = details.Website;
                    place.GoogleMapsUrl = details.GoogleMapsUrl;
                    place.GovernorateID = governorateId;
                    // Map types intelligently instead of just tourist_attraction
                    int? mappedType = null;
                    if (fetched.Types != null)
                    {
                        var lowerTypes = fetched.Types.Select(t => t.ToLower()).ToList();
                        if (lowerTypes.Contains("museum")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "museum")?.TypeID;
                        else if (lowerTypes.Contains("restaurant") || lowerTypes.Contains("food")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "restaurant")?.TypeID;
                        else if (lowerTypes.Contains("cafe") || lowerTypes.Contains("coffee_shop")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "cafe")?.TypeID ?? placeTypes.FirstOrDefault(t => t.GoogleType == "restaurant")?.TypeID;
                        else if (lowerTypes.Contains("park") || lowerTypes.Contains("tourist_attraction")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "national_park")?.TypeID;
                        else if (lowerTypes.Contains("beach")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "beach_resort")?.TypeID;
                        else if (lowerTypes.Contains("hotel") || lowerTypes.Contains("lodging")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "hotel")?.TypeID;
                        else if (lowerTypes.Contains("church") || lowerTypes.Contains("place_of_worship")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "church")?.TypeID;
                        else if (lowerTypes.Contains("mosque")) mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "mosque")?.TypeID;
                    }
                    if (mappedType == null)
                        mappedType = placeTypes.FirstOrDefault(t => t.GoogleType == "national_park")?.TypeID;

                    place.PlaceTypeID = mappedType;
                    
                    if (details.OpeningHours != null && details.OpeningHours.Any())
                    {
                        place.OpeningHoursJSON = JsonSerializer.Serialize(details.OpeningHours);
                    }
                    if (additionalUrls.Any())
                    {
                        place.AdditionalPhotoUrlsJSON = JsonSerializer.Serialize(additionalUrls);
                    }
                    if (mainImageUrl != null)
                    {
                        place.MainImageURL = mainImageUrl;
                    }
                    
                    place.LastEnrichedAt = DateTime.UtcNow;

                    if (isNew)
                    {
                        await _uow.Repository<Place>().AddAsync(place);
                        result.PlacesAdded++;
                    }
                    else
                    {
                        _uow.Repository<Place>().Update(place);
                        result.PlacesUpdated++;
                    }

                    await _uow.CommitAsync(); // Save to get PlaceID if new

                    // Process Reviews
                    if (details.ApiReviews != null && details.ApiReviews.Any())
                    {
                        // Remove old Google reviews
                        var oldGoogleReviews = (await _uow.Repository<Review>()
                            .FindAsync(r => r.PlaceID == place.PlaceID && r.Source == "Google")).ToList();
                        
                        foreach (var oldRev in oldGoogleReviews)
                        {
                            _uow.Repository<Review>().Remove(oldRev);
                        }

                        foreach (var apiRev in details.ApiReviews)
                        {
                            await _uow.Repository<Review>().AddAsync(new Review
                            {
                                PlaceID = place.PlaceID,
                                AuthorName = apiRev.AuthorName,
                                Rating = apiRev.Rating,
                                Text = apiRev.Text,
                                Source = "Google"
                            });
                        }
                        await _uow.CommitAsync();
                    }

                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error syncing place {ExtId}", fetched.ExternalId);
                    result.Errors.Add($"Place {fetched.ExternalId}: {ex.Message}");
                }
            }

            return result;
        }

        public async Task<SyncResultDto> TestSyncPortSaidAsync(CancellationToken ct = default)
        {
            var result = new SyncResultDto();
            
            // 1. Delete all mock places across the DB to clean up Home screen
            // Use Raw SQL to cascade delete and avoid FK constraint issues on multiple dependent tables.
            try
            {
                await _dbContext.Database.ExecuteSqlRawAsync(@"
                    DECLARE @PlaceIds TABLE (PlaceID int);
                    INSERT INTO @PlaceIds SELECT PlaceID FROM Places WHERE Source IS NULL OR Source != 'google_v1';

                    DELETE FROM CommentMedia WHERE CommentId IN (SELECT CommentId FROM Comments WHERE PostId IN (SELECT PostId FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds)));
                    DELETE FROM CommentReactions WHERE CommentId IN (SELECT CommentId FROM Comments WHERE PostId IN (SELECT PostId FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds)));
                    DELETE FROM Comments WHERE PostId IN (SELECT PostId FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds));
                    DELETE FROM PostMedia WHERE PostId IN (SELECT PostId FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds));
                    DELETE FROM PostReactions WHERE PostId IN (SELECT PostId FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds));
                    DELETE FROM Posts WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds);

                    DELETE FROM TripPlaces WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM Stories WHERE LocationId IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM UserFavorites WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM Reviews WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM Photos WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM Events WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                    DELETE FROM Places WHERE PlaceID IN (SELECT PlaceID FROM @PlaceIds);
                ");
                _logger.LogInformation("Successfully deleted all mock places and their dependencies from DB globally");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to execute raw SQL deletion of mock places");
            }

            // 2. Find Port Said
            var gov = await _uow.Repository<Governorate>()
                .FirstOrDefaultAsync(g => g.Name.Contains("Port Said"));

            if (gov == null)
            {
                result.Errors.Add("Port Said governorate not found.");
                return result;
            }

            result.GovernorateId = gov.GovernorateID;
            result.GovernorateName = gov.Name;
            var allFetchedPlaces = new Dictionary<string, Domain.Models.FetchedPlaceDto>();

            // 3. Fetch up to 20 places per category
            foreach (var category in SyncCategories)
            {
                try
                {
                    var searchRes = await _placesDataService.SearchPlacesByAreaAsync($"{gov.Name}, Egypt", new[] { category }, limit: 20);
                    foreach (var p in searchRes)
                    {
                        if (!string.IsNullOrEmpty(p.ExternalId) && !allFetchedPlaces.ContainsKey(p.ExternalId))
                        {
                            allFetchedPlaces[p.ExternalId] = p;
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error searching category {Cat} in Port Said", category);
                    result.Errors.Add($"Search error [{category}]: {ex.Message}");
                }
            }

            // 4. Process each place
            var placeTypes = (await _uow.Repository<PlaceType>().GetAllAsync()).ToList();
            var touristType = placeTypes.FirstOrDefault(t => t.GoogleType == "tourist_attraction");

            foreach (var fetched in allFetchedPlaces.Values)
            {
                if (ct.IsCancellationRequested) break;

                try
                {
                    var existingPlacesList = await _uow.Repository<Place>()
                        .FindAsync(p => p.GoogleDataId == fetched.ExternalId, p => p.Photos, p => p.Reviews);
                    var existingPlace = existingPlacesList.FirstOrDefault();

                    var details = await _placesDataService.GetPlaceDetailsAsync(fetched.ExternalId!);
                    if (details == null)
                    {
                        _logger.LogWarning("Could not get details for {ExtId}, using fetched search data.", fetched.ExternalId);
                        result.Errors.Add($"Could not get details for {fetched.ExternalId}");
                        details = fetched; // Fallback to search result data
                    }

                    string? mainImageUrl = null;
                    var additionalUrls = new List<string>();

                    var allPhotos = details.AllPhotoNames != null && details.AllPhotoNames.Any() 
                                    ? details.AllPhotoNames 
                                    : fetched.AllPhotoNames;

                    if (allPhotos != null && allPhotos.Any())
                    {
                        var photosToUpload = allPhotos.Take(3).ToList();
                        foreach (var photoName in photosToUpload)
                        {
                            var permUrl = $"https://places.googleapis.com/v1/{photoName}/media?key={GetGoogleApiKey()}&maxWidthPx=800";
                            if (mainImageUrl == null) mainImageUrl = permUrl;
                            else additionalUrls.Add(permUrl);
                        }
                    }

                    bool isNew = existingPlace == null;
                    var place = existingPlace ?? new Place { GoogleDataId = fetched.ExternalId, Source = "google_v1" };

                    place.Name = details.Name ?? fetched.Name;
                    place.Address = details.Address ?? fetched.Address;
                    
                    var fallbackDesc = $"A wonderful destination located in {gov.Name}.";
                    place.Description = details.Description ?? fetched.Description ?? fallbackDesc;
                    place.Latitude = (decimal)(details.Latitude != 0 ? details.Latitude : fetched.Latitude);
                    place.Longitude = (decimal)(details.Longitude != 0 ? details.Longitude : fetched.Longitude);
                    place.Rating = (decimal)(details.Rating ?? fetched.Rating ?? 0);
                    place.PriceLevel = int.TryParse(details.PriceLevel, out var pl) ? pl : 0;
                    place.Phone = details.Phone;
                    place.Website = details.Website;
                    place.GoogleMapsUrl = details.GoogleMapsUrl;
                    place.GovernorateID = gov.GovernorateID;
                    place.PlaceTypeID = touristType?.TypeID;
                    
                    if (details.OpeningHours != null && details.OpeningHours.Any())
                    {
                        place.OpeningHoursJSON = JsonSerializer.Serialize(details.OpeningHours);
                    }
                    if (additionalUrls.Any())
                    {
                        place.AdditionalPhotoUrlsJSON = JsonSerializer.Serialize(additionalUrls);
                    }
                    if (mainImageUrl == null && !string.IsNullOrEmpty(fetched.ImageUrl))
                    {
                        mainImageUrl = fetched.ImageUrl;
                    }
                    
                    if (mainImageUrl != null)
                    {
                        place.MainImageURL = mainImageUrl;
                    }
                    
                    place.LastEnrichedAt = DateTime.UtcNow;

                    if (isNew)
                    {
                        await _uow.Repository<Place>().AddAsync(place);
                        result.PlacesAdded++;
                    }
                    else
                    {
                        _uow.Repository<Place>().Update(place);
                        result.PlacesUpdated++;
                    }

                    await _uow.CommitAsync();

                    if (details.ApiReviews != null && details.ApiReviews.Any())
                    {
                        var oldGoogleReviews = (await _uow.Repository<Review>()
                            .FindAsync(r => r.PlaceID == place.PlaceID && r.Source == "Google")).ToList();
                        
                        foreach (var oldRev in oldGoogleReviews)
                        {
                            _uow.Repository<Review>().Remove(oldRev);
                        }

                        foreach (var apiRev in details.ApiReviews)
                        {
                            await _uow.Repository<Review>().AddAsync(new Review
                            {
                                PlaceID = place.PlaceID,
                                AuthorName = apiRev.AuthorName,
                                Rating = apiRev.Rating,
                                Text = apiRev.Text,
                                Source = "Google"
                            });
                        }
                        await _uow.CommitAsync();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error syncing place {ExtId}", fetched.ExternalId);
                    result.Errors.Add($"Place {fetched.ExternalId}: {ex.Message}");
                }
            }

            return result;
        }

        private async Task<string?> UploadToCloudinary(string sourceUrl)
        {
            try
            {
                var response = await _httpClient.GetAsync(sourceUrl);
                if (!response.IsSuccessStatusCode) return null;

                using var stream = await response.Content.ReadAsStreamAsync();
                return await _imageService.UploadImageAsync(stream, $"google_place_{Guid.NewGuid()}");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to upload image from {SourceUrl}", sourceUrl);
                return null;
            }
        }

        private string GetGoogleApiKey()
        {
            return _apiKey ?? "";
        }
    }
}
