using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Manage comments on posts: create, list, update, and delete.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}")]
    [ApiController]
    [Authorize]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _commentService;
        private readonly IBadgeAwardService _badgeAwardService;
        private readonly ILogger<CommentsController> _logger;

        public CommentsController(ICommentService commentService, IBadgeAwardService badgeAwardService, ILogger<CommentsController> logger)
        {
            _commentService = commentService;
            _badgeAwardService = badgeAwardService;
            _logger = logger;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        /// <summary>
        /// Add a comment to a post.
        /// </summary>
        /// <param name="postId">The post to comment on.</param>
        /// <param name="dto">Comment content and optional media.</param>
        [HttpPost("posts/{postId}/comments")]
        [ProducesResponseType(typeof(CommentResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<CommentResponseDto>> CreateComment(int postId, [FromBody] CreateCommentDto dto)
        {
            var comment = await _commentService.CreateCommentAsync(postId, GetUserId(), dto);
            if (comment == null) return NotFound("Post not found.");
            
            _logger.LogInformation("CommentCreated: User {UserId} commented on Post {PostId}", GetUserId(), postId);
            
            await _badgeAwardService.CheckCommentAchievementsAsync(GetUserId());
            
            return Ok(comment);
        }

        /// <summary>
        /// Get paginated comments for a post.
        /// </summary>
        [HttpGet("posts/{postId}/comments")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(PagedResult<CommentResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<PagedResult<CommentResponseDto>>> GetComments(int postId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            return Ok(await _commentService.GetCommentsAsync(postId, page, pageSize));
        }

        /// <summary>
        /// Update your own comment.
        /// </summary>
        [HttpPut("comments/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateComment(int id, [FromBody] UpdateCommentDto dto)
        {
            if (await _commentService.UpdateCommentAsync(id, GetUserId(), dto))
                return NoContent();
            return NotFound("Comment not found or unauthorized.");
        }

        /// <summary>
        /// Delete your own comment.
        /// </summary>
        [HttpDelete("comments/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteComment(int id)
        {
            if (await _commentService.DeleteCommentAsync(id, GetUserId()))
                return NoContent();
            return NotFound("Comment not found or unauthorized.");
        }
    }
}
