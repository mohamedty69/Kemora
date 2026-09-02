using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class UpdateProfileDto
    {
        [Required(ErrorMessage = "Full name is required.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Full name must be between 3 and 100 characters.")]
        public string FullName { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "Bio cannot exceed 500 characters.")]
        public string? Bio { get; set; }
    }

    public class ProfileResponseDto
    {
        public string UserId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? ProfilePictureUrl { get; set; }
        public string? Bio { get; set; }
        public string Country { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int TotalPoints { get; set; }
        public int PostCount { get; set; }
        public int TripCount { get; set; }
        public int BadgeCount { get; set; }
        public int FavoriteCount { get; set; }
    }

    public class PublicProfileDto
    {
        public string UserId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? ProfilePictureUrl { get; set; }
        public string? Bio { get; set; }
        public string Country { get; set; } = string.Empty;
        public int TotalPoints { get; set; }
        public int BadgeCount { get; set; }
        public int PostCount { get; set; }
    }
}
