using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Kemora.Domain.Entities
{
    public class Post
    {
        [Key] public int PostID { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }

        public int? LinkedTripId { get; set; }
        public Trip? LinkedTrip { get; set; }

        public int? LocationId { get; set; }
        public Place? Location { get; set; }

        public ICollection<PostMedia> Media { get; set; }
        public ICollection<PostReaction> Reactions { get; set; }
        public ICollection<Comment> Comments { get; set; }
    }

    public class Story
    {
        [Key] public int StoryID { get; set; }
        public string MediaUrl { get; set; } = string.Empty;
        public string MediaType { get; set; } = string.Empty; // "Image", "Video"
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime ExpiresAt { get; set; }
        
        public string UserID { get; set; } = string.Empty;
        public ApplicationUser User { get; set; } = null!;

        public int? LocationId { get; set; }
        public Place? Location { get; set; }
    }

    public class PostMedia
    {
        [Key] public int MediaID { get; set; }
        public string MediaURL { get; set; }
        public string MediaType { get; set; } // "Image", "Video"
        public int PostID { get; set; }
        public Post Post { get; set; }
    }

    public class PostReaction
    {
        public string ReactionType { get; set; } // "Like", "Love"
        public DateTime ReactedAt { get; set; } = DateTime.UtcNow;
        public int PostID { get; set; }
        public Post Post { get; set; }
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }
    }

    public class Comment
    {
        [Key] public int CommentID { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public int PostID { get; set; }
        public Post Post { get; set; }
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }

        public int? ParentCommentId { get; set; }
        public Comment? ParentComment { get; set; }
        public ICollection<Comment> Replies { get; set; } = new List<Comment>();

        public ICollection<CommentMedia> Media { get; set; }
        public ICollection<CommentReaction> Reactions { get; set; }
    }

    public class CommentMedia
    {
        [Key] public int MediaID { get; set; }
        public string MediaURL { get; set; }
        public string MediaType { get; set; }
        public int CommentID { get; set; }
        public Comment Comment { get; set; }
    }

    public class CommentReaction
    {
        public string ReactionType { get; set; }
        public DateTime ReactedAt { get; set; }
        public int CommentID { get; set; }
        public Comment Comment { get; set; }
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }
    }
    public class Message
    {
        [Key] public int MessageID { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime SentAt { get; set; } = DateTime.UtcNow;
        public bool IsRead { get; set; }
        public string SenderID { get; set; } = string.Empty;
        public ApplicationUser Sender { get; set; } = null!;
        public string ReceiverID { get; set; } = string.Empty;
        public ApplicationUser Receiver { get; set; } = null!;
    }
}