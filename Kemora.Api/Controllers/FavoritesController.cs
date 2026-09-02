using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Manage user favorite places: add, remove, list, and check.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;

        public FavoritesController(IFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        /// <summary>
        /// Add a place to favorites.
        /// </summary>
        /// <param name="placeId">The place to favorite.</param>
        [HttpPost("{placeId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> AddFavorite(int placeId)
        {
            if (await _favoriteService.AddFavoriteAsync(GetUserId(), placeId))
                return Ok();
            return BadRequest();
        }

        /// <summary>
        /// Remove a place from favorites.
        /// </summary>
        [HttpDelete("{placeId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RemoveFavorite(int placeId)
        {
            if (await _favoriteService.RemoveFavoriteAsync(GetUserId(), placeId))
                return Ok();
            return BadRequest();
        }

        /// <summary>
        /// Get all favorite places for the authenticated user.
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(List<PlacePublicDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<List<PlacePublicDto>>> GetMyFavorites()
        {
            return Ok(await _favoriteService.GetMyFavoritesAsync(GetUserId()));
        }

        /// <summary>
        /// Check if a specific place is in the user's favorites.
        /// </summary>
        [HttpGet("{placeId}/check")]
        [ProducesResponseType(typeof(FavoriteCheckDto), StatusCodes.Status200OK)]
        public async Task<ActionResult<FavoriteCheckDto>> CheckFavorite(int placeId)
        {
            return Ok(await _favoriteService.CheckFavoriteAsync(GetUserId(), placeId));
        }
    }
}
