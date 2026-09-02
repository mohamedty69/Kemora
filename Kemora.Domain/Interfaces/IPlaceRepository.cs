using Kemora.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Domain.Interfaces
{
    public interface IPlaceRepository : IRepository<Place>
    {
        Task<IEnumerable<Place>> GetFilteredAsync(string? query, int? governorateId, int? categoryId, string? categoryName, string? sortBy, int page, int size);
        Task<int> GetFilteredCountAsync(string? query, int? governorateId, int? categoryId, string? categoryName);
        Task<Place?> GetWithDetailsAsync(int id);
        Task<IEnumerable<Place>> GetTopPlacesAsync(int count = 20);
    }
}
