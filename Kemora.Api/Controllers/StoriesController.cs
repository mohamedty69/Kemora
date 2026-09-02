using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace Kemora.Api.Controllers
{
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class StoriesController : ControllerBase
    {
        private readonly IStoryService _storyService;
        private readonly IImageService _imageService;
        private readonly IBadgeAwardService _badgeAwardService;

        public StoriesController(IStoryService storyService, IImageService imageService, IBadgeAwardService badgeAwardService)
        {
            _storyService = storyService;
            _imageService = imageService;
            _badgeAwardService = badgeAwardService;
        }

        private string? GetCurrentUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier);

        [HttpPost]
        [ProducesResponseType(typeof(StoryResponseDto), StatusCodes.Status200OK)]
        public async Task<ActionResult<StoryResponseDto>> CreateStory(
            [FromForm] IFormFile mediaFile, 
            [FromForm] string mediaType,
            [FromForm] int? locationId)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (mediaFile == null || mediaFile.Length == 0) return BadRequest("No file provided.");

            using var stream = mediaFile.OpenReadStream();
            var imageUrl = await _imageService.UploadImageAsync(stream, mediaFile.FileName);
            
            if (string.IsNullOrEmpty(imageUrl)) return BadRequest("Failed to upload media.");

            var dto = new CreateStoryDto
            {
                MediaUrl = imageUrl,
                MediaType = mediaType ?? "Image",
                LocationId = locationId
            };

            var story = await _storyService.CreateAsync(userId, dto);
            return Ok(story);
        }

        [HttpGet]
        [AllowAnonymous]
        [ProducesResponseType(typeof(IEnumerable<object>), StatusCodes.Status200OK)]
        public async Task<ActionResult> GetActiveStories()
        {
            var stories = await _storyService.GetActiveStoriesAsync();
            var grouped = stories
                .GroupBy(s => new { s.AuthorId, s.AuthorName, s.AuthorProfilePicture })
                .Select(g => new
                {
                    UserId = g.Key.AuthorId,
                    UserName = g.Key.AuthorName,
                    UserProfilePicture = g.Key.AuthorProfilePicture,
                    Stories = g.ToList()
                })
                .ToList();
            return Ok(grouped);
        }

        [HttpGet("{userId}")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(IEnumerable<StoryResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<StoryResponseDto>>> GetUserStories(string userId)
        {
            var stories = await _storyService.GetStoriesByUserAsync(userId);
            return Ok(stories);
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteStory(int id)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (await _storyService.DeleteStoryAsync(id, userId))
                return NoContent();
            return NotFound("Story not found or unauthorized.");
        }
    }
}
