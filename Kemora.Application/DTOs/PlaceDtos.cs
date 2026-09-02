using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Kemora.Domain.Enums;
using Kemora.Domain.Models;

namespace Kemora.Application.DTOs
{
    // ── Request DTOs ──────────────────────────────────────────────────────────

    public class NearbyPlacesRequestDto
    {
        /// <summary>Centre latitude of the search area.</summary>
        [Required]
        [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90.")]
        public double Latitude { get; set; }

        /// <summary>Centre longitude of the search area.</summary>
        [Required]
        [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180.")]
        public double Longitude { get; set; }

        /// <summary>Minimum search radius in kilometres (default 4 km).</summary>
        [Range(0, 50, ErrorMessage = "MinRadiusKm must be between 0 and 50.")]
        public double MinRadiusKm { get; set; } = 4;

        /// <summary>Maximum search radius in kilometres (default 20 km).</summary>
        [Range(1, 50, ErrorMessage = "MaxRadiusKm must be between 1 and 50.")]
        public double MaxRadiusKm { get; set; } = 20;
    }

    public class TripPlanRequestDto
    {
        /// <summary>Centre latitude of the search area.</summary>
        [Required]
        [Range(-90, 90)]
        public double Latitude { get; set; }

        /// <summary>Centre longitude of the search area.</summary>
        [Required]
        [Range(-180, 180)]
        public double Longitude { get; set; }

        /// <summary>Minimum search radius in kilometres (default 0 km).</summary>
        [Range(0, 50)]
        public double MinRadiusKm { get; set; } = 0;

        /// <summary>Maximum search radius in kilometres (default 5 km for walking-friendly plans).</summary>
        [Range(1, 50)]
        public double MaxRadiusKm { get; set; } = 5;

        /// <summary>Number of days to plan the trip for (1–30).</summary>
        [Required]
        [Range(1, 30, ErrorMessage = "Duration must be between 1 and 30 days.")]
        public int DurationDays { get; set; } = 3;

        /// <summary>
        /// Daily budget tier: "Budget" (under 500 EGP), "Mid-Range" (500–1500 EGP),
        /// "Luxury" (1500+ EGP). Or pass a custom string like "2000 EGP per day".
        /// </summary>
        public string? Budget { get; set; }

        /// <summary>
        /// Governorate or area name (e.g. "Cairo", "Luxor", "Alexandria").
        /// Used in the AI prompt to contextualise the plan.
        /// </summary>
        public string? Location { get; set; }

        /// <summary>
        /// One or more tourism interests. The AI will prioritise activities
        /// matching these categories. Accepts: Leisure, CulturalHeritage,
        /// Adventure, EcoTourism, Business, MedicalWellness,
        /// ReligiousPilgrimage, Sports, Culinary.
        /// </summary>
        public List<TourismType>? TourismTypes { get; set; }

        /// <summary>Optional free-text preferences, e.g. "solo traveler", "family with kids".</summary>
        public string? Preferences { get; set; }

        /// <summary>Optional. If provided, the plan will centre around this known DB place instead of arbitrary coordinates.</summary>
        public int? CenterPlaceId { get; set; }

        /// <summary>Used to generate and retrieve cached alternative versions of a trip plan.</summary>
        public int AlternativeIndex { get; set; } = 1;
    }

    // ── Response DTOs ─────────────────────────────────────────────────────────

    public class NearbyPlacesResponseDto
    {
        public int TotalCount { get; set; }
        public List<FetchedPlaceDto> Places { get; set; } = [];
    }

    public class TripPlanResponseDto
    {
        public int TotalPlacesFound { get; set; }
        public List<FetchedPlaceDto> Places { get; set; } = [];

        /// <summary>
        /// The AI-generated trip plan as raw JSON string.
        /// Parse this on the client side for structured rendering.
        /// </summary>
        public string TripPlan { get; set; } = string.Empty;
    }
}
