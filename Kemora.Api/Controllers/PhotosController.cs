using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Manage photos for places: add, list, set main, and delete.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}")]
    [ApiController]
    [Authorize]
    public class PhotosController : ControllerBase
    {
        private readonly IPhotoService _photoService;

        public PhotosController(IPhotoService photoService)
        {
            _photoService = photoService;
        }

        /// <summary>
        /// Add a photo to a place (Admin only).
        /// </summary>
        [HttpPost("places/{placeId}/photos")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(typeof(PhotoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<PhotoResponseDto>> AddPhoto(int placeId, [FromBody] CreatePhotoDto dto)
        {
            var photo = await _photoService.AddPhotoAsync(placeId, dto);
            if (photo == null) return NotFound("Place not found.");
            return Ok(photo);
        }

        /// <summary>
        /// Get all photos for a place.
        /// </summary>
        [HttpGet("places/{placeId}/photos")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(List<PhotoResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<List<PhotoResponseDto>>> GetPhotos(int placeId)
        {
            return Ok(await _photoService.GetPlacePhotosAsync(placeId));
        }

        /// <summary>
        /// Set a photo as the main photo for a place (Admin only).
        /// </summary>
        [HttpPut("places/{placeId}/photos/{photoId}/main")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> SetMainPhoto(int placeId, int photoId)
        {
            if (await _photoService.SetMainPhotoAsync(placeId, photoId)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a photo from a place (Admin only).
        /// </summary>
        [HttpDelete("places/{placeId}/photos/{photoId}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeletePhoto(int placeId, int photoId)
        {
            if (await _photoService.DeletePhotoAsync(placeId, photoId)) return NoContent();
            return NotFound();
        }
        /// <summary>
        /// Proxies a photo from Google Places API to avoid exposing the API key.
        /// Served at <c>/api/v{version}/photos/proxy</c> to match the URLs stored on
        /// places during hydration (see GooglePlacesService.BuildPhotoFetchUrl).
        /// </summary>
        [HttpGet("photos/proxy")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(FileResult), StatusCodes.Status200OK)]
        public async Task<IActionResult> ProxyPhoto(
            [FromQuery] string name, 
            [FromServices] Microsoft.Extensions.Configuration.IConfiguration config, 
            [FromServices] System.Net.Http.IHttpClientFactory httpClientFactory)
        {
            if (string.IsNullOrEmpty(name)) return BadRequest("Photo name is required.");

            // Prefer a real key, ignoring unconfigured "YOUR_..." placeholders.
            var googleKey = config["Google:ApiKey"];
            var googleMapsKey = config["GoogleMaps:ApiKey"];
            var apiKey = (!string.IsNullOrEmpty(googleKey) && !googleKey.Contains("YOUR_")) ? googleKey
                       : (!string.IsNullOrEmpty(googleMapsKey) && !googleMapsKey.Contains("YOUR_")) ? googleMapsKey
                       : null;
            if (string.IsNullOrEmpty(apiKey)) return StatusCode(500, "Google API Key is missing.");

            var url = $"https://places.googleapis.com/v1/{name}/media?key={apiKey}&maxWidthPx=800";

            var client = httpClientFactory.CreateClient("GooglePlacesProxy");
            var response = await client.GetAsync(url, System.Net.Http.HttpCompletionOption.ResponseHeadersRead);

            if (!response.IsSuccessStatusCode) return StatusCode((int)response.StatusCode, "Failed to fetch image from Google.");

            var contentType = response.Content.Headers.ContentType?.ToString() ?? "image/jpeg";
            var stream = await response.Content.ReadAsStreamAsync();

            return File(stream, contentType);
        }
    }
}
