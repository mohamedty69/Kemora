using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;
using Kemora.Domain.Interfaces;
using Kemora.Domain.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Kemora.Infrastructure.Services
{
    public class GooglePlacesService : IPlacesDataService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<GooglePlacesService> _logger;
        private readonly string? _apiKey;

        public GooglePlacesService(IHttpClientFactory httpClientFactory, ILogger<GooglePlacesService> logger, IConfiguration configuration)
        {
            _httpClient = httpClientFactory.CreateClient("GooglePlaces");
            _logger = logger;
            // Support both potential key names and ignore placeholders
            var googleKey = configuration["Google:ApiKey"];
            var googleMapsKey = configuration["GoogleMaps:ApiKey"];
            
            _apiKey = (!string.IsNullOrEmpty(googleKey) && !googleKey.Contains("YOUR_")) ? googleKey : 
                     (!string.IsNullOrEmpty(googleMapsKey) && !googleMapsKey.Contains("YOUR_") ? googleMapsKey : null);

            if (string.IsNullOrEmpty(_apiKey))
                _logger.LogError("[GooglePlaces] API key is NOT configured! Check user secrets for 'GoogleMaps:ApiKey'.");
            else
                _logger.LogInformation("[GooglePlaces] API key loaded (length={Len}).", _apiKey.Length);
        }

        public async Task<List<FetchedPlaceDto>> SearchPlacesByAreaAsync(string nearLocation, string[]? categories = null, int limit = 20, int page = 1, double latitude = 0, double longitude = 0)
        {
            if (string.IsNullOrEmpty(_apiKey))
            {
                _logger.LogWarning("Google API Key is not configured.");
                return new List<FetchedPlaceDto>();
            }

            var categoryQuery = categories != null && categories.Length > 0 ? string.Join(" ", categories) : "tourist attractions";
            
            string queryPrefix = page switch {
                1 => "top",
                2 => "best",
                3 => "popular",
                4 => "highly rated",
                5 => "must visit",
                6 => "famous",
                _ => "top"
            };

            var textQuery = $"{queryPrefix} {categoryQuery} in {nearLocation}";

            return await ExecuteSearchAsync(textQuery, limit);
        }

        public async Task<List<FetchedPlaceDto>> SearchPlacesAsync(string query, double latitude, double longitude, int radiusMeters = 20000, int limit = 20, string[]? categories = null)
        {
            if (string.IsNullOrEmpty(_apiKey)) return new List<FetchedPlaceDto>();

            var categoryQuery = categories != null && categories.Length > 0 ? string.Join(" ", categories) + " " : "";
            var textQuery = $"{categoryQuery}{query}";
            
            var payload = new
            {
                textQuery = textQuery,
                languageCode = "en",
                maxResultCount = limit,
                locationBias = new
                {
                    circle = new
                    {
                        center = new { latitude = latitude, longitude = longitude },
                        radius = radiusMeters
                    }
                }
            };

            return await ExecuteSearchAsyncPayload(payload);
        }

        public async Task<FetchedPlaceDto?> GetPlaceDetailsAsync(string externalId)
        {
            if (string.IsNullOrEmpty(_apiKey)) return null;

            var url = $"https://places.googleapis.com/v1/places/{externalId}";
            
            var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Add("X-Goog-Api-Key", _apiKey);
            request.Headers.Add("X-Goog-FieldMask", "id,displayName,formattedAddress,location,rating,priceLevel,nationalPhoneNumber,websiteUri,photos,editorialSummary,reviews,types");

            try
            {
                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var jsonResponse = await response.Content.ReadAsStringAsync();
                var doc = JsonDocument.Parse(jsonResponse);
                
                return MapPlaceFromJson(doc.RootElement);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching Google Place details for {ExternalId}", externalId);
                return null;
            }
        }

        public async Task<List<FetchedPlaceDto>> FetchNearbyPlacesAsync(double latitude, double longitude, double minRadiusKm = 0, double maxRadiusKm = 20)
        {
            return await SearchPlacesAsync("places", latitude, longitude, (int)(maxRadiusKm * 1000));
        }

        public string? BuildPhotoFetchUrl(string photoResourceName, int maxWidthPx = 1600)
        {
            if (string.IsNullOrEmpty(_apiKey) || string.IsNullOrEmpty(photoResourceName)) return null;
            // _apiKey already excludes "YOUR_" placeholders (resolved in the constructor).
            return $"https://places.googleapis.com/v1/{photoResourceName}/media?key={_apiKey}&maxWidthPx={maxWidthPx}";
        }

        private async Task<List<FetchedPlaceDto>> ExecuteSearchAsync(string textQuery, int limit)
        {
            int fetched = 0;
            string? pageToken = null;
            var allResults = new List<FetchedPlaceDto>();

            while (fetched < limit)
            {
                int currentLimit = Math.Min(20, limit - fetched);
                
                var payload = new Dictionary<string, object>
                {
                    { "textQuery", textQuery },
                    { "languageCode", "en" },
                    { "maxResultCount", currentLimit }
                };

                if (!string.IsNullOrEmpty(pageToken))
                {
                    payload["pageToken"] = pageToken;
                }

                var (results, nextToken) = await ExecuteSearchAsyncPayloadWithToken(payload);
                allResults.AddRange(results);
                fetched += results.Count;

                if (string.IsNullOrEmpty(nextToken) || results.Count == 0)
                {
                    break;
                }
                
                pageToken = nextToken;
                if (fetched < limit) await Task.Delay(500); 
            }

            return allResults;
        }

        private async Task<List<FetchedPlaceDto>> ExecuteSearchAsyncPayload(object payload)
        {
            var (results, _) = await ExecuteSearchAsyncPayloadWithToken(payload);
            return results;
        }

        private async Task<(List<FetchedPlaceDto> Results, string? NextPageToken)> ExecuteSearchAsyncPayloadWithToken(object payload)
        {
            var url = "https://places.googleapis.com/v1/places:searchText";
            
            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Headers.Add("X-Goog-Api-Key", _apiKey);
            // Request the fields we need
            request.Headers.Add("X-Goog-FieldMask", "places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.priceLevel,places.nationalPhoneNumber,places.websiteUri,places.photos,places.editorialSummary,places.reviews,places.types,nextPageToken");
            
            request.Content = JsonContent.Create(payload);

            try
            {
                var response = await _httpClient.SendAsync(request);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorBody = await response.Content.ReadAsStringAsync();
                    _logger.LogError("Google Places API (New) Error {StatusCode}: {ErrorBody}", response.StatusCode, errorBody);
                    return (new List<FetchedPlaceDto>(), null);
                }

                var jsonResponse = await response.Content.ReadAsStringAsync();
                var doc = JsonDocument.Parse(jsonResponse);

                var results = new List<FetchedPlaceDto>();
                string? nextPageToken = null;

                if (doc.RootElement.TryGetProperty("nextPageToken", out var tokenElement))
                {
                    nextPageToken = tokenElement.GetString();
                }

                if (doc.RootElement.TryGetProperty("places", out var placesArray))
                {
                    foreach (var placeElement in placesArray.EnumerateArray())
                    {
                        var place = MapPlaceFromJson(placeElement);
                        if (place != null)
                        {
                            place.Source = "google_v1";
                            results.Add(place);
                        }
                    }
                }

                return (results, nextPageToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error executing Google Places API (New) search");
                return (new List<FetchedPlaceDto>(), null);
            }
        }



        private FetchedPlaceDto? MapPlaceFromJson(JsonElement placeElement)
        {
            var dto = new FetchedPlaceDto();

            if (placeElement.TryGetProperty("id", out var idElement)) dto.ExternalId = idElement.GetString();
            if (placeElement.TryGetProperty("displayName", out var nameElement) && nameElement.TryGetProperty("text", out var textName))
                dto.Name = textName.GetString();

            if (string.IsNullOrEmpty(dto.Name) || string.IsNullOrEmpty(dto.ExternalId)) return null;

            if (placeElement.TryGetProperty("formattedAddress", out var addressElement)) dto.Address = addressElement.GetString();
            
            if (placeElement.TryGetProperty("location", out var locationElement))
            {
                if (locationElement.TryGetProperty("latitude", out var lat)) dto.Latitude = lat.GetDouble();
                if (locationElement.TryGetProperty("longitude", out var lng)) dto.Longitude = lng.GetDouble();
            }

            if (placeElement.TryGetProperty("rating", out var ratingElement)) dto.Rating = ratingElement.GetDouble();
            
            if (placeElement.TryGetProperty("priceLevel", out var priceElement))
            {
                var priceStr = priceElement.GetString();
                dto.PriceLevel = priceStr switch
                {
                    "PRICE_LEVEL_FREE" => "0",
                    "PRICE_LEVEL_INEXPENSIVE" => "1",
                    "PRICE_LEVEL_MODERATE" => "2",
                    "PRICE_LEVEL_EXPENSIVE" => "3",
                    "PRICE_LEVEL_VERY_EXPENSIVE" => "4",
                    _ => "0"
                };
            }

            if (placeElement.TryGetProperty("nationalPhoneNumber", out var phoneElement)) dto.Phone = phoneElement.GetString();
            if (placeElement.TryGetProperty("websiteUri", out var webElement)) dto.Website = webElement.GetString();

            if (placeElement.TryGetProperty("editorialSummary", out var editorialElement) && editorialElement.TryGetProperty("text", out var editorialText))
                dto.Description = editorialText.GetString();

            if (placeElement.TryGetProperty("types", out var typesArray))
            {
                foreach (var typeElement in typesArray.EnumerateArray())
                {
                    var val = typeElement.GetString();
                    if (!string.IsNullOrEmpty(val)) dto.Types.Add(val);
                }
            }

            if (placeElement.TryGetProperty("photos", out var photosArray) && photosArray.GetArrayLength() > 0)
            {
                foreach (var photoElement in photosArray.EnumerateArray())
                {
                    if (photoElement.TryGetProperty("name", out var photoName))
                    {
                        var nameStr = photoName.GetString();
                        if (string.IsNullOrEmpty(nameStr)) continue;
                        // Keep the raw resource name so hydration can build an
                        // authenticated media URL for Cloudinary uploads.
                        dto.PhotoResourceNames.Add(nameStr);
                        // Return the proxy URL instead of exposing the API key directly
                        var photoUrl = $"/api/v1/photos/proxy?name={nameStr}";
                        dto.PhotoUrls.Add(photoUrl);
                    }
                }
                if (dto.PhotoUrls.Count > 0)
                {
                    dto.ImageUrl = dto.PhotoUrls[0];
                }
            }

            // Parse reviews from Google Places API response
            if (placeElement.TryGetProperty("reviews", out var reviewsArray))
            {
                foreach (var reviewElement in reviewsArray.EnumerateArray())
                {
                    var review = new Kemora.Domain.Models.FetchedReviewDto();
                    if (reviewElement.TryGetProperty("authorAttribution", out var authorAttr) &&
                        authorAttr.TryGetProperty("displayName", out var displayName))
                    {
                        review.AuthorName = displayName.GetString();
                    }
                    if (reviewElement.TryGetProperty("rating", out var reviewRating))
                    {
                        review.Rating = reviewRating.GetInt32();
                    }
                    if (reviewElement.TryGetProperty("text", out var reviewTextObj) &&
                        reviewTextObj.TryGetProperty("text", out var reviewText))
                    {
                        review.Text = reviewText.GetString();
                    }
                    dto.Reviews.Add(review);
                }
            }

            return dto;
        }
    }
}
