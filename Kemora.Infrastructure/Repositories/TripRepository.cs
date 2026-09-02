using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Repositories
{
    public class TripRepository : Repository<Trip>, ITripRepository
    {
        public TripRepository(ApplicationDbContext ctx) : base(ctx) { }

        public async Task<IEnumerable<Trip>> GetByUserIdAsync(string userId, int page, int size)
        {
            return await _dbSet
                .Where(t => t.UserID == userId)
                .OrderByDescending(t => t.StartDate)
                .Include(t => t.TripPlaces)
                    .ThenInclude(tp => tp.Place)
                        .ThenInclude(p => p.Governorate)
                .Skip((page - 1) * size).Take(size)
                .ToListAsync();
        }

        public async Task<int> GetCountByUserIdAsync(string userId) => await _dbSet.CountAsync(t => t.UserID == userId);

        public async Task<Trip?> GetWithPlacesAsync(int id)
        {
            return await _dbSet
                .Include(x => x.TripPlaces).ThenInclude(tp => tp.Place)
                    .ThenInclude(p => p.PlaceType)
                        .ThenInclude(pt => pt.Category)
                .FirstOrDefaultAsync(x => x.TripID == id);
        }

    }
}
