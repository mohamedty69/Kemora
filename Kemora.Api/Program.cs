using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Kemora.Infrastructure.Services;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using Microsoft.OpenApi.Models;
using System.Text;
using System.Net.Http.Headers;
using System.Threading.RateLimiting;
using Serilog;
using dotenv.net;

DotEnv.Load();

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", Serilog.Events.LogEventLevel.Warning)
    .WriteTo.Console()
    .WriteTo.File("logs/kemora-.log", rollingInterval: RollingInterval.Day, retainedFileCountLimit: 14)
    .Enrich.FromLogContext()
    .CreateLogger();

try
{

var builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog();

// 1. Database Configuration
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.Configure<Kemora.Application.DTOs.EmailSettings>(builder.Configuration.GetSection("EmailSettings"));

// 2. Identity (User Management) Config
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Production password settings
    options.User.RequireUniqueEmail = true;
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// 3. JWT Authentication Config
var tokenKey = builder.Configuration["TokenKey"] ?? "super_secret_key_must_be_long_enough_for_security";
var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = key,
        ValidateIssuer = false,   // Set to true in production
        ValidateAudience = false  // Set to true in production
    };
});

// 4. Register Services (Dependency Injection)

// Domain / Infrastructure Repositories
builder.Services.AddScoped(typeof(Kemora.Domain.Interfaces.IRepository<>), typeof(Kemora.Infrastructure.Repositories.Repository<>));
builder.Services.AddScoped<Kemora.Domain.Interfaces.IPostRepository, Kemora.Infrastructure.Repositories.PostRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.ICommentRepository, Kemora.Infrastructure.Repositories.CommentRepository>();
builder.Services.AddMemoryCache();
builder.Services.AddScoped<Kemora.Application.Interfaces.ICacheService, Kemora.Infrastructure.Services.MemoryCacheService>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IReactionRepository, Kemora.Infrastructure.Repositories.ReactionRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IUnitOfWork, Kemora.Infrastructure.Repositories.UnitOfWork>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.ITripRepository, Kemora.Infrastructure.Repositories.TripRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IPlaceRepository, Kemora.Infrastructure.Repositories.PlaceRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IReviewRepository, Kemora.Infrastructure.Repositories.ReviewRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IPhotoRepository, Kemora.Infrastructure.Repositories.PhotoRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IEventRepository, Kemora.Infrastructure.Repositories.EventRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IFavoriteRepository, Kemora.Infrastructure.Repositories.FavoriteRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IBadgeRepository, Kemora.Infrastructure.Repositories.BadgeRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.INotificationRepository, Kemora.Infrastructure.Repositories.NotificationRepository>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IUserRepository, Kemora.Infrastructure.Repositories.UserRepository>();

// Application Services
builder.Services.AddScoped<Kemora.Domain.Interfaces.ITokenService, Kemora.Infrastructure.Services.TokenService>();

builder.Services.AddScoped<Kemora.Domain.Interfaces.IPlacesDataService, Kemora.Infrastructure.Services.GooglePlacesService>();
builder.Services.AddSingleton<Kemora.Domain.Interfaces.IAiService, Kemora.Infrastructure.Services.OpenRouterAiService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IAuthService, Kemora.Infrastructure.Services.AuthService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IBadgeService, Kemora.Application.Services.BadgeService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IChatService, Kemora.Application.Services.ChatService>();
// builder.Services.AddScoped<Kemora.Domain.Interfaces.IWikipediaService, Kemora.Infrastructure.Services.WikipediaService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IEmailService, Kemora.Infrastructure.Services.SmtpEmailService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IImageService, Kemora.Infrastructure.Services.CloudinaryImageService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.ICommentService, Kemora.Application.Services.CommentService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IEventService, Kemora.Application.Services.EventService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IFavoriteService, Kemora.Application.Services.FavoriteService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.INotificationService, Kemora.Application.Services.NotificationService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IPhotoService, Kemora.Application.Services.PhotoService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IPlaceManagementService, Kemora.Application.Services.PlaceManagementService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IPlacePublicService, Kemora.Application.Services.PlacePublicService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IPostService, Kemora.Application.Services.PostService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IProfileService, Kemora.Infrastructure.Services.ProfileService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IReactionService, Kemora.Application.Services.ReactionService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IReviewService, Kemora.Application.Services.ReviewService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.ITripService, Kemora.Application.Services.TripService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.ITripPlannerService, Kemora.Application.Services.TripPlannerService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IUserManagementService, Kemora.Infrastructure.Services.UserManagementService>();
builder.Services.AddScoped<Kemora.Domain.Interfaces.IStoryRepository, Kemora.Infrastructure.Repositories.StoryRepository>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IStoryService, Kemora.Application.Services.StoryService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IBadgeAwardService, Kemora.Infrastructure.Services.BadgeAwardService>();
builder.Services.AddScoped<Kemora.Application.Interfaces.IPlacesSyncService, Kemora.Infrastructure.Services.GooglePlacesSyncService>();

