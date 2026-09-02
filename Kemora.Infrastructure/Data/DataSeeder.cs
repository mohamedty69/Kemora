using Kemora.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Data
{
    public static class DataSeeder
    {
        public static async Task SeedAsync(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();

            await SeedGovernoratesAsync(context);
            await SeedCategoriesAsync(context);
            await SeedPlaceTypesAsync(context);
            
            await SeedUsersAsync(userManager, context);
            await SeedAdminRolesAsync(userManager);
            await SeedBadgesAsync(context);

            await SeedSocialPostsAsync(context);
            await AwardInitialBadgesAsync(context);
        }

        private static async Task SeedGovernoratesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Governorates...");
            if (await context.Governorates.AnyAsync()) {
                System.Console.WriteLine("SEED: Governorates already exist. Skipping.");
                return;
            }

            var governorates = new List<Governorate>
            {
                new() { Name = "Cairo", Region = "Greater Cairo", Latitude = 30.0444m, Longitude = 31.2357m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1782855168/h4zpnpv26okfogjscrw2.jpg" }, // Museum of Islamic Art
                new() { Name = "Giza", Region = "Greater Cairo", Latitude = 29.9792m, Longitude = 31.1342m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1783020572/jihxqmjeyh6mpgjypova.jpg" }, // Pyramids
                new() { Name = "Alexandria", Region = "Northern Coast", Latitude = 31.2001m, Longitude = 29.9187m, ImageURL = null },
                new() { Name = "Luxor", Region = "Upper Egypt", Latitude = 25.6872m, Longitude = 32.6396m, ImageURL = null },
                new() { Name = "Aswan", Region = "Upper Egypt", Latitude = 24.0889m, Longitude = 32.8998m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1782855081/dipbtzn9bnhjl8ja1qqc.jpg" }, // Philae Temple
                new() { Name = "Red Sea", Region = "Eastern Coast", Latitude = 27.2579m, Longitude = 33.8116m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1782844703/sa706u80egd2k1774bvn.jpg" }, // Mahmya Island
                new() { Name = "South Sinai", Region = "Sinai Peninsula", Latitude = 27.9158m, Longitude = 34.3299m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1782844600/ogxvefpccwddeivuog39.jpg" }, // Ras Mohamed
                new() { Name = "Matrouh", Region = "Northern Coast", Latitude = 31.3543m, Longitude = 27.2373m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1783024013/y72neyo5y6eirvypbr4j.jpg" }, // Ageeba Beach
                new() { Name = "Fayoum", Region = "Central Egypt", Latitude = 29.3090m, Longitude = 30.8418m, ImageURL = null },
                new() { Name = "Dakahlia", Region = "Nile Delta", Latitude = 31.0413m, Longitude = 31.3785m, ImageURL = null },
                new() { Name = "Sharqia", Region = "Nile Delta", Latitude = 30.6234m, Longitude = 31.6375m, ImageURL = null },
                new() { Name = "Qalyubia", Region = "Greater Cairo", Latitude = 30.3308m, Longitude = 31.2241m, ImageURL = null },
                new() { Name = "Kafr El Sheikh", Region = "Nile Delta", Latitude = 31.2137m, Longitude = 30.6872m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1782930858/rdz74envavcgnvcyuxle.jpg" }, // Museum
                new() { Name = "Gharbia", Region = "Nile Delta", Latitude = 30.7303m, Longitude = 30.9996m, ImageURL = null },
                new() { Name = "Monufia", Region = "Nile Delta", Latitude = 30.4682m, Longitude = 30.9859m, ImageURL = null },
                new() { Name = "Beheira", Region = "Nile Delta", Latitude = 31.0364m, Longitude = 30.4699m, ImageURL = null },
                new() { Name = "Beni Suef", Region = "Central Egypt", Latitude = 29.0661m, Longitude = 31.0994m, ImageURL = null },
                new() { Name = "Minya", Region = "Upper Egypt", Latitude = 28.1096m, Longitude = 30.7516m, ImageURL = null },
                new() { Name = "Asyut", Region = "Upper Egypt", Latitude = 27.1802m, Longitude = 31.1837m, ImageURL = null },
                new() { Name = "Sohag", Region = "Upper Egypt", Latitude = 26.5591m, Longitude = 31.6957m, ImageURL = null },
                new() { Name = "Qena", Region = "Upper Egypt", Latitude = 26.1551m, Longitude = 32.7160m, ImageURL = null },
                new() { Name = "Damietta", Region = "Nile Delta", Latitude = 31.4175m, Longitude = 31.8144m, ImageURL = null },
                new() { Name = "Port Said", Region = "Canal Zone", Latitude = 31.2653m, Longitude = 32.3020m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1783019765/oaybbuqv0rvffc3ejvpt.jpg" }, // Lighthouse
                new() { Name = "Suez", Region = "Canal Zone", Latitude = 29.9668m, Longitude = 32.5498m, ImageURL = null },
                new() { Name = "Ismailia", Region = "Canal Zone", Latitude = 30.5965m, Longitude = 32.2715m, ImageURL = null },
                new() { Name = "North Sinai", Region = "Sinai Peninsula", Latitude = 30.5903m, Longitude = 33.7052m, ImageURL = "https://res.cloudinary.com/dcctg0emo/image/upload/v1783019712/fodo9btlqb4hqwzjdl8l.jpg" }, // Al-Arish Beach
                new() { Name = "New Valley", Region = "Western Desert", Latitude = 25.4390m, Longitude = 30.5586m, ImageURL = null },
            };

            context.Governorates.AddRange(governorates);
            await context.SaveChangesAsync();
        }

        private static async Task SeedCategoriesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Categories...");
            if (await context.Categories.AnyAsync()) {
                System.Console.WriteLine("SEED: Categories already exist. Skipping.");
                return;
            }
            var categories = new List<Category>
            {
                new() { Name = "Historical" },
                new() { Name = "Beach" },
                new() { Name = "Cultural" },
                new() { Name = "Adventure" },
                new() { Name = "Religious" },
                new() { Name = "Nature" },
                new() { Name = "Shopping" },
                new() { Name = "Food & Dining" }
            };
            context.Categories.AddRange(categories);
            await context.SaveChangesAsync();
        }

        private static async Task SeedPlaceTypesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Seeding Place Types...");
            if (await context.PlaceTypes.AnyAsync()) {
                System.Console.WriteLine("SEED: Place Types already exist. Skipping.");
                return;
            }
            var historical = await context.Categories.FirstAsync(c => c.Name == "Historical");
            var beach = await context.Categories.FirstAsync(c => c.Name == "Beach");
            var cultural = await context.Categories.FirstAsync(c => c.Name == "Cultural");
            var adventure = await context.Categories.FirstAsync(c => c.Name == "Adventure");
            var religious = await context.Categories.FirstAsync(c => c.Name == "Religious");
            var nature = await context.Categories.FirstAsync(c => c.Name == "Nature");
            var shopping = await context.Categories.FirstAsync(c => c.Name == "Shopping");
            var food = await context.Categories.FirstAsync(c => c.Name == "Food & Dining");

            // Ensure new categories exist
            if (!await context.Categories.AnyAsync(c => c.Name == "Entertainment"))
            {
                context.Categories.Add(new Category { Name = "Entertainment" });
                await context.SaveChangesAsync();
            }
            if (!await context.Categories.AnyAsync(c => c.Name == "Accommodation"))
            {
                context.Categories.Add(new Category { Name = "Accommodation" });
                await context.SaveChangesAsync();
            }

            var entertainment = await context.Categories.FirstAsync(c => c.Name == "Entertainment");
            var accommodation = await context.Categories.FirstAsync(c => c.Name == "Accommodation");

            var types = new List<PlaceType>
            {
                new() { GoogleType = "temple", DisplayName = "Temple", CategoryID = historical.CategoryID },
                new() { GoogleType = "pyramid", DisplayName = "Pyramid", CategoryID = historical.CategoryID },
                new() { GoogleType = "museum", DisplayName = "Museum", CategoryID = cultural.CategoryID },
                new() { GoogleType = "beach_resort", DisplayName = "Beach Resort", CategoryID = beach.CategoryID },
                new() { GoogleType = "national_park", DisplayName = "National Park", CategoryID = nature.CategoryID },
                new() { GoogleType = "mosque", DisplayName = "Mosque", CategoryID = religious.CategoryID },
                new() { GoogleType = "church", DisplayName = "Church", CategoryID = religious.CategoryID },
                new() { GoogleType = "restaurant", DisplayName = "Restaurant", CategoryID = food.CategoryID },
                new() { GoogleType = "market", DisplayName = "Market/Bazaar", CategoryID = shopping.CategoryID },
                new() { GoogleType = "hotel", DisplayName = "Hotel", CategoryID = beach.CategoryID },
                new() { GoogleType = "oasis", DisplayName = "Oasis", CategoryID = nature.CategoryID },
                new() { GoogleType = "diving_spot", DisplayName = "Diving Spot", CategoryID = adventure.CategoryID },
                new() { GoogleType = "safari", DisplayName = "Desert Safari", CategoryID = adventure.CategoryID },
                new() { GoogleType = "citadel", DisplayName = "Citadel/Fort", CategoryID = historical.CategoryID },
                new() { GoogleType = "cafe", DisplayName = "Cafe", CategoryID = food.CategoryID },
                new() { GoogleType = "park", DisplayName = "Park", CategoryID = nature.CategoryID },
                new() { GoogleType = "amusement_park", DisplayName = "Amusement Park", CategoryID = entertainment.CategoryID },
                new() { GoogleType = "tourist_attraction", DisplayName = "Tourist Attraction", CategoryID = cultural.CategoryID },
                new() { GoogleType = "historical_landmark", DisplayName = "Historical Landmark", CategoryID = historical.CategoryID }
            };

            context.PlaceTypes.AddRange(types);
            await context.SaveChangesAsync();
        }

        private static async Task SeedUsersAsync(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            var users = new List<ApplicationUser>
            {
                new ApplicationUser { UserName = "john_doe", Email = "john@example.com", FullName = "John Doe", Country = "USA", ProfilePictureUrl = "https://i.pravatar.cc/150?u=john", UserPreferencesJSON = "{\"Budget\": \"Mid-Range\", \"Vibe\": \"Historical\"}" },
                new ApplicationUser { UserName = "sarah_smith", Email = "sarah@example.com", FullName = "Sarah Smith", Country = "UK", ProfilePictureUrl = "https://i.pravatar.cc/150?u=sarah", UserPreferencesJSON = "{\"Budget\": \"Luxury\", \"Vibe\": \"Relaxed\"}" },
                new ApplicationUser { UserName = "ahmed_ali", Email = "ahmed@example.com", FullName = "Ahmed Ali", Country = "Egypt", ProfilePictureUrl = "https://i.pravatar.cc/150?u=ahmed", UserPreferencesJSON = "{\"Budget\": \"Budget\", \"Vibe\": \"Adventure\"}" },
                new ApplicationUser { Id = "guest", UserName = "guest", Email = "guest@kemora.com", FullName = "Guest User", Country = "Egypt" }
            };

            foreach (var user in users)
            {
                if (await userManager.FindByNameAsync(user.UserName!) == null)
                {
                    if (user.Id == "guest") System.Console.WriteLine("SEED: Creating fallback 'guest' user...");
                    await userManager.CreateAsync(user, "Password123!");
                }
            }

            // Seed the admin developer account
            const string adminEmail = "zyadkhaled151@gmail.com";
            const string adminPassword = "123456789@Zz";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                System.Console.WriteLine("SEED: Creating admin user zyadkhaled151@gmail.com...");
                adminUser = new ApplicationUser
                {
                    UserName = "zyad_admin",
                    Email = adminEmail,
                    FullName = "Zyad Khaled",
                    Country = "Egypt",
                    EmailConfirmed = true,
                };
                await userManager.CreateAsync(adminUser, adminPassword);
            }
        }

        private static async Task SeedAdminRolesAsync(UserManager<ApplicationUser> userManager)
        {
            const string adminEmail = "zyadkhaled151@gmail.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null) return;

            var roles = await userManager.GetRolesAsync(adminUser);
            if (!roles.Contains("Admin"))
            {
                System.Console.WriteLine("SEED: Assigning Admin role to zyadkhaled151@gmail.com...");
                await userManager.AddToRoleAsync(adminUser, "Admin");
            }
        }

        private static async Task SeedPlacesAsync(ApplicationDbContext context)
        {
            System.Console.WriteLine("SEED: Checking for old external and mock Places...");

            var oldPlaces = await context.Places
                .Where(p => p.Source == "seed" || p.Source == "google")
                .ToListAsync();

            if (oldPlaces.Any())
            {
                System.Console.WriteLine($"SEED: Found {oldPlaces.Count} old places. Deleting dependencies...");
                var oldPlaceIds = oldPlaces.Select(p => p.PlaceID).ToList();

                var tripPlaces = await context.TripPlaces.Where(tp => oldPlaceIds.Contains(tp.PlaceID)).ToListAsync();
                context.TripPlaces.RemoveRange(tripPlaces);

                var posts = await context.Posts.Where(p => p.LocationId != null && oldPlaceIds.Contains(p.LocationId.Value)).ToListAsync();
                foreach(var post in posts)
                {
                    var comments = await context.Comments.Where(c => c.PostID == post.PostID).ToListAsync();
                    context.Comments.RemoveRange(comments);
                }
                context.Posts.RemoveRange(posts);

                System.Console.WriteLine("SEED: Deleting old places...");
                context.Places.RemoveRange(oldPlaces);
                await context.SaveChangesAsync();
                System.Console.WriteLine("SEED: Old places deleted successfully. New Google Places will be hydrated on demand.");
            }
            else
            {
                System.Console.WriteLine("SEED: No old places found. Google Places will be hydrated on demand.");
            }
        }

        private static async Task SeedSocialPostsAsync(ApplicationDbContext context)
        {
            if (await context.Posts.AnyAsync()) return;

            var user1 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "john_doe");
            var user2 = await context.Users.FirstOrDefaultAsync(u => u.UserName == "sarah_smith");
            if (user1 == null || user2 == null) return;

            // Attach to real places
            var pyramidPlace = await context.Places.FirstOrDefaultAsync(p => p.Name.Contains("Great Pyramid"));
            var luxorPlace   = await context.Places.FirstOrDefaultAsync(p => p.Name.Contains("Luxor Temple"));

            var post1 = new Post
            {
                Content = "Just visited the Pyramids and they were absolutely magnificent! ☀️🐫 #Egypt #Travel",
                UserID = user1.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                LocationId = pyramidPlace?.PlaceID,
                Media = new List<PostMedia> {
                    new PostMedia { MediaURL = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368", MediaType = "Image" }
                }
            };

            var post2 = new Post
            {
                Content = "I've planned out my entire itinerary for Luxor next week using Kemora's AI Planner! The temples are calling. Who has recommendations? 🏛️",
                UserID = user2.Id,
                CreatedAt = DateTime.UtcNow.AddHours(-12),
                LocationId = luxorPlace?.PlaceID,
            };

            var post3 = new Post
            {
                Content = "Siwa Oasis is completely off the beaten path but absolutely magical. The salt lake at sunset is a dream. 🌅✨ #Siwa #Egypt",
                UserID = user1.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                Media = new List<PostMedia> {
                    new PostMedia { MediaURL = "https://images.unsplash.com/photo-1616790809516-92895f11181f", MediaType = "Image" }
                }
            };

            context.Posts.AddRange(new[] { post1, post2, post3 });
            await context.SaveChangesAsync();
            
            var comment1 = new Comment
            {
                PostID = post1.PostID,
                UserID = user2.Id,
                Content = "Amazing photo! Did you take a camel ride? 🐫",
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            };

            var comment2 = new Comment
            {
                PostID = post2.PostID,
                UserID = user1.Id,
                Content = "Go to the Valley of the Kings first thing in the morning before the tour buses arrive!",
                CreatedAt = DateTime.UtcNow.AddHours(-8)
            };

            context.Comments.AddRange(comment1, comment2);
            await context.SaveChangesAsync();
        }

        private static async Task SeedBadgesAsync(ApplicationDbContext context)
        {
            // Only seed if we don't have exactly 5 badges (the exact ones we need)
            if (await context.Badges.CountAsync() == 5 && await context.Badges.AnyAsync(b => b.Name == "Explorer")) return;

            // Clear existing badges and user progress to ensure exact requested state
            context.UserBadges.RemoveRange(context.UserBadges);
            context.Badges.RemoveRange(context.Badges);
            await context.SaveChangesAsync();

            var badges = new List<Badge>
            {
                new() { Name = "First Post", Description = "Share your first post with the Kemora community.", Criteria = "First Post", PointsReward = 75, IconUrl = "📸" },
                new() { Name = "First Comment", Description = "Leave your first comment on a post.", Criteria = "First Comment", PointsReward = 50, IconUrl = "💬" },
                new() { Name = "5 Posts", Description = "Active contributor! You've made 5 posts.", Criteria = "5 Posts", PointsReward = 200, IconUrl = "🌟" },
                new() { Name = "5 Comments", Description = "Chatterbox! You've left 5 comments.", Criteria = "5 Comments", PointsReward = 150, IconUrl = "🗣️" },
                new() { Name = "Explorer", Description = "You started exploring! Viewed a place for the first time.", Criteria = "Explorer", PointsReward = 100, IconUrl = "🗺️" }
            };

            context.Badges.AddRange(badges);
            await context.SaveChangesAsync();
        }

        private static async Task AwardInitialBadgesAsync(ApplicationDbContext context)
        {
            var firstStepsBadge = await context.Badges.FirstOrDefaultAsync(b => b.Name == "First Steps");
            if (firstStepsBadge == null) return;

            var users = await context.Users.ToListAsync();
            foreach (var user in users)
            {
                var alreadyHas = await context.UserBadges.AnyAsync(ub => ub.UserID == user.Id && ub.BadgeID == firstStepsBadge.BadgeID);
                if (!alreadyHas)
                {
                    context.UserBadges.Add(new UserBadge { UserID = user.Id, BadgeID = firstStepsBadge.BadgeID, EarnedAt = DateTime.UtcNow });
                }
            }
            await context.SaveChangesAsync();
        }
        private static int religiousType_OrDefault(ApplicationDbContext context, string type)
        {
            return context.PlaceTypes.Where(pt => pt.GoogleType == type).Select(pt => pt.TypeID).FirstOrDefault();
        }
    }
}
