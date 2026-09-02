using Kemora.Domain.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Kemora.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        // Locations
        public DbSet<Governorate> Governorates { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<PlaceType> PlaceTypes { get; set; }
        public DbSet<Place> Places { get; set; }
        public DbSet<Photo> Photos { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Event> Events { get; set; }

        // Social
        public DbSet<Post> Posts { get; set; }
        public DbSet<PostMedia> PostMedia { get; set; }
        public DbSet<PostReaction> PostReactions { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<CommentMedia> CommentMedia { get; set; }
        public DbSet<CommentReaction> CommentReactions { get; set; }
        public DbSet<Story> Stories { get; set; }

        // Planning
        public DbSet<Trip> Trips { get; set; }
        public DbSet<TripPlace> TripPlaces { get; set; }
        public DbSet<PrecomputedTripPlan> PrecomputedTripPlans { get; set; }

        // Gamification
        public DbSet<Badge> Badges { get; set; }
        public DbSet<UserBadge> UserBadges { get; set; }
        public DbSet<UserPoint> UserPoints { get; set; }
        public DbSet<UserFavorite> UserFavorites { get; set; }
        public DbSet<Notification> Notifications { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // 1. Composite Keys
            builder.Entity<UserBadge>().HasKey(ub => new { ub.UserID, ub.BadgeID });
            builder.Entity<UserFavorite>().HasKey(uf => new { uf.UserID, uf.PlaceID });
            builder.Entity<PostReaction>().HasKey(pr => new { pr.PostID, pr.UserID });
            builder.Entity<CommentReaction>().HasKey(cr => new { cr.CommentID, cr.UserID });

            // Indexes
            builder.Entity<PrecomputedTripPlan>()
                .HasIndex(p => p.CacheKey)
                .IsUnique();

            // 2. Decimal Precision
            builder.Entity<Place>(entity =>
            {
                entity.Property(e => e.Latitude).HasColumnType("decimal(10, 8)");
                entity.Property(e => e.Longitude).HasColumnType("decimal(11, 8)");
                entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
            });

            // 3. PREVENT CYCLES (The Fix)

            // Fix: When deleting a User, DO NOT auto-delete their comments.
            // (Because deleting a User also deletes their Posts, which deletes Comments -> Cycle)
            builder.Entity<Comment>()
                .HasOne(c => c.User)
                .WithMany(u => u.Comments)
                .HasForeignKey(c => c.UserID)
                .OnDelete(DeleteBehavior.Restrict);

            // Fix: When deleting a User, DO NOT auto-delete their Likes.
            builder.Entity<PostReaction>()
                .HasOne(pr => pr.User)
                .WithMany()
                .HasForeignKey(pr => pr.UserID)
                .OnDelete(DeleteBehavior.Restrict);

            // Fix: When deleting a User, DO NOT auto-delete their Comment Likes.
            builder.Entity<CommentReaction>()
                .HasOne(cr => cr.User)
                .WithMany()
                .HasForeignKey(cr => cr.UserID)
                .OnDelete(DeleteBehavior.Restrict);

            // Fix: When deleting a Place, do not delete the Trip history.
            builder.Entity<TripPlace>()
                .HasOne(tp => tp.Place)
                .WithMany()
                .OnDelete(DeleteBehavior.Restrict);

            // Optional: Explicitly allow Post -> Media cascade
            builder.Entity<Post>()
                .HasMany(p => p.Media)
                .WithOne(m => m.Post)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
