using System;
using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class MessageDto
    {
        public int MessageID { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime SentAt { get; set; }
        public bool IsRead { get; set; }
        public string SenderID { get; set; } = string.Empty;
        public string SenderName { get; set; } = string.Empty;
        public string? SenderProfilePicture { get; set; }
        public string ReceiverID { get; set; } = string.Empty;
        public string ReceiverName { get; set; } = string.Empty;
        public string? ReceiverProfilePicture { get; set; }
    }

    public class SendMessageDto
    {
        [Required]
        public string ReceiverID { get; set; } = string.Empty;

        [Required]
        [StringLength(1000)]
        public string Content { get; set; } = string.Empty;
    }

    public class ConversationDto
    {
        public string ContactId { get; set; } = string.Empty;
        public string ContactName { get; set; } = string.Empty;
        public string? ContactProfilePicture { get; set; }
        public string LastMessage { get; set; } = string.Empty;
        public DateTime LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
    }
}
