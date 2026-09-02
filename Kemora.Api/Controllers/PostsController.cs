using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

using Microsoft.Extensions.Logging;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Community posts: create, browse, update, and delete social posts with media.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class PostsController : ControllerBase
    {
        private readonly IPostService _postService;
        private readonly IImageService _imageService;
        private readonly IBadgeAwardService _badgeAwardService;
        private readonly ILogger<PostsController> _logger;

        public PostsController(IPostService postService, IImageService imageService, IBadgeAwardService badgeAwardService, ILogger<PostsController> logger)
        {
            _postService = postService;
            _imageService = imageService;
            _badgeAwardService = badgeAwardService;
            _logger = logger;
        }

        private string? GetCurrentUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier);

        /// <summary>
        /// Create a new community post.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(PostListResponseDto), StatusCodes.Status200OK)]
        public async Task<ActionResult<PostListResponseDto>> CreatePost(
            [FromForm] string content,
            [FromForm] int? locationId,
            [FromForm] IFormFile? mediaFile)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var dto = new CreatePostDto
            {
                Content = content,
                LocationId = locationId
            };

            if (mediaFile != null && mediaFile.Length > 0)
            {
                using var stream = mediaFile.OpenReadStream();
                var imageUrl = await _imageService.UploadImageAsync(stream, mediaFile.FileName);
                if (!string.IsNullOrEmpty(imageUrl))
                {
                    dto.Media = new List<CreatePostMediaDto>
                    {
                        new CreatePostMediaDto { MediaURL = imageUrl, MediaType = "Image" }
                    };
                }
            }

            var post = await _postService.CreateAsync(userId, dto);
            // Award post achievements
            await _badgeAwardService.CheckPostAchievementsAsync(userId);
            return Ok(post);
        }

        /// <summary>
        /// Upload an image for a post and get its URL.
        /// </summary>
        [HttpPost("image")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (file == null || file.Length == 0) return BadRequest("No file provided.");

            using var stream = file.OpenReadStream();
            var imageUrl = await _imageService.UploadImageAsync(stream, file.FileName);
            
            if (string.IsNullOrEmpty(imageUrl)) return BadRequest("Failed to upload image.");

            return Ok(new { Url = imageUrl });
        }

        /// <summary>
        /// Browse all posts with pagination.
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        [ProducesResponseType(typeof(PagedResult<PostListResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<PagedResult<PostListResponseDto>>> GetPosts(
            [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            return Ok(await _postService.GetPostsAsync(GetCurrentUserId(), page, pageSize));
        }

        /// <summary>
        /// Get a single post with full details.
        /// </summary>
        [HttpGet("{id}")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(PostDetailResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<PostDetailResponseDto>> GetPost(int id)
        {
            var p = await _postService.GetPostAsync(id, GetCurrentUserId());
            if (p == null) return NotFound();
            return Ok(p);
        }

        /// <summary>
        /// Get the authenticated user's posts.
        /// </summary>
        [HttpGet("my")]
        [ProducesResponseType(typeof(PagedResult<PostListResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<PagedResult<PostListResponseDto>>> GetMyPosts(
            [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();
            return Ok(await _postService.GetMyPostsAsync(userId, page, pageSize));
        }

        /// <summary>
        /// Toggle a like/reaction on a post.
        /// </summary>
        [HttpPost("{id}/like")]
        public async Task<IActionResult> ToggleLike(int id)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (await _postService.ToggleLikeAsync(id, userId))
                return Ok();
            return NotFound();
        }

        /// <summary>
        /// Add a comment to a post.
        /// </summary>
        [HttpPost("{id}/comment")]
        public async Task<ActionResult<CommentResponseDto>> AddComment(int id, [FromBody] CreateCommentDto dto)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var comment = await _postService.AddCommentAsync(id, userId, dto);
            if (comment == null) return NotFound();
            
            _logger.LogInformation("CommentCreated: User {UserId} commented on Post {PostId}", userId, id);
            await _badgeAwardService.CheckCommentAchievementsAsync(userId);
            
            return Ok(comment);
        }

        /// <summary>
        /// Update your own post.
        /// </summary>
        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdatePost(int id, [FromBody] UpdatePostDto dto)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (await _postService.UpdatePostAsync(id, userId, dto))
                return NoContent();
            return NotFound("Post not found or unauthorized.");
        }

        /// <summary>
        /// Delete your own post.
        /// </summary>
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeletePost(int id)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            if (await _postService.DeletePostAsync(id, userId))
                return NoContent();
            return NotFound("Post not found or unauthorized.");
        }
    }
}
