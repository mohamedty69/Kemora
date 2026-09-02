using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IPlacePublicService
    {
        Task<PagedResult<PlacePublicDto>> GetPlacesAsync(int? governorateId, int? categoryId, string? categoryName, string? searchQuery, string? sortBy, int page, int pageSize);
        Task<PlaceDetailPublicDto?> GetPlaceDetailAsync(int id);
        Task<List<GovernorateDto>> GetGovernoratesAsync();
        Task<List<PlacePublicDto>> GetTopPlacesAsync();
    }
}
