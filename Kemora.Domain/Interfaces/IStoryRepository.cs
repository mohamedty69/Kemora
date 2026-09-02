using Kemora.Domain.Entities;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace Kemora.Domain.Interfaces
{
    public interface IStoryRepository : IRepository<Story>
    {
        Task<List<Story>> GetActiveStoriesAsync();
        Task<List<Story>> GetStoriesByUserAsync(string userId);
    }
}
