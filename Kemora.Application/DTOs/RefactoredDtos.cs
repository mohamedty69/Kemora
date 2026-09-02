using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System;

namespace Kemora.Application.DTOs
{
    public class GovernorateDto
    {
        public int GovernorateID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Region { get; set; } = string.Empty;
        public string? ImageURL { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
    }

    public class CategoryDto
    {
        public int CategoryID { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class PlaceTypeDto
    {
        public int TypeID { get; set; }
        public string GoogleType { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
    }

    public class PlaceAdminDto
    {
        public int PlaceID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public decimal Rating { get; set; }
        public int PriceLevel { get; set; }
        public string GovernorateName { get; set; } = string.Empty;
        public string PlaceTypeName { get; set; } = string.Empty;
    }

    public class PlacePublicDto
    {
        public int PlaceID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public decimal Rating { get; set; }
        public int PriceLevel { get; set; }
        public string PlaceTypeName { get; set; } = string.Empty;
        public string? MainImageURL { get; set; }
        public string? GovernorateName { get; set; }
        public int ReviewCount { get; set; }
    }

    public class PlaceDetailPublicDto
    {
        public int PlaceID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }
        public decimal Rating { get; set; }
        public int PriceLevel { get; set; }
        public string PlaceTypeName { get; set; } = string.Empty;
        public string? OpeningHoursJSON { get; set; }
        public string? MainImageURL { get; set; }
        public string? GoogleMapsUrl { get; set; }
        public List<string> AdditionalPhotoUrls { get; set; } = new();
        public List<PhotoResponseDto> Photos { get; set; } = new();
        public List<ReviewResponseDto> Reviews { get; set; } = new();
        public List<EventResponseDto> ActiveEvents { get; set; } = new();
    }

    public class ReactToPostDto
    {
        [Required(ErrorMessage = "Reaction type is required.")]
        [RegularExpression("^(Like|Love|Wow|Sad|Angry)$", ErrorMessage = "Invalid reaction type.")]
        public string ReactionType { get; set; } = "Like";

        [Required(ErrorMessage = "Action (add/remove) is required.")]
        [RegularExpression("^(add|remove)$", ErrorMessage = "Action must be 'add' or 'remove'.")]
        public string Action { get; set; } = "add"; // "add" or "remove"
    }

    public class ReactToCommentDto
    {
        [Required(ErrorMessage = "Reaction type is required.")]
        [RegularExpression("^(Like|Love|Wow|Sad|Angry)$", ErrorMessage = "Invalid reaction type.")]
        public string ReactionType { get; set; } = "Like";

        [Required(ErrorMessage = "Action (add/remove) is required.")]
        [RegularExpression("^(add|remove)$", ErrorMessage = "Action must be 'add' or 'remove'.")]
        public string Action { get; set; } = "add";
    }

    public class ProfileDto
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public int TotalPoints { get; set; }
    }
}
