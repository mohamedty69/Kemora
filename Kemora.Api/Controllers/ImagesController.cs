using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Asp.Versioning;

namespace Kemora.Api.Controllers
{
    /// <summary>
    /// Upload images to Cloudinary cloud storage.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public class ImagesController : ControllerBase
    {
        private readonly IImageService _imageService;

        public ImagesController(IImageService imageService)
        {
            _imageService = imageService;
        }

        /// <summary>
        /// Upload an image file (Admin only). Returns the public URL of the uploaded image.
        /// </summary>
        /// <param name="file">The image file to upload (JPEG, PNG, etc.).</param>
        /// <returns>The public URL of the uploaded image.</returns>
        [HttpPost("upload")]
        [Authorize]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file provided.");

            await using var stream = file.OpenReadStream();
            var url = await _imageService.UploadImageAsync(stream, file.FileName);

            if (url == null)
                return StatusCode(StatusCodes.Status500InternalServerError, "Failed to upload image.");

            return Ok(new { Url = url });
        }
    }
}
