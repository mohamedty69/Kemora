using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IFavoriteService
    {
        Task<bool> AddFavoriteAsync(string userId, int placeId);
        Task<bool> RemoveFavoriteAsync(string userId, int placeId);
        Task<List<PlacePublicDto>> GetMyFavoritesAsync(string userId);
        Task<FavoriteCheckDto> CheckFavoriteAsync(string userId, int placeId);
    }
}
