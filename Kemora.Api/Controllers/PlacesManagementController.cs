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
    /// Admin endpoints for managing governorates, categories, place types, and places.
    /// </summary>
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/admin")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class PlacesManagementController : ControllerBase
    {
        private readonly IPlaceManagementService _service;

        public PlacesManagementController(IPlaceManagementService service)
        {
            _service = service;
        }

        // ── Governorates ─────────────────────────────────────────

        /// <summary>
        /// Create a new governorate.
        /// </summary>
        [HttpPost("governorates")]
        [ProducesResponseType(typeof(GovernorateDto), StatusCodes.Status200OK)]
        public async Task<ActionResult<GovernorateDto>> CreateGovernorate([FromBody] CreateGovernorateDto dto)
        {
            return Ok(await _service.CreateGovernorateAsync(dto));
        }

        /// <summary>
        /// Get all governorates.
        /// </summary>
        [HttpGet("governorates")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(List<GovernorateDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<List<GovernorateDto>>> GetGovernorates()
        {
            return Ok(await _service.GetGovernoratesAsync());
        }

        /// <summary>
        /// Update a governorate.
        /// </summary>
        [HttpPut("governorates/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateGovernorate(int id, [FromBody] CreateGovernorateDto dto)
        {
            if (await _service.UpdateGovernorateAsync(id, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a governorate.
        /// </summary>
        [HttpDelete("governorates/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteGovernorate(int id)
        {
            if (await _service.DeleteGovernorateAsync(id)) return NoContent();
            return NotFound();
        }

        // ── Categories ───────────────────────────────────────────

        /// <summary>
        /// Create a new category.
        /// </summary>
        [HttpPost("categories")]
        [ProducesResponseType(typeof(CategoryDto), StatusCodes.Status200OK)]
        public async Task<ActionResult<CategoryDto>> CreateCategory([FromBody] CreateCategoryDto dto)
        {
            return Ok(await _service.CreateCategoryAsync(dto));
        }

        /// <summary>
        /// Get all categories.
        /// </summary>
        [HttpGet("categories")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(List<CategoryDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<List<CategoryDto>>> GetCategories()
        {
            return Ok(await _service.GetCategoriesAsync());
        }

        /// <summary>
        /// Update a category.
        /// </summary>
        [HttpPut("categories/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] CreateCategoryDto dto)
        {
            if (await _service.UpdateCategoryAsync(id, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a category.
        /// </summary>
        [HttpDelete("categories/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            if (await _service.DeleteCategoryAsync(id)) return NoContent();
            return NotFound();
        }

        // ── Place Types ──────────────────────────────────────────

        /// <summary>
        /// Create a new place type.
        /// </summary>
        [HttpPost("placetypes")]
        [ProducesResponseType(typeof(PlaceTypeDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<PlaceTypeDto>> CreatePlaceType([FromBody] CreatePlaceTypeDto dto)
        {
            var res = await _service.CreatePlaceTypeAsync(dto);
            if (res == null) return BadRequest();
            return Ok(res);
        }

        /// <summary>
        /// Get all place types.
        /// </summary>
        [HttpGet("placetypes")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(List<PlaceTypeDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<List<PlaceTypeDto>>> GetPlaceTypes()
        {
            return Ok(await _service.GetPlaceTypesAsync());
        }

        /// <summary>
        /// Update a place type.
        /// </summary>
        [HttpPut("placetypes/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdatePlaceType(int id, [FromBody] CreatePlaceTypeDto dto)
        {
            if (await _service.UpdatePlaceTypeAsync(id, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a place type.
        /// </summary>
        [HttpDelete("placetypes/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeletePlaceType(int id)
        {
            if (await _service.DeletePlaceTypeAsync(id)) return NoContent();
            return NotFound();
        }

        // ── Places ───────────────────────────────────────────────

        /// <summary>
        /// Create a new place.
        /// </summary>
        [HttpPost("places")]
        [ProducesResponseType(typeof(PlaceAdminDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<PlaceAdminDto>> CreatePlace([FromBody] CreatePlaceDto dto)
        {
            var res = await _service.CreatePlaceAsync(dto);
            if (res == null) return BadRequest("Invalid category or governorate.");
            return Ok(res);
        }

        /// <summary>
        /// Update a place.
        /// </summary>
        [HttpPut("places/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdatePlace(int id, [FromBody] UpdatePlaceDto dto)
        {
            if (await _service.UpdatePlaceAsync(id, dto)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Delete a place.
        /// </summary>
        [HttpDelete("places/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeletePlace(int id)
        {
            if (await _service.DeletePlaceAsync(id)) return NoContent();
            return NotFound();
        }

        /// <summary>
        /// Upload a picture for a place.
        /// </summary>
        [HttpPost("places/{id}/image")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UploadPlacePicture(int id, Microsoft.AspNetCore.Http.IFormFile file)
        {
            if (file == null || file.Length == 0) return BadRequest("No file provided.");
            
            using var stream = file.OpenReadStream();
            var (succeeded, error, url) = await _service.UploadPlacePictureAsync(id, stream, file.FileName);
            
            if (!succeeded)
            {
                if (error == "Place not found.") return NotFound(error);
                return BadRequest(error);
            }
            
            return Ok(new { Url = url });
        }
    }
}
