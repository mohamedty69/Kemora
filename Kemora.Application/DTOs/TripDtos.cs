using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class CreateTripDto
    {
        [Required(ErrorMessage = "Trip name is required.")]
        [StringLength(200, ErrorMessage = "Trip name cannot exceed 200 characters.")]
        public string Name { get; set; } = string.Empty;

        [StringLength(1000, ErrorMessage = "Description cannot exceed 1000 characters.")]
        public string Description { get; set; } = string.Empty;

        [Required(ErrorMessage = "Start date is required.")]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "End date is required.")]
        public DateTime EndDate { get; set; }
    }

    public class UpdateTripDto
    {
        [StringLength(200)] public string? Name { get; set; }
        public string? Description { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class TripListDto
    {
        public int TripID { get; set; }
        public string Name { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int PlaceCount { get; set; }
        public string Location { get; set; } = "Egypt";
    }

    public class TripDetailDto
    {
        public int TripID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Location { get; set; } = "Egypt";
        public List<TripPlaceResponseDto> Places { get; set; } = [];
    }

    public class AddTripPlaceDto
    {
        [Required(ErrorMessage = "Place ID is required.")]
        public int PlaceID { get; set; }

        [Required(ErrorMessage = "Visit date is required.")]
        public DateTime VisitDate { get; set; }

        [StringLength(500, ErrorMessage = "Notes cannot exceed 500 characters.")]
        public string? Notes { get; set; }
    }

    public class UpdateTripPlaceDto
    {
        public DateTime? VisitDate { get; set; }
        public string? Notes { get; set; }
        public bool? IsVisited { get; set; }
    }

    public class TripPlaceResponseDto
    {
        public int TripPlaceID { get; set; }
        public int PlaceID { get; set; }
        public string PlaceName { get; set; } = string.Empty;
        public DateTime VisitDate { get; set; }
        public string? Notes { get; set; }
        public bool IsVisited { get; set; }
        // Carried through so a reloaded AI trip renders the image + category badge
        // without an extra round-trip to /places/{id}.
        public string? ImageUrl { get; set; }
        public string? Category { get; set; }
        // Rating + a short description so saved-trip cards match the richness of
        // home-screen place cards (star rating, blurb) instead of a bare name.
        public double? Rating { get; set; }
        public string? Description { get; set; }
    }

    public class SaveAIPlanDto
    {
        [Required]
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<AIPlanActivityDto> Activities { get; set; } = [];
    }

    public class AIPlanActivityDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public double? Latitude { get; set; }   // Optional - AI may not provide coords
        public double? Longitude { get; set; }  // Optional - AI may not provide coords
        public string? Category { get; set; }
        public string? ImageUrl { get; set; }
        public DateTime VisitDate { get; set; }
        public string? Notes { get; set; }
        /// <summary>
        /// Database PlaceID when the activity references an existing Place (set by
        /// the AI trip planner from the curated DB list). Preferred over name-based
        /// lookups so the saved trip links to the real place and avoids stubs.
        /// </summary>
        public int? PlaceID { get; set; }
    }
}
