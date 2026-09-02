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
    public class PlaceManagementService : IPlaceManagementService
    {
        private readonly IPlaceRepository _placeRepo;
        private readonly IRepository<Governorate> _govRepo;
        private readonly IRepository<Category> _catRepo;
        private readonly IRepository<PlaceType> _typeRepo;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IImageService _imageService;

        public PlaceManagementService(
            IPlaceRepository placeRepo,
            IRepository<Governorate> govRepo,
            IRepository<Category> catRepo,
            IRepository<PlaceType> typeRepo,
            IMapper mapper,
            IUnitOfWork unitOfWork,
            IImageService imageService)
        {
            _placeRepo = placeRepo;
            _govRepo = govRepo;
            _catRepo = catRepo;
            _typeRepo = typeRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _imageService = imageService;
        }

        public async Task<GovernorateDto> CreateGovernorateAsync(CreateGovernorateDto dto)
        {
            var g = new Governorate { Name = dto.Name, Region = dto.Region ?? "" };
            await _govRepo.AddAsync(g);
            await _unitOfWork.CommitAsync();
            return new GovernorateDto { GovernorateID = g.GovernorateID, Name = g.Name, Region = g.Region };
        }

        public async Task<List<GovernorateDto>> GetGovernoratesAsync()
        {
            var govs = await _govRepo.GetAllAsync();
            return _mapper.Map<List<GovernorateDto>>(govs);
        }

        public async Task<bool> UpdateGovernorateAsync(int id, CreateGovernorateDto dto)
        {
             var g = await _govRepo.GetByIdAsync(id);
             if (g == null) return false;
             g.Name = dto.Name; g.Region = dto.Region ?? "";
             await _unitOfWork.CommitAsync();
             return true;
        }

        public async Task<bool> DeleteGovernorateAsync(int id)
        {
            var g = await _govRepo.GetByIdAsync(id);
            if (g == null) return false;
            _govRepo.Remove(g);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto)
        {
            var c = new Category { Name = dto.Name };
            await _catRepo.AddAsync(c);
            await _unitOfWork.CommitAsync();
            return new CategoryDto { CategoryID = c.CategoryID, Name = c.Name };
        }

        public async Task<List<CategoryDto>> GetCategoriesAsync()
        {
            var c = await _catRepo.GetAllAsync();
            return _mapper.Map<List<CategoryDto>>(c);
        }

        public async Task<bool> UpdateCategoryAsync(int id, CreateCategoryDto dto)
        {
            var c = await _catRepo.GetByIdAsync(id);
            if (c == null) return false;
            c.Name = dto.Name;
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeleteCategoryAsync(int id)
        {
            var c = await _catRepo.GetByIdAsync(id);
            if (c == null) return false;
            _catRepo.Remove(c);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<PlaceTypeDto?> CreatePlaceTypeAsync(CreatePlaceTypeDto dto)
        {
            if (!await _catRepo.ExistsAsync(dto.CategoryID)) return null;
            var pt = new PlaceType { GoogleType = dto.GoogleType, DisplayName = dto.DisplayName, CategoryID = dto.CategoryID };
            await _typeRepo.AddAsync(pt);
            await _unitOfWork.CommitAsync();
            
            var created = await _typeRepo.GetByIdAsync(pt.TypeID);
            return _mapper.Map<PlaceTypeDto>(created);
        }

        public async Task<List<PlaceTypeDto>> GetPlaceTypesAsync()
        {
            var pts = await _typeRepo.GetAllAsync(pt => pt.Category);
            return _mapper.Map<List<PlaceTypeDto>>(pts);
        }

        public async Task<bool> UpdatePlaceTypeAsync(int id, CreatePlaceTypeDto dto)
        {
            var pt = await _typeRepo.GetByIdAsync(id);
            if (pt == null || !await _catRepo.ExistsAsync(dto.CategoryID)) return false;
            pt.GoogleType = dto.GoogleType; pt.DisplayName = dto.DisplayName; pt.CategoryID = dto.CategoryID;
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeletePlaceTypeAsync(int id)
        {
            var pt = await _typeRepo.GetByIdAsync(id);
            if (pt == null) return false;
            _typeRepo.Remove(pt);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<PlaceAdminDto?> CreatePlaceAsync(CreatePlaceDto dto)
        {
            if (!await _govRepo.ExistsAsync(dto.GovernorateID) || !await _typeRepo.ExistsAsync(dto.PlaceTypeID)) return null;

            var p = new Place
            {
                Name = dto.Name, Description = dto.Description, Address = dto.Address,
                Latitude = dto.Latitude, Longitude = dto.Longitude, Phone = dto.Phone, Website = dto.Website,
                PriceLevel = dto.PriceLevel, GovernorateID = dto.GovernorateID, PlaceTypeID = dto.PlaceTypeID
            };
            await _placeRepo.AddAsync(p);
            await _unitOfWork.CommitAsync();
            
            var created = await _placeRepo.GetWithDetailsAsync(p.PlaceID);
            return _mapper.Map<PlaceAdminDto>(created);
        }

        public async Task<bool> UpdatePlaceAsync(int id, UpdatePlaceDto dto)
        {
            var p = await _placeRepo.GetByIdAsync(id);
            if (p == null) return false;

            if (dto.GovernorateID.HasValue && !await _govRepo.ExistsAsync(dto.GovernorateID.Value)) return false;
            if (dto.PlaceTypeID.HasValue && !await _typeRepo.ExistsAsync(dto.PlaceTypeID.Value)) return false;

            if (dto.Name != null) p.Name = dto.Name;
            if (dto.Description != null) p.Description = dto.Description;
            if (dto.Address != null) p.Address = dto.Address;
            if (dto.Latitude.HasValue) p.Latitude = dto.Latitude.Value;
            if (dto.Longitude.HasValue) p.Longitude = dto.Longitude.Value;
            if (dto.Phone != null) p.Phone = dto.Phone;
            if (dto.Website != null) p.Website = dto.Website;
            if (dto.PriceLevel.HasValue) p.PriceLevel = dto.PriceLevel.Value;
            if (dto.GovernorateID.HasValue) p.GovernorateID = dto.GovernorateID.Value;
            if (dto.PlaceTypeID.HasValue) p.PlaceTypeID = dto.PlaceTypeID.Value;

            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeletePlaceAsync(int id)
        {
            var p = await _placeRepo.GetByIdAsync(id);
            if (p == null) return false;
            _placeRepo.Remove(p);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<(bool Succeeded, string? Error, string? Url)> UploadPlacePictureAsync(int placeId, System.IO.Stream imageStream, string fileName)
        {
            var p = await _placeRepo.GetByIdAsync(placeId);
            if (p == null) return (false, "Place not found.", null);

            var url = await _imageService.UploadImageAsync(imageStream, fileName);
            if (string.IsNullOrEmpty(url)) return (false, "Failed to upload image.", null);

            p.MainImageURL = url;
            await _unitOfWork.CommitAsync();

            return (true, null, url);
        }
    }
}
