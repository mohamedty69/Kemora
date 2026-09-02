using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Public-facing place browsing and AI-powered trip planning.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class PlacesController : ControllerBase
    {
        private readonly IPlacePublicService _placeService;
        private readonly ITripPlannerService _tripPlannerService;
        private readonly IBadgeAwardService _badgeAwardService;

        public PlacesController(IPlacePublicService placeService, ITripPlannerService tripPlannerService, IBadgeAwardService badgeAwardService)
        {
            _placeService = placeService;
            _tripPlannerService = tripPlannerService;
            _badgeAwardService = badgeAwardService;
        }

        /// <summary>
        /// Browse places with optional filters. Supports search, category, and governorate filtering.
        /// </summary>
        /// <param name="governorateId">Optional governorate filter.</param>
        /// <param name="categoryId">Optional category filter.</param>
        /// <param name="search">Optional text search.</param>
        /// <param name="page">Page number (default: 1).</param>
        /// <param name="pageSize">Items per page (default: 20).</param>
        [HttpGet]
        [AllowAnonymous]
        [ResponseCache(Duration = 60, VaryByQueryKeys = new[] { "governorateId", "categoryId", "categoryName", "search", "page", "pageSize" })]
        [ProducesResponseType(typeof(PagedResult<PlacePublicDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<PagedResult<PlacePublicDto>>> GetPlaces(
            [FromQuery] int? governorateId,
            [FromQuery] int? categoryId,
            [FromQuery] string? categoryName,
            [FromQuery] string? search,
            [FromQuery] string? sortBy,
            [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            return Ok(await _placeService.GetPlacesAsync(governorateId, categoryId, categoryName, search, sortBy, page, pageSize));
        }

        /// <summary>
        /// Get detailed information about a specific place including photos, reviews, and events.
        /// </summary>
        /// <param name="id">The place ID.</param>
        [HttpGet("{id}")]
        [AllowAnonymous]
        [ResponseCache(Duration = 120)]
        [ProducesResponseType(typeof(PlaceDetailPublicDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<PlaceDetailPublicDto>> GetPlace(int id)
        {
            var place = await _placeService.GetPlaceDetailAsync(id);
            if (place == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!string.IsNullOrEmpty(userId))
            {
                await _badgeAwardService.CheckExplorerAchievementAsync(userId);
            }

            return Ok(place);
        }

        /// <summary>
        /// Generate an AI-powered trip plan based on location, budget, and preferences.
        /// </summary>
        /// <param name="request">Trip plan parameters including coordinates, duration, and preferences.</param>
        [HttpPost("trip-plan")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(TripPlanResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TripPlanResponseDto>> GenerateTripPlan([FromBody] TripPlanRequestDto request)
        {
            var result = await _tripPlannerService.GenerateTripPlanAsync(request);
            if (result == null) return BadRequest("Could not generate trip plan.");
            return Ok(result);
        }

        /// <summary>
        /// Get all governorates in Egypt.
        /// </summary>
        [HttpGet("governorates")]
        [AllowAnonymous]
        [ResponseCache(Duration = 3600)]
        public async Task<ActionResult<List<GovernorateDto>>> GetGovernorates()
        {
            return Ok(await _placeService.GetGovernoratesAsync());
        }

        /// <summary>
        /// Get the top 20 featured places across Egypt.
        /// </summary>
        [HttpGet("top")]
        [AllowAnonymous]
        [ResponseCache(Duration = 1800)]
        public async Task<ActionResult<List<PlacePublicDto>>> GetTopPlaces()
        {
            return Ok(await _placeService.GetTopPlacesAsync());
        }

        /// <summary>
        /// Request an alternative for a specific place in a trip plan.
        /// </summary>
        /// <param name="currentPlaceName">The name of the place to swap.</param>
        /// <param name="preferences">User's preferences.</param>
        [HttpGet("swap")]
        [AllowAnonymous]
        public async Task<IActionResult> SwapPlace([FromQuery] string currentPlaceName, [FromQuery] string preferences)
        {
            if (string.IsNullOrWhiteSpace(currentPlaceName))
                return BadRequest(new { message = "currentPlaceName is required." });

            var result = await _tripPlannerService.SwapPlaceAsync(currentPlaceName, preferences ?? "");
            
            // The AI returns a JSON string — parse it to return as a proper JSON object
            try
            {
                var parsed = System.Text.Json.JsonDocument.Parse(result);
                
                // If the AI returned { "newActivity": { ... } }, extract the inner object
                if (parsed.RootElement.TryGetProperty("newActivity", out var newActivity))
                {
                    return Content(newActivity.GetRawText(), "application/json");
                }
                
                // Otherwise return the full parsed result
                return Content(result, "application/json");
            }
            catch
            {
                // If parsing fails, return a fallback
                return Ok(new { place = "Alternative Place", description = result, time = "09:00" });
            }
        }
    }
}
