using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class PhotoService : IPhotoService
    {
        private readonly IPhotoRepository _photoRepo;
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;

        private readonly IUnitOfWork _unitOfWork;

        public PhotoService(IPhotoRepository photoRepo, IPlaceRepository placeRepo, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _photoRepo = photoRepo;
            _placeRepo = placeRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }

        public async Task<PhotoResponseDto?> AddPhotoAsync(int placeId, CreatePhotoDto dto)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return null;

            var photo = new Photo { PlaceID = placeId, ImageURL = dto.ImageURL, IsMain = false };
            await _photoRepo.AddAsync(photo);
            await _unitOfWork.CommitAsync();
            return _mapper.Map<PhotoResponseDto>(photo);
        }

        public async Task<List<PhotoResponseDto>> GetPlacePhotosAsync(int placeId)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return new List<PhotoResponseDto>();

            var photos = await _photoRepo.FindAsync(p => p.PlaceID == placeId);
            return _mapper.Map<List<PhotoResponseDto>>(photos);
        }

        public async Task<bool> SetMainPhotoAsync(int placeId, int photoId)
        {
            var photoToSet = await _photoRepo.GetByIdAsync(photoId);
            if (photoToSet == null || photoToSet.PlaceID != placeId)
                return false;

            var existingMain = await _photoRepo.FirstOrDefaultAsync(p => p.PlaceID == placeId && p.IsMain);
            if (existingMain != null) existingMain.IsMain = false;

            photoToSet.IsMain = true;
            
            var place = await _placeRepo.GetByIdAsync(placeId);
            if (place != null) place.MainImageURL = photoToSet.ImageURL;

            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeletePhotoAsync(int placeId, int photoId)
        {
            var photo = await _photoRepo.GetByIdAsync(photoId);
            if (photo == null || photo.PlaceID != placeId) return false;

            _photoRepo.Remove(photo);
            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
