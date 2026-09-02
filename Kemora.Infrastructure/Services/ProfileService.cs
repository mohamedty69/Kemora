using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using AutoMapper;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    /// <summary>
    /// Implements IProfileService in Infrastructure because it requires
    /// UserManager<ApplicationUser> which is an ASP.NET Identity (Infrastructure) concern.
    /// The Application layer interface (IProfileService) is still in Application — 
    /// this maintains the dependency inversion principle correctly.
    /// </summary>
    public class ProfileService : IProfileService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IMapper _mapper;
        private readonly IImageService _imageService;

        public ProfileService(UserManager<ApplicationUser> userManager, IMapper mapper, IImageService imageService)
        {
            _userManager = userManager;
            _mapper = mapper;
            _imageService = imageService;
        }

        public async Task<ProfileDto?> GetMyProfileAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return null;

            return _mapper.Map<ProfileDto>(user);
        }

        public async Task<bool> UpdateProfileAsync(string userId, UpdateProfileDto dto)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return false;

            if (dto.FullName != null) user.FullName = dto.FullName;
            if (dto.Bio != null) user.Bio = dto.Bio;
            await _userManager.UpdateAsync(user);
            return true;
        }

        public async Task<PublicProfileDto?> GetPublicProfileAsync(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null) return null;

            return _mapper.Map<PublicProfileDto>(user);
        }

        public async Task<(bool Succeeded, string Error, string Url)> UploadProfilePictureAsync(string userId, System.IO.Stream fileStream, string fileName)
        {
            if (fileStream == null || fileStream.Length == 0)
                return (false, "No file uploaded.", null!);

            var extension = System.IO.Path.GetExtension(fileName).ToLowerInvariant();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png" && extension != ".webp")
                return (false, "Only JPG, PNG and WEBP files are allowed.", null!);

            if (fileStream.Length > 5 * 1024 * 1024)
                return (false, "File size must not exceed 5MB.", null!);

            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return (false, "User not found.", null!);

            var imageUrl = await _imageService.UploadImageAsync(fileStream, fileName);

            if (string.IsNullOrEmpty(imageUrl))
                return (false, "Failed to upload image to cloud storage.", null!);

            user.ProfilePictureUrl = imageUrl;
            await _userManager.UpdateAsync(user);

            return (true, null!, imageUrl);
        }
    }
}
