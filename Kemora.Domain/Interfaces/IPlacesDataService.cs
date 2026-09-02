using Kemora.Domain.Enums;
using Kemora.Domain.Models;

namespace Kemora.Domain.Interfaces
{
    public interface IPlacesDataService
    {
        /// <summary>
        /// Search places near coordinates with optional category filters.
        /// </summary>
        Task<List<FetchedPlaceDto>> SearchPlacesAsync(
            string query,
            double latitude, double longitude,
            int radiusMeters = 20000,
            int limit = 50,
            string[]? categories = null);

        /// <summary>
        /// Search places by governorate/city name (e.g. "Cairo").
        /// </summary>
        Task<List<FetchedPlaceDto>> SearchPlacesByAreaAsync(
            string nearLocation,
            string[]? categories = null,
            int limit = 20,
            int page = 1,
            double latitude = 0,
            double longitude = 0);

        /// <summary>
        /// Get detailed info for a specific place by external id.
        /// </summary>
        Task<FetchedPlaceDto?> GetPlaceDetailsAsync(string externalId);

        /// <summary>
        /// Fetch nearby places (backward-compatible).
        /// </summary>
        Task<List<FetchedPlaceDto>> FetchNearbyPlacesAsync(
            double latitude, double longitude,
            double minRadiusKm = 0, double maxRadiusKm = 20);

        /// <summary>
        /// Builds an authenticated, directly-fetchable media URL for a Google photo
        /// resource name (e.g. "places/{id}/photos/{ref}"). Used server-side as the
        /// source for Cloudinary uploads. Returns null when no valid API key is set.
        /// </summary>
        string? BuildPhotoFetchUrl(string photoResourceName, int maxWidthPx = 1600);
    }
}
