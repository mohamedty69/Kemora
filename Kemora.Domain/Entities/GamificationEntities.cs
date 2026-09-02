using System;
using System.ComponentModel.DataAnnotations;

namespace Kemora.Domain.Entities
{
    public class Badge
    {
        [Key] public int BadgeID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string IconUrl { get; set; } = string.Empty;
        public string Criteria { get; set; } = string.Empty;
        public int PointsReward { get; set; }
    }

    public class UserBadge
    {
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }
        public int BadgeID { get; set; }
        public Badge Badge { get; set; }
        public DateTime EarnedAt { get; set; } = DateTime.UtcNow;
    }

    public class UserPoint
    {
        [Key] public int UserPointID { get; set; }
        public int PointsGained { get; set; }
        public DateTime GainedAt { get; set; } = DateTime.UtcNow;
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }
        public int? SourcePlaceID { get; set; }
        public Place? SourcePlace { get; set; }
    }

    public class UserFavorite
    {
        public string UserID { get; set; }
        public ApplicationUser User { get; set; }
        public int PlaceID { get; set; }
        public Place Place { get; set; }
    }
}