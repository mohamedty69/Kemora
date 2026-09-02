using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IPlaceManagementService
    {
        Task<GovernorateDto> CreateGovernorateAsync(CreateGovernorateDto dto);
        Task<List<GovernorateDto>> GetGovernoratesAsync();
        Task<bool> UpdateGovernorateAsync(int id, CreateGovernorateDto dto);
        Task<bool> DeleteGovernorateAsync(int id);

        Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto);
        Task<List<CategoryDto>> GetCategoriesAsync();
        Task<bool> UpdateCategoryAsync(int id, CreateCategoryDto dto);
        Task<bool> DeleteCategoryAsync(int id);

        Task<PlaceTypeDto?> CreatePlaceTypeAsync(CreatePlaceTypeDto dto);
        Task<List<PlaceTypeDto>> GetPlaceTypesAsync();
        Task<bool> UpdatePlaceTypeAsync(int id, CreatePlaceTypeDto dto);
        Task<bool> DeletePlaceTypeAsync(int id);

        Task<PlaceAdminDto?> CreatePlaceAsync(CreatePlaceDto dto);
        Task<bool> UpdatePlaceAsync(int id, UpdatePlaceDto dto);
        Task<bool> DeletePlaceAsync(int id);
        
        Task<(bool Succeeded, string? Error, string? Url)> UploadPlacePictureAsync(int placeId, System.IO.Stream imageStream, string fileName);
    }
}
