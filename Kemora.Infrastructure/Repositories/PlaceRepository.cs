using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Repositories
{
    public class PlaceRepository : Repository<Place>, IPlaceRepository
    {
        public PlaceRepository(ApplicationDbContext ctx) : base(ctx) { }

        public async Task<IEnumerable<Place>> GetFilteredAsync(string? query, int? governorateId, int? categoryId, string? categoryName, string? sortBy, int page, int size)
        {
            var sq = _dbSet.AsQueryable().Where(p => !string.IsNullOrEmpty(p.MainImageURL));

            if (governorateId.HasValue) sq = sq.Where(p => p.GovernorateID == governorateId.Value);
            if (categoryId.HasValue) sq = sq.Where(p => p.PlaceType.CategoryID == categoryId.Value);
            if (!string.IsNullOrWhiteSpace(categoryName)) sq = sq.Where(p => p.PlaceType.Category.Name == categoryName);
            if (!string.IsNullOrWhiteSpace(query)) sq = sq.Where(p => p.Name.Contains(query) || p.Description.Contains(query));

            if (sortBy?.ToLower() == "rating")
            {
                sq = sq.OrderByDescending(p => p.Rating);
            }
            else
            {
                sq = sq.OrderByDescending(p => p.PlaceID);
            }

            return await sq
                .Include(p => p.Governorate)
                .Include(p => p.PlaceType).ThenInclude(pt => pt.Category)
                .Include(p => p.Reviews)
                .OrderByDescending(p => p.PlaceID)
                .Skip((page - 1) * size).Take(size)
                .ToListAsync();
        }

        public async Task<int> GetFilteredCountAsync(string? query, int? governorateId, int? categoryId, string? categoryName)
        {
            var sq = _dbSet.AsQueryable().Where(p => !string.IsNullOrEmpty(p.MainImageURL));

            if (governorateId.HasValue) sq = sq.Where(p => p.GovernorateID == governorateId.Value);
            if (categoryId.HasValue) sq = sq.Where(p => p.PlaceType.CategoryID == categoryId.Value);
            if (!string.IsNullOrWhiteSpace(categoryName)) sq = sq.Where(p => p.PlaceType.Category.Name == categoryName);
            if (!string.IsNullOrWhiteSpace(query)) sq = sq.Where(p => p.Name.Contains(query) || p.Description.Contains(query));

            return await sq.CountAsync();
        }

        public async Task<Place?> GetWithDetailsAsync(int id)
        {
            return await _dbSet
                .Include(p => p.Governorate)
                .Include(p => p.PlaceType).ThenInclude(pt => pt.Category)
                .Include(p => p.Photos)
                .Include(p => p.Reviews)
                .Include(p => p.Events.Where(e => e.EndDate >= System.DateTime.UtcNow))
                .FirstOrDefaultAsync(p => p.PlaceID == id);
        }

        public async Task<IEnumerable<Place>> GetTopPlacesAsync(int count = 20)
        {
            return await _dbSet
                .Where(p => !string.IsNullOrEmpty(p.MainImageURL))
                .Include(p => p.Governorate)
                .Include(p => p.PlaceType).ThenInclude(pt => pt.Category)
                .Include(p => p.Reviews)
                .OrderByDescending(p => p.Rating)
                .Take(count)
                .ToListAsync();
        }
    }
}
