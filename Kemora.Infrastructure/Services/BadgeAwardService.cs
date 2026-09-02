using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.Extensions.Logging;

namespace Kemora.Infrastructure.Services
{
    /// <summary>
    /// Awards gamification badges automatically when specific events occur.
    /// All methods are idempotent — safe to call repeatedly without double-awarding.
    /// </summary>
    public class BadgeAwardService : IBadgeAwardService
    {
        private readonly ApplicationDbContext _context;
        private readonly INotificationPusher _notificationPusher;
        private readonly ILogger<BadgeAwardService> _logger;

        public BadgeAwardService(ApplicationDbContext context, INotificationPusher notificationPusher, ILogger<BadgeAwardService> logger)
        {
            _context = context;
            _notificationPusher = notificationPusher;
            _logger = logger;
        }

        public async Task CheckPostAchievementsAsync(string userId)
        {
            var postsCount = await _context.Posts.CountAsync(p => p.UserID == userId);
            if (postsCount >= 1) await TryAwardAsync(userId, "First Post");
            if (postsCount >= 5) await TryAwardAsync(userId, "5 Posts");
        }

        public async Task CheckCommentAchievementsAsync(string userId)
        {
            _logger.LogInformation("AchievementCheck started for Comments. UserId: {UserId}", userId);
            var commentsCount = await _context.Comments.CountAsync(c => c.UserID == userId);
            _logger.LogInformation("UserCommentCount for {UserId}: {Count}", userId, commentsCount);
            
            if (commentsCount >= 1) await TryAwardAsync(userId, "First Comment");
            if (commentsCount >= 5) await TryAwardAsync(userId, "5 Comments");
        }

        public async Task CheckExplorerAchievementAsync(string userId)
        {
            await TryAwardAsync(userId, "Explorer");
        }

        /// <summary>Awards "AI Pioneer" on the user's first saved AI trip.</summary>
        public async Task TryAwardAiPioneerAsync(string userId)
        {
            await TryAwardAsync(userId, "AI Pioneer");
        }

        /// <summary>Awards "City Hopper" when the user's saved trips span 5 or more unique governorates.</summary>
        public async Task TryAwardCityHopperAsync(string userId)
        {
            // Count distinct governorates from all places in the user's saved trips
            var distinctGovCount = await _context.TripPlaces
                .Where(tp => tp.Trip.UserID == userId)
                .Select(tp => tp.Place!.GovernorateID)
                .Where(gid => gid != null)
                .Distinct()
                .CountAsync();

            if (distinctGovCount >= 5)
            {
                await TryAwardAsync(userId, "City Hopper");
            }
        }

        // ── Helpers ────────────────────────────────────────────────────────────────

        private async Task TryAwardAsync(string userId, string badgeName)
        {
            try
            {
                var badge = await _context.Badges
                    .FirstOrDefaultAsync(b => b.Name == badgeName);

                if (badge == null) return;

                var alreadyHas = await _context.UserBadges
                    .AnyAsync(ub => ub.UserID == userId && ub.BadgeID == badge.BadgeID);

                if (!alreadyHas)
                {
                    _logger.LogInformation("AchievementUnlocked: {UserId} unlocked {BadgeName}", userId, badgeName);
                    _context.UserBadges.Add(new UserBadge
                    {
                        UserID = userId,
                        BadgeID = badge.BadgeID,
                        EarnedAt = DateTime.UtcNow
                    });
                    await _context.SaveChangesAsync();

                    // Notify user
                    await _notificationPusher.PushToUserAsync(
                        userId,
                        "Achievement Unlocked! 🏆",
                        $"{badge.IconUrl} {badge.Name}\n{badge.Description}"
                    );
                }
                else
                {
                    _logger.LogInformation("Achievement check: {UserId} already has {BadgeName}", userId, badgeName);
                }
            }
            catch
            {
                // Badge award is non-critical — never block the main request if this fails
            }
        }
    }
}
