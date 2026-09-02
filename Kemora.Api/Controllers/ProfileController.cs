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
    /// User profile management: view/edit own profile, view public profiles.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        /// <summary>
        /// Get the authenticated user's profile.
        /// </summary>
        [HttpGet("my")]
        [ProducesResponseType(typeof(ProfileDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<ProfileDto>> GetMyProfile()
        {
            var profile = await _profileService.GetMyProfileAsync(GetUserId());
            if (profile == null) return NotFound("User not found.");
            return Ok(profile);
        }

        /// <summary>
        /// Update the authenticated user's profile.
        /// </summary>
        [HttpPut("my")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            if (await _profileService.UpdateProfileAsync(GetUserId(), dto))
                return NoContent();
            return BadRequest("Could not update profile.");
        }

        /// <summary>
        /// Get a user's public profile by user ID.
        /// </summary>
        /// <param name="id">The user's ID.</param>
        [HttpGet("{id}/public")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(PublicProfileDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<PublicProfileDto>> GetPublicProfile(string id)
        {
            var profile = await _profileService.GetPublicProfileAsync(id);
            if (profile == null) return NotFound("User not found.");
            return Ok(profile);
        }

        /// <summary>
        /// Upload a new profile picture.
        /// </summary>
        [HttpPost("image")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UploadProfilePicture(Microsoft.AspNetCore.Http.IFormFile file)
        {
            if (file == null) return BadRequest("File is required.");
            using var stream = file.OpenReadStream();
            var (succeeded, error, url) = await _profileService.UploadProfilePictureAsync(GetUserId(), stream, file.FileName);
            if (!succeeded) return BadRequest(error);
            return Ok(new { ProfilePictureUrl = url });
        }
    }
}
