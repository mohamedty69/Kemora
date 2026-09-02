using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class CreateReviewDto
    {
        [Required(ErrorMessage = "Rating is required.")]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5 stars.")]
        public int Rating { get; set; }

        [Required(ErrorMessage = "Review text is required.")]
        [StringLength(2000, ErrorMessage = "Review text cannot exceed 2000 characters.")]
        public string Text { get; set; } = string.Empty;
    }

    public class ReviewResponseDto
    {
        public int ReviewID { get; set; }
        public string AuthorName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Text { get; set; } = string.Empty;
        public int PlaceID { get; set; }
        public string? Source { get; set; }
    }
}
