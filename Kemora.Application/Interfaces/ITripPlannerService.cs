using Kemora.Application.DTOs;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface ITripPlannerService
    {
        Task<TripPlanResponseDto> GenerateTripPlanAsync(TripPlanRequestDto request);
        Task<string> SwapPlaceAsync(string currentPlaceName, string preferences);
    }
}
