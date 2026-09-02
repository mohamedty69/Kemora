using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Kemora.Application.Services
{
    public class PlacePublicService : IPlacePublicService
    {
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;
        private readonly ICacheService _cacheService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IPlacesDataService _placesDataService;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<PlacePublicService> _logger;
        private readonly IImageService _imageService;

        public PlacePublicService(
            IPlaceRepository placeRepo, 
            IMapper mapper, 
            ICacheService cacheService, 
            IUnitOfWork unitOfWork, 
            IPlacesDataService placesDataService, 
            IServiceScopeFactory scopeFactory,
            ILogger<PlacePublicService> logger,
            IImageService imageService)
        {
            _placeRepo = placeRepo;
            _mapper = mapper;
            _cacheService = cacheService;
            _unitOfWork = unitOfWork;
            _placesDataService = placesDataService;
            _scopeFactory = scopeFactory;
            _logger = logger;
            _imageService = imageService;
        }

        public async Task<PagedResult<PlacePublicDto>> GetPlacesAsync(int? governorateId, int? categoryId, string? categoryName, string? searchQuery, string? sortBy, int page, int pageSize)
        {
            var places = await _placeRepo.GetFilteredAsync(searchQuery, governorateId, categoryId, categoryName, sortBy, page, pageSize);
            var count = await _placeRepo.GetFilteredCountAsync(searchQuery, governorateId, categoryId, categoryName);
            
            // If no places found for this page/query, or not enough to fill the page, 
            // trigger hydration to satisfy the requested page size.
            if (places.Count() < pageSize && string.IsNullOrEmpty(searchQuery))
            {
                int currentTotal = (int)count;
                int googlePage = (currentTotal / 20) + 1;
                
                _logger.LogInformation("[Hydration] DB has {Count} places for category {Category}. Filling page {Page} from API...", places.Count(), categoryName ?? "All", page);
                
                // For a better UX, we hydrate synchronously if the DB is very empty
                if (currentTotal < page * pageSize)
                {
                    if (governorateId.HasValue)
                    {
                        await HydrateGovernoratePlacesAsync(governorateId.Value, categoryName, googlePage);
                    }
                    else if (!string.IsNullOrEmpty(categoryName))
                    {
                        // Global category search: hydrate top tourist governorates
                        var defaultGovs = new[] { "Cairo", "Giza", "Luxor" };
                        foreach (var gName in defaultGovs)
                        {
                            var gov = await _unitOfWork.Repository<Governorate>().FirstOrDefaultAsync(g => g.Name == gName);
                            if (gov != null) await HydrateGovernoratePlacesAsync(gov.GovernorateID, categoryName, googlePage);
                        }
                    }
                    
                    // Re-fetch after hydration to include new results
                    places = await _placeRepo.GetFilteredAsync(searchQuery, governorateId, categoryId, categoryName, sortBy, page, pageSize);
                    count = await _placeRepo.GetFilteredCountAsync(searchQuery, governorateId, categoryId, categoryName);
                }
                else
                {
                    // Trigger background hydration for next pages
                    _ = Task.Run(async () => {
                        try 
                        {
                            using var scope = _scopeFactory.CreateScope();
                            var scopedService = scope.ServiceProvider.GetRequiredService<IPlacePublicService>();
                            var implementation = scopedService as PlacePublicService;
                            if (implementation != null)
                            {
                                await implementation.HydrateGovernoratePlacesAsync(governorateId.Value, categoryName, googlePage);
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "[BackgroundHydration] Error");
                        }
                    });
                }
            }

            await EnrichPlacesWithImagesAsync(places);
            return new PagedResult<PlacePublicDto>
            {
                Items = _mapper.Map<List<PlacePublicDto>>(places),
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<PlaceDetailPublicDto?> GetPlaceDetailAsync(int id)
        {
            var cacheKey = $"place_detail_{id}";
            var cached = _cacheService.Get<PlaceDetailPublicDto>(cacheKey);

            if (cached != null)
                return cached;

            var place = await _placeRepo.GetWithDetailsAsync(id);
            if (place == null) return null;

            await EnrichPlacesWithImagesAsync(new[] { place });

            var dto = _mapper.Map<PlaceDetailPublicDto>(place);
            var activeEvents = place.Events;
            dto.ActiveEvents = _mapper.Map<List<EventResponseDto>>(activeEvents);

            _cacheService.Set(cacheKey, dto, System.TimeSpan.FromMinutes(10));
            return dto;
        }

        public async Task<List<GovernorateDto>> GetGovernoratesAsync()
        {
            var cacheKey = "all_governorates";
            var cached = _cacheService.Get<List<GovernorateDto>>(cacheKey);
            if (cached != null) return cached;

            var governorates = await _unitOfWork.Repository<Governorate>().GetAllAsync();
            var dtos = _mapper.Map<List<GovernorateDto>>(governorates);

            _cacheService.Set(cacheKey, dtos, System.TimeSpan.FromHours(1));
            return dtos;
        }

        public async Task<List<PlacePublicDto>> GetTopPlacesAsync()
        {
            var cacheKey = "top_places";
            var cached = _cacheService.Get<List<PlacePublicDto>>(cacheKey);
            if (cached != null && cached.Any()) return cached;

            var places = await _placeRepo.GetTopPlacesAsync(20);

            // If the DB has too few places, hydrate key governorates first
            if (places.Count() < 5)
            {
                _logger.LogInformation("[TopPlaces] Only {Count} places found. Triggering hydration for key governorates...", places.Count());

                var governorateNames = new[] { "Cairo", "Alexandria", "Giza" };
                foreach (var govName in governorateNames)
                {
                    try
                    {
                        var gov = await _unitOfWork.Repository<Kemora.Domain.Entities.Governorate>()
                            .FirstOrDefaultAsync(g => g.Name == govName);
                        if (gov != null)
                        {
                            await HydrateGovernoratePlacesAsync(gov.GovernorateID, null, 1);
                        }
                        else
                        {
                            _logger.LogWarning("[TopPlaces] Governorate '{Name}' not found in DB.", govName);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "[TopPlaces] Error hydrating {GovName}", govName);
                    }
                }

                // Re-query after hydration
                places = await _placeRepo.GetTopPlacesAsync(20);
            }

            await EnrichPlacesWithImagesAsync(places);
            var dtos = _mapper.Map<List<PlacePublicDto>>(places);

            _cacheService.Set(cacheKey, dtos, System.TimeSpan.FromMinutes(30));
            return dtos;
        }

        public async Task HydrateGovernoratePlacesAsync(int governorateId, string? categoryName, int page)
        {
            try 
            {
                var governorate = await _unitOfWork.Repository<Governorate>().GetByIdAsync(governorateId);
                if (governorate == null || governorate.Latitude == 0) 
                {
                    _logger.LogWarning("[Hydration] Governorate {Id} not found or has no coordinates.", governorateId);
                    return;
                }

                _logger.LogInformation("[Hydration] Fetching places for {GovName} (Category: {Cat}, Page: {Page})", governorate.Name, categoryName ?? "Any", page);

                var categories = BuildSearchKeywords(categoryName);
                // By requesting page * 20 limit, GooglePlacesService will use nextPageToken to fetch deeper results.
                var results = await _placesDataService.SearchPlacesByAreaAsync(
                    $"{governorate.Name}, Egypt", categories, 20, page,
                    (double)governorate.Latitude, (double)governorate.Longitude);

                _logger.LogInformation("[Hydration] Places API returned {Count} results.", results.Count);

                var existingPlaces = await _placeRepo.GetFilteredAsync(null, governorateId, null, null, null, 1, 1000);
                var existingIds = existingPlaces.Select(p => p.GoogleDataId).Where(id => id != null).ToHashSet();

                var allPlaceTypes = await _unitOfWork.Repository<PlaceType>().GetAllAsync();

                // Resolve the requested category so newly-fetched places are linked to it.
                // This guarantees they're served from the DB (not Google) on subsequent
                // requests for the same category.
                int? targetCategoryId = null;
                int? fallbackPlaceTypeId = null;
                if (!string.IsNullOrEmpty(categoryName))
                {
                    var category = await _unitOfWork.Repository<Category>().FirstOrDefaultAsync(c => c.Name == categoryName);
                    if (category != null)
                    {
                        targetCategoryId = category.CategoryID;
                        fallbackPlaceTypeId = allPlaceTypes
                            .Where(pt => pt.CategoryID == category.CategoryID)
                            .Select(pt => (int?)pt.TypeID)
                            .FirstOrDefault();
                    }
                    else
                    {
                        _logger.LogWarning("[Hydration] Category '{Name}' not found in DB; saving places without a category link.", categoryName);
                    }
                }

                int newAddsCount = 0;
                
                foreach (var basicPlace in results.Where(r => !existingIds.Contains(r.ExternalId)).Take(20))
                {
                    if (string.IsNullOrEmpty(basicPlace.ExternalId)) continue;

                    var detailedPlace = await _placesDataService.GetPlaceDetailsAsync(basicPlace.ExternalId);
                    if (detailedPlace?.Reviews != null && detailedPlace.Reviews.Count > 0)
                    {
                        basicPlace.Reviews = detailedPlace.Reviews;
                    }
                    
                    if (!string.IsNullOrEmpty(basicPlace.Name))
                    {
                        // Upload the main photo to Cloudinary so the app serves images directly
                        // from Cloudinary (not via the key-dependent proxy). Falls back to the
                        // proxy URL only if the upload fails.
                        string? uploadedImageUrl = await ResolveStoredImageUrlAsync(
                            basicPlace.PhotoResourceNames.Count > 0 ? basicPlace.PhotoResourceNames[0] : null,
                            basicPlace.ImageUrl);
                        
                        int? matchedPlaceTypeId = null;
                        var placeTypesList = detailedPlace?.Types != null && detailedPlace.Types.Count > 0
                            ? detailedPlace.Types
                            : basicPlace.Types;

                        if (placeTypesList != null && placeTypesList.Count > 0)
                        {
                            foreach (var googleType in placeTypesList)
                            {
                                var matched = allPlaceTypes.FirstOrDefault(pt => string.Equals(pt.GoogleType, googleType, StringComparison.OrdinalIgnoreCase));
                                if (matched != null)
                                {
                                    // When hydrating for a specific category, only accept a
                                    // GoogleType match that belongs to that category — otherwise
                                    // the place would be saved under a different category and never
                                    // surface for the one the user requested.
                                    if (targetCategoryId == null || matched.CategoryID == targetCategoryId)
                                    {
                                        matchedPlaceTypeId = matched.TypeID;
                                        break;
                                    }
                                }
                            }
                        }

                        // No in-category GoogleType match: fall back to the requested category's
                        // type so the place is retrievable by category from the DB next time.
                        if (matchedPlaceTypeId == null && fallbackPlaceTypeId != null)
                        {
                            matchedPlaceTypeId = fallbackPlaceTypeId;
                        }

                        var newPlace = new Place
                        {
                            GoogleDataId = basicPlace.ExternalId,
                            Name = basicPlace.Name,
                            Description = basicPlace.Description,
                            Address = basicPlace.Address,
                            Latitude = (decimal)basicPlace.Latitude,
                            Longitude = (decimal)basicPlace.Longitude,
                            Rating = (decimal)(basicPlace.Rating ?? 0),
                            PriceLevel = int.TryParse(basicPlace.PriceLevel, out int pl) ? pl : 0,
                            MainImageURL = uploadedImageUrl ?? basicPlace.ImageUrl, 
                            Phone = basicPlace.Phone,
                            Website = basicPlace.Website,
                            GovernorateID = governorateId,
                            PlaceTypeID = matchedPlaceTypeId,
                            Source = basicPlace.Source,
                            LastEnrichedAt = System.DateTime.UtcNow,
                            Reviews = new List<Kemora.Domain.Entities.Review>(),
                            Photos = new List<Kemora.Domain.Entities.Photo>()
                        };
                        await _unitOfWork.Repository<Place>().AddAsync(newPlace);

                        // Save reviews from Google Places API
                        if (basicPlace.Reviews != null && basicPlace.Reviews.Count > 0)
                        {
                            foreach (var fetchedReview in basicPlace.Reviews)
                            {
                                var review = new Kemora.Domain.Entities.Review
                                {
                                    AuthorName = fetchedReview.AuthorName ?? "Anonymous",
                                    Rating = fetchedReview.Rating,
                                    Text = fetchedReview.Text ?? string.Empty
                                };
                                newPlace.Reviews.Add(review);
                            }
                            _logger.LogInformation("[Hydration] Added {Count} reviews for place '{Name}'", basicPlace.Reviews.Count, basicPlace.Name);
                        }

                        // Save additional photos beyond the main image, uploading each to Cloudinary.
                        if (basicPlace.PhotoResourceNames != null && basicPlace.PhotoResourceNames.Count > 1)
                        {
                            // Skip the first photo (already used as MainImageURL).
                            for (int i = 1; i < basicPlace.PhotoResourceNames.Count; i++)
                            {
                                var proxyFallback = i < basicPlace.PhotoUrls.Count ? basicPlace.PhotoUrls[i] : null;
                                var storedUrl = await ResolveStoredImageUrlAsync(basicPlace.PhotoResourceNames[i], proxyFallback);
                                if (string.IsNullOrEmpty(storedUrl)) continue;

                                var photo = new Kemora.Domain.Entities.Photo
                                {
                                    ImageURL = storedUrl,
                                    IsMain = false
                                };
                                newPlace.Photos.Add(photo);
                            }
                        }

                        existingIds.Add(basicPlace.ExternalId); 
                        newAddsCount++;
                    }
                }
                
                if (newAddsCount > 0)
                {
                    await _unitOfWork.CommitAsync();
                    _logger.LogInformation("[Hydration] Successfully added {Count} new places to {GovName}.", newAddsCount, governorate.Name);
                }
                else 
                {
                    _logger.LogInformation("[Hydration] No new unique places found to add.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Hydration] Error during hydration for governorate {Id}", governorateId);
            }
        }

        // Uploads a Google photo (by resource name) to Cloudinary and returns the stored
        // Cloudinary URL. Falls back to the proxy URL if no key/upload is available so the
        // image can still be served. Returns null only when there is nothing to store.
        private async Task<string?> ResolveStoredImageUrlAsync(string? photoResourceName, string? proxyFallbackUrl)
        {
            if (string.IsNullOrEmpty(photoResourceName)) return proxyFallbackUrl;
            try
            {
                var sourceUrl = _placesDataService.BuildPhotoFetchUrl(photoResourceName);
                if (!string.IsNullOrEmpty(sourceUrl))
                {
                    var cloudinaryUrl = await _imageService.UploadImageFromUrlAsync(sourceUrl);
                    if (!string.IsNullOrEmpty(cloudinaryUrl)) return cloudinaryUrl;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "[Hydration] Cloudinary upload failed for photo '{Name}'. Falling back to proxy URL.", photoResourceName);
            }
            return proxyFallbackUrl;
        }

        // Maps a DB category name to richer Google Places search keywords so hydration
        // returns relevant results (the bare category name alone is a poor text query).
        private static readonly Dictionary<string, string> _categorySearchKeywords = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Historical"] = "historical landmarks monuments",
            ["Beach"] = "beaches resorts",
            ["Cultural"] = "museums cultural sites",
            ["Adventure"] = "adventure desert safari diving",
            ["Religious"] = "mosques churches",
            ["Nature"] = "nature parks oases",
            ["Shopping"] = "markets bazaars",
            ["Food & Dining"] = "restaurants"
        };

        private static string[]? BuildSearchKeywords(string? categoryName)
        {
            if (string.IsNullOrEmpty(categoryName)) return null;
            return _categorySearchKeywords.TryGetValue(categoryName, out var keywords)
                ? new[] { keywords }
                : new[] { categoryName };
        }

        private async Task EnrichPlacesWithImagesAsync(IEnumerable<Place> places)
        {
            // With Google Places API, images and ratings are already enriched during hydration.
            // We just clear any mock IDs if they exist.
            bool hasUpdates = false;
            foreach (var place in places)
            {
                // Clear stale mock IDs from old seeding
                if (place.GoogleDataId != null && place.GoogleDataId.StartsWith("mock_"))
                {
                    place.GoogleDataId = null;
                    _unitOfWork.Repository<Place>().Update(place);
                    hasUpdates = true;
                }
            }
            if (hasUpdates)
            {
                await _unitOfWork.CommitAsync();
            }
        }
    }
}