// SignalR
builder.Services.AddSignalR();
builder.Services.AddScoped<Kemora.Application.Interfaces.INotificationPusher, Kemora.Api.Services.SignalRNotificationPusher>();

// Rate Limiting
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = 429;
    options.AddPolicy("fixed", context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 60,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));
    options.AddPolicy("auth", context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 10,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));
});

// Health Checks
builder.Services.AddHealthChecks()
    .AddSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")!);

// Response Caching
builder.Services.AddResponseCaching();

// AutoMapper
builder.Services.AddAutoMapper(cfg => {
    cfg.AddProfile<Kemora.Application.Mapping.MappingProfile>();
});

builder.Services.AddHttpClient("GooglePlaces", client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Named client used by PhotosController.ProxyPhoto to stream photo media from the
// Google Places API (longer timeout for image downloads).
builder.Services.AddHttpClient("GooglePlacesProxy", client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});



builder.Services.AddHttpClient("OpenRouter", client =>
{
    client.BaseAddress = new Uri("https://openrouter.ai/api/v1/");
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    client.DefaultRequestHeaders.Add("X-OpenRouter-Title", "Kemora Travel Planner");
    client.Timeout = TimeSpan.FromMinutes(3);
});

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value!.Errors.Count > 0)
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value!.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            return new BadRequestObjectResult(new
            {
                Message = "One or more validation errors occurred.",
                Errors = errors
            });
        };
    }); // We use Controllers, not Minimal APIs

builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new Asp.Versioning.ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
}).AddApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";
    options.SubstituteApiVersionInUrl = true;
});

// 5. Swagger / OpenAPI Config (With Auth Support)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Kemora Tourism API",
        Version = "v1",
        Description = "RESTful API for the Kemora tourism platform — explore Egyptian destinations, plan trips, engage with the community, and earn gamification badges.",
        Contact = new OpenApiContact
        {
            Name = "Kemora Team",
            Email = "support@kemora.app"
        },
        License = new OpenApiLicense
        {
            Name = "MIT License"
        }
    });

    // Include XML comments from API project
    var xmlFilename = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFilename);
    if (File.Exists(xmlPath)) c.IncludeXmlComments(xmlPath);

    // Enable the "Authorize" button in Swagger UI
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. \r\n\r\n Enter 'Bearer' [space] and then your token in the text input below.\r\n\r\nExample: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.SetIsOriginAllowed(_ => true) // Allows Flutter Web's random localhost ports
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

app.UseMiddleware<Kemora.Api.Middlewares.ExceptionHandlingMiddleware>();
app.UseSerilogRequestLogging();

// 6. Middleware Pipeline

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Skip HTTPS redirection in development so Flutter Web (Chrome) can call HTTP port 5299
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowFrontend");

// Serve uploaded images from wwwroot/uploads as static files
app.UseStaticFiles();

// IMPORTANT: Authentication must come BEFORE Authorization
app.UseAuthentication();
app.UseAuthorization();
app.UseResponseCaching();

app.MapControllers();
app.MapHub<Kemora.Api.Hubs.NotificationHub>("/hubs/notifications");
app.MapHealthChecks("/health");
app.UseRateLimiter();

using (var scope = app.Services.CreateScope())
{
    await RoleSeeder.SeedRolesAsync(scope.ServiceProvider);

    if (app.Environment.IsDevelopment())
    {
    }
    
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    try 
    {
        Log.Information("DATABASE STARTUP: Applying pending migrations...");
        await context.Database.MigrateAsync();

        Log.Information("DATABASE STARTUP: Ensuring base data is seeded...");
        await DataSeeder.SeedAsync(scope.ServiceProvider);

        // Execute SQL script if it exists (for migrating local data to remote)
        string scriptPath = Path.Combine(app.Environment.WebRootPath ?? "wwwroot", "db_script.sql");
        if (System.IO.File.Exists(scriptPath))
        {
            Log.Information("Found db_script.sql. Executing...");
            var script = System.IO.File.ReadAllText(scriptPath);
            var batches = System.Text.RegularExpressions.Regex.Split(script, @"^\s*GO\s*$", System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Multiline);
            foreach (var batch in batches)
            {
                if (string.IsNullOrWhiteSpace(batch)) continue;
                try {
                    context.Database.ExecuteSqlRaw(batch);
                } catch (Exception ex) {
                    Log.Error(ex, "Error executing SQL batch:\n" + (batch.Length > 100 ? batch.Substring(0, 100) : batch));
                }
            }
            System.IO.File.Delete(scriptPath);
            Log.Information("db_script.sql executed and deleted.");
        }
        
        var placeCount = await context.Places.CountAsync();
        Log.Information("DATABASE STARTUP: Ready. Current Place count: {Count}", placeCount);
    }
    catch (Exception ex)
    {
        Log.Error(ex, "DATABASE STARTUP: Error during seeding check");
    }
}

app.Run();

}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

public partial class Program { }