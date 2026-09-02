using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class FavoriteService : IFavoriteService
    {
        private readonly IFavoriteRepository _favoriteRepo;
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;

        private readonly IUnitOfWork _unitOfWork;

        public FavoriteService(IFavoriteRepository favoriteRepo, IPlaceRepository placeRepo, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _favoriteRepo = favoriteRepo;
            _placeRepo = placeRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> AddFavoriteAsync(string userId, int placeId)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return false;
            if (await _favoriteRepo.IsFavoritedAsync(userId, placeId)) return true;

            await _favoriteRepo.AddAsync(new UserFavorite { UserID = userId, PlaceID = placeId });
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> RemoveFavoriteAsync(string userId, int placeId)
        {
            var fav = await _favoriteRepo.GetAsync(userId, placeId);
            if (fav == null) return true;

            _favoriteRepo.Remove(fav);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<List<PlacePublicDto>> GetMyFavoritesAsync(string userId)
        {
            var favs = await _favoriteRepo.GetByUserIdAsync(userId);
            var places = favs.Select(f => f.Place).ToList();
            return _mapper.Map<List<PlacePublicDto>>(places);
        }

        public async Task<FavoriteCheckDto> CheckFavoriteAsync(string userId, int placeId)
        {
            var exists = await _favoriteRepo.IsFavoritedAsync(userId, placeId);
            return new FavoriteCheckDto { IsFavorited = exists };
        }
    }
}
