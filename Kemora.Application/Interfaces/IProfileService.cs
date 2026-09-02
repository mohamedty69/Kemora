using Kemora.Application.DTOs;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IProfileService
    {
        Task<ProfileDto?> GetMyProfileAsync(string userId);
        Task<bool> UpdateProfileAsync(string userId, UpdateProfileDto dto);
        Task<PublicProfileDto?> GetPublicProfileAsync(string id);
        Task<(bool Succeeded, string Error, string Url)> UploadProfilePictureAsync(string userId, System.IO.Stream fileStream, string fileName);
    }
}
