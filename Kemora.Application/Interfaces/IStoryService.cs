using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IStoryService
    {
        Task<StoryResponseDto> CreateAsync(string userId, CreateStoryDto dto);
        Task<List<StoryResponseDto>> GetActiveStoriesAsync();
        Task<List<StoryResponseDto>> GetStoriesByUserAsync(string userId);
        Task<bool> DeleteStoryAsync(int storyId, string userId);
    }
}
