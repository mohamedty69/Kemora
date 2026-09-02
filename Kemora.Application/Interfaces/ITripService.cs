using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface ITripService
    {
        Task<TripDetailDto> CreateAsync(string userId, CreateTripDto dto);
        Task<PagedResult<TripListDto>> ListAsync(string userId, int page, int pageSize);
        Task<TripDetailDto?> GetAsync(string userId, int id);
        Task<bool> UpdateAsync(string userId, int id, UpdateTripDto dto);
        Task<bool> DeleteAsync(string userId, int id);
        
        Task<TripPlaceResponseDto?> AddPlaceAsync(string userId, int tripId, AddTripPlaceDto dto);
        Task<bool> UpdatePlaceAsync(string userId, int tripId, int tpId, UpdateTripPlaceDto dto);
        Task<bool> RemovePlaceAsync(string userId, int tripId, int tpId);
        Task<TripDetailDto> SaveAIPlanAsync(string userId, SaveAIPlanDto dto);
    }
}
