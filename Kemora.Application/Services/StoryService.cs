using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class StoryService : IStoryService
    {
        private readonly IStoryRepository _storyRepo;
        private readonly IUserRepository _userRepo;
        private readonly IUnitOfWork _unitOfWork;

        public StoryService(IStoryRepository storyRepo, IUserRepository userRepo, IUnitOfWork unitOfWork)
        {
            _storyRepo = storyRepo;
            _userRepo = userRepo;
            _unitOfWork = unitOfWork;
        }

        public async Task<StoryResponseDto> CreateAsync(string userId, CreateStoryDto dto)
        {
            var user = await _userRepo.GetByIdAsync(userId);
            var story = new Story
            {
                UserID = userId,
                MediaUrl = dto.MediaUrl,
                MediaType = dto.MediaType,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddHours(24),
                LocationId = dto.LocationId
            };

            await _storyRepo.AddAsync(story);
            await _unitOfWork.CommitAsync();

            return MapToDto(story, user);
        }

        public async Task<List<StoryResponseDto>> GetActiveStoriesAsync()
        {
            var stories = await _storyRepo.GetActiveStoriesAsync();
            return stories.Select(s => MapToDto(s, s.User)).ToList();
        }

        public async Task<List<StoryResponseDto>> GetStoriesByUserAsync(string userId)
        {
            var stories = await _storyRepo.GetStoriesByUserAsync(userId);
            return stories.Select(s => MapToDto(s, s.User)).ToList();
        }

        public async Task<bool> DeleteStoryAsync(int storyId, string userId)
        {
            var story = await _storyRepo.GetByIdAsync(storyId);
            if (story == null || story.UserID != userId)
                return false;

            _storyRepo.Remove(story);
            await _unitOfWork.CommitAsync();
            return true;
        }

        private StoryResponseDto MapToDto(Story story, ApplicationUser? user)
        {
            return new StoryResponseDto
            {
                StoryID = story.StoryID,
                MediaUrl = story.MediaUrl,
                MediaType = story.MediaType,
                CreatedAt = story.CreatedAt,
                ExpiresAt = story.ExpiresAt,
                AuthorId = story.UserID,
                AuthorName = user?.FullName ?? "Unknown",
                AuthorProfilePicture = user?.ProfilePictureUrl,
                LocationId = story.LocationId,
                LocationName = story.Location?.Name,
                Latitude = story.Location?.Latitude,
                Longitude = story.Location?.Longitude
            };
        }
    }
}
