using System.ComponentModel.DataAnnotations;

namespace Kemora.Application.DTOs
{
    public class CreateBadgeDto
    {
        [Required, StringLength(100)] public string Name { get; set; } = string.Empty;
        [Required, StringLength(500)] public string Description { get; set; } = string.Empty;
        [Range(0, 10000)] public int PointsReward { get; set; }
    }

    public class BadgeResponseDto
    {
        public int BadgeID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string IconUrl { get; set; } = string.Empty;
        public string Criteria { get; set; } = string.Empty;
        public int PointsReward { get; set; }
    }

    public class UserBadgeResponseDto
    {
        public int BadgeID { get; set; }
        public string BadgeName { get; set; } = string.Empty;
        public string BadgeDescription { get; set; } = string.Empty;
        public string IconUrl { get; set; } = string.Empty;
        public string Criteria { get; set; } = string.Empty;
        public int PointsReward { get; set; }
        public int? Progress { get; set; }
        public DateTime EarnedAt { get; set; }
    }

    public class PointHistoryDto
    {
        public int PointsGained { get; set; }
        public DateTime GainedAt { get; set; }
        public string? SourcePlaceName { get; set; }
    }

    public class PointsSummaryDto
    {
        public int TotalPoints { get; set; }
        public List<PointHistoryDto> History { get; set; } = [];
    }

    public class LeaderboardEntryDto
    {
        public int Rank { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public int TotalPoints { get; set; }
    }
}
