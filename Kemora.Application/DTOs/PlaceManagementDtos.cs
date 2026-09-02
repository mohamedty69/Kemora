using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    // ── Governorate ───────────────────────────────────────────────────────────

    public class CreateGovernorateDto
    {
        [Required(ErrorMessage = "Governorate name is required.")]
        [StringLength(100, ErrorMessage = "Governorate name cannot exceed 100 characters.")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Region name is required.")]
        [StringLength(100, ErrorMessage = "Region name cannot exceed 100 characters.")]
        public string Region { get; set; } = string.Empty;
    }

    public class GovernorateResponseDto
    {
        public int GovernorateID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Region { get; set; } = string.Empty;
        public int PlaceCount { get; set; }
    }

    // ── Category ──────────────────────────────────────────────────────────────

    public class CreateCategoryDto
    {
        [Required(ErrorMessage = "Category name is required.")]
        [StringLength(100, ErrorMessage = "Category name cannot exceed 100 characters.")]
        public string Name { get; set; } = string.Empty;
    }

    public class CategoryResponseDto
    {
        public int CategoryID { get; set; }
        public string Name { get; set; } = string.Empty;
        public List<PlaceTypeResponseDto> PlaceTypes { get; set; } = [];
    }

    // ── PlaceType ─────────────────────────────────────────────────────────────

    public class CreatePlaceTypeDto
    {
        [Required(ErrorMessage = "Google Type identifier is required.")]
        [StringLength(100, ErrorMessage = "Google Type cannot exceed 100 characters.")]
        public string GoogleType { get; set; } = string.Empty;

        [Required(ErrorMessage = "Display name is required.")]
        [StringLength(100, ErrorMessage = "Display name cannot exceed 100 characters.")]
        public string DisplayName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Parent Category ID is required.")]
        public int CategoryID { get; set; }
    }

    public class PlaceTypeResponseDto
    {
        public int TypeID { get; set; }
        public string GoogleType { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
    }

    // ── Place (DB-stored) ─────────────────────────────────────────────────────

    public class CreatePlaceDto
    {
        [Required(ErrorMessage = "Place name is required.")]
        [StringLength(200, ErrorMessage = "Place name cannot exceed 200 characters.")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Description is required.")]
        public string Description { get; set; } = string.Empty;

        [Required(ErrorMessage = "Address is required.")]
        [StringLength(500, ErrorMessage = "Address cannot exceed 500 characters.")]
        public string Address { get; set; } = string.Empty;

        [Required(ErrorMessage = "Latitude is required for mapping.")]
        [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90.")]
        public decimal Latitude { get; set; }

        [Required(ErrorMessage = "Longitude is required for mapping.")]
        [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180.")]
        public decimal Longitude { get; set; }

        [Phone(ErrorMessage = "Invalid phone number format.")]
        public string? Phone { get; set; }

        [Url(ErrorMessage = "Website must be a valid URL.")]
        public string? Website { get; set; }

        [Range(0, 5, ErrorMessage = "Rating must be between 0 and 5.")]
        public decimal Rating { get; set; }

        [Range(0, 4, ErrorMessage = "Price level must be between 0 and 4.")]
        public int PriceLevel { get; set; }

        public string? OpeningHoursJSON { get; set; }

        [Url(ErrorMessage = "Main image must be a valid URL.")]
        public string? MainImageURL { get; set; }

        [Required(ErrorMessage = "Governorate ID is required.")]
        public int GovernorateID { get; set; }

        [Required(ErrorMessage = "Place Type ID is required.")]
        public int PlaceTypeID { get; set; }
    }

    public class UpdatePlaceDto
    {
        [StringLength(200)] public string? Name { get; set; }
        public string? Description { get; set; }
        [StringLength(500)] public string? Address { get; set; }
        [Range(-90, 90)] public decimal? Latitude { get; set; }
        [Range(-180, 180)] public decimal? Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        [Range(0, 5)] public decimal? Rating { get; set; }
        [Range(0, 4)] public int? PriceLevel { get; set; }
        public string? OpeningHoursJSON { get; set; }
        public string? MainImageURL { get; set; }
        public int? GovernorateID { get; set; }
        public int? PlaceTypeID { get; set; }
    }

    public class PlaceListDto
    {
        public int PlaceID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Rating { get; set; }
        public int PriceLevel { get; set; }
        public string GovernorateName { get; set; } = string.Empty;
        public string PlaceTypeName { get; set; } = string.Empty;
        public string? MainImageURL { get; set; }
    }

    public class PlaceDetailDto
    {
        public int PlaceID { get; set; }
        public string? GooglePlaceId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public decimal Rating { get; set; }
        public int PriceLevel { get; set; }
        public string? OpeningHoursJSON { get; set; }
        public string? MainImageURL { get; set; }
        public string GovernorateName { get; set; } = string.Empty;
        public string PlaceTypeName { get; set; } = string.Empty;
        public List<PhotoResponseDto> Photos { get; set; } = [];
        public List<ReviewResponseDto> Reviews { get; set; } = [];
        public List<EventResponseDto> Events { get; set; } = [];
    }
}
