using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Repositories
{
    public class StoryRepository : Repository<Story>, IStoryRepository
    {
        private readonly ApplicationDbContext _context;

        public StoryRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<Story>> GetActiveStoriesAsync()
        {
            return await _context.Stories
                .Include(s => s.User)
                .Include(s => s.Location)
                .Where(s => s.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(s => s.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Story>> GetStoriesByUserAsync(string userId)
        {
            return await _context.Stories
                .Include(s => s.User)
                .Include(s => s.Location)
                .Where(s => s.UserID == userId && s.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(s => s.CreatedAt)
                .ToListAsync();
        }
    }
}
