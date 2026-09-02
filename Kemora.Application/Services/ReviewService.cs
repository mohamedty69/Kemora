using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IReviewRepository _reviewRepo;
        private readonly IPlaceRepository _placeRepo;
        private readonly IMapper _mapper;

        private readonly IUnitOfWork _unitOfWork;

        public ReviewService(IReviewRepository reviewRepo, IPlaceRepository placeRepo, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _reviewRepo = reviewRepo;
            _placeRepo = placeRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }

        public async Task<ReviewResponseDto?> CreateReviewAsync(string userId, string userName, int placeId, CreateReviewDto dto)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return null;

            var review = new Review
            {
                AuthorName = string.IsNullOrWhiteSpace(userName) ? "Anonymous" : userName,
                Rating = dto.Rating,
                Text = dto.Text,
                PlaceID = placeId
            };

            await _reviewRepo.AddAsync(review);
            await _unitOfWork.CommitAsync();

            return _mapper.Map<ReviewResponseDto>(review);
        }

        public async Task<PagedResult<ReviewResponseDto>> GetReviewsAsync(int placeId, int page, int pageSize)
        {
            if (!await _placeRepo.ExistsAsync(placeId)) return new PagedResult<ReviewResponseDto>();

            var reviews = await _reviewRepo.GetPagedAsync(r => r.PlaceID == placeId, q => q.OrderByDescending(r => r.ReviewID), page, pageSize);
            var count = await _reviewRepo.CountAsync(r => r.PlaceID == placeId);
            return new PagedResult<ReviewResponseDto>
            {
                Items = _mapper.Map<List<ReviewResponseDto>>(reviews),
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<bool> DeleteReviewAsync(int id, string userName, string userId)
        {
            var review = await _reviewRepo.GetByIdAsync(id);
            if (review == null || review.AuthorName != userName) return false;

            _reviewRepo.Remove(review);
            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
