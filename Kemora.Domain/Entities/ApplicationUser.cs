using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.Xml.Linq;

namespace Kemora.Domain.Entities
{
    public class ApplicationUser : IdentityUser
    {
        public string FullName { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public string? Bio { get; set; }
        public string Country { get; set; }
        public int TotalPoints { get; set; } = 0;

        public string? RefreshToken { get; set; }
        public DateTime RefreshTokenExpiryTime { get; set; }

        public string? UserPreferencesJSON { get; set; } // Stores Budget, Vibe, Pace etc.

        // Navigation Properties
        public ICollection<UserBadge> UserBadges { get; set; }
        public ICollection<UserPoint> PointHistory { get; set; }
        public ICollection<Trip> Trips { get; set; }
        public ICollection<UserFavorite> Favorites { get; set; }
        public ICollection<Post> Posts { get; set; }
        public ICollection<Comment> Comments { get; set; }
    }
}