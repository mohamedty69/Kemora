using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    // ── Request ───────────────────────────────────────────────────────────────

    public class CreatePostDto
    {
        [Required(ErrorMessage = "Post content is required.")]
        [StringLength(5000, ErrorMessage = "Post content cannot exceed 5000 characters.")]
        public string Content { get; set; } = string.Empty;

        public List<CreatePostMediaDto>? Media { get; set; }

        public int? LocationId { get; set; }
    }

    public class CreatePostMediaDto
    {
        [Required(ErrorMessage = "Media URL is required.")]
        [Url(ErrorMessage = "Media URL must be a valid URL.")]
        public string MediaURL { get; set; } = string.Empty;

        [Required(ErrorMessage = "Media type is required (Image or Video).")]
        [RegularExpression("^(Image|Video)$", ErrorMessage = "MediaType must be 'Image' or 'Video'.")]
        public string MediaType { get; set; } = "Image";
    }

    public class UpdatePostDto
    {
        [Required, StringLength(5000)]
        public string Content { get; set; } = string.Empty;
    }

    // ── Response ──────────────────────────────────────────────────────────────

    public class PostMediaResponseDto
    {
        public int MediaID { get; set; }
        public string MediaURL { get; set; } = string.Empty;
        public string MediaType { get; set; } = string.Empty;
    }

    public class PostListResponseDto
    {
        public int PostID { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string AuthorId { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string? AuthorProfilePicture { get; set; }
        public List<PostMediaResponseDto> Media { get; set; } = [];
        public int ReactionCount { get; set; }
        public int CommentCount { get; set; }
        public bool IsLikedByMe { get; set; }
        public int? LocationId { get; set; }
        public string? LocationName { get; set; }
    }

    public class PostDetailResponseDto : PostListResponseDto
    {
        public List<CommentResponseDto> Comments { get; set; } = [];
    }
}
