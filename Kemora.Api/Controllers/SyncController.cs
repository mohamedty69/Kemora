using System.Threading;
using System.Threading.Tasks;
using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kemora.Api.Controllers
{
    [Route("api/v1/admin/sync")]
    [ApiController]
    // [Authorize(Roles = "Admin")]
    public class SyncController : ControllerBase
    {
        private readonly IPlacesSyncService _placesSyncService;

        public SyncController(IPlacesSyncService placesSyncService)
        {
            _placesSyncService = placesSyncService;
        }

        [HttpPost("places/{governorateId}")]
        public async Task<IActionResult> SyncGovernoratePlaces(int governorateId, CancellationToken ct)
        {
            var result = await _placesSyncService.SyncGovernorateAsync(governorateId, ct);
            
            if (result.Errors.Count > 0 && result.PlacesAdded == 0 && result.PlacesUpdated == 0)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpGet("test-port-said")]
        public async Task<IActionResult> TestSyncPortSaid(CancellationToken ct)
        {
            var result = await _placesSyncService.TestSyncPortSaidAsync(ct);
            return Ok(result);
        }
    }
}
