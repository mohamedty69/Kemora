using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class CreateCommentDto
    {
        [Required(ErrorMessage = "Comment content is required.")]
        [StringLength(2000, ErrorMessage = "Comment content cannot exceed 2000 characters.")]
        public string Content { get; set; } = string.Empty;

        public int? ParentCommentId { get; set; }

        public List<CreateCommentMediaDto>? Media { get; set; }
    }

    public class CreateCommentMediaDto
    {
        [Required(ErrorMessage = "Media URL is required.")]
        [Url(ErrorMessage = "Media URL must be a valid URL.")]
        public string MediaURL { get; set; } = string.Empty;

        [Required(ErrorMessage = "Media type is required (Image or Video).")]
        [RegularExpression("^(Image|Video)$", ErrorMessage = "MediaType must be 'Image' or 'Video'.")]
        public string MediaType { get; set; } = "Image";
    }

    public class UpdateCommentDto
    {
        [Required, StringLength(2000)]
        public string Content { get; set; } = string.Empty;
    }

    public class CommentMediaResponseDto
    {
        public int MediaID { get; set; }
        public string MediaURL { get; set; } = string.Empty;
        public string MediaType { get; set; } = string.Empty;
    }

    public class CommentResponseDto
    {
        public int CommentID { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string AuthorId { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string? AuthorProfilePicture { get; set; }
        public int? ParentCommentId { get; set; }
        public List<CommentMediaResponseDto> Media { get; set; } = [];
        public List<CommentResponseDto> Replies { get; set; } = [];
        public int ReactionCount { get; set; }
    }
}
