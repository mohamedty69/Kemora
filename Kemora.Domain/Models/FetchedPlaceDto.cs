namespace Kemora.Domain.Models
{
    /// <summary>
    /// Represents a place returned from the Google Places API.
    /// Lives in Domain so Infrastructure and API can share this model without coupling.
    /// </summary>
    public class FetchedPlaceDto
    {
        public string? ExternalId { get; set; } // fsq_id
        public string? Source { get; set; } // "foursquare" or "db"
        /// <summary>
        /// Primary key of the Place row in the local DB. Set when this DTO is
        /// materialised from a persisted Place so the AI trip plan can reference it
        /// and the Flutter app can deep-link to <c>/places/{DbPlaceId}</c>.
        /// </summary>
        public int? DbPlaceId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<string> Types { get; set; } = [];
        public List<string> Categories { get; set; } = []; 
        public double? Rating { get; set; }
        public string? PriceLevel { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public List<string>? OpeningHours { get; set; }
        public double DistanceKm { get; set; }
        public string? ImageUrl { get; set; }
        public List<string> PhotoUrls { get; set; } = [];
        /// <summary>
        /// Raw Google photo resource names (e.g. "places/{id}/photos/{ref}"), in the
        /// same order as <see cref="PhotoUrls"/>. Used to build authenticated media
        /// URLs for uploading to Cloudinary during hydration.
        /// </summary>
        public List<string> PhotoResourceNames { get; set; } = [];
        public int? Popularity { get; set; }
        public List<FetchedReviewDto> Reviews { get; set; } = [];
        
        // Added for GooglePlacesSyncService compatibility
        public List<string> AllPhotoNames { get; set; } = [];
        public string? GoogleMapsUrl { get; set; }
        public List<FetchedReviewDto> ApiReviews { get; set; } = [];
    }
}
