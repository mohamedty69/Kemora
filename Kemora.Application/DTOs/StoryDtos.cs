using System;
using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class CreateStoryDto
    {
        [Required(ErrorMessage = "Media URL is required.")]
        [Url(ErrorMessage = "Media URL must be a valid URL.")]
        public string MediaUrl { get; set; } = string.Empty;

        [Required(ErrorMessage = "Media type is required (Image or Video).")]
        [RegularExpression("^(Image|Video)$", ErrorMessage = "MediaType must be 'Image' or 'Video'.")]
        public string MediaType { get; set; } = "Image";

        public int? LocationId { get; set; }
    }

    public class StoryResponseDto
    {
        public int StoryID { get; set; }
        public string MediaUrl { get; set; } = string.Empty;
        public string MediaType { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
        
        public string AuthorId { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string? AuthorProfilePicture { get; set; }

        public int? LocationId { get; set; }
        public string? LocationName { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
    }
}
