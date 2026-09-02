using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class CommentService : ICommentService
    {
        private readonly ICommentRepository _commentRepo;
        private readonly IPostRepository _postRepo;
        private readonly IUserRepository _userRepo;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;

        public CommentService(ICommentRepository commentRepo, IPostRepository postRepo, IUserRepository userRepo, IMapper mapper, IUnitOfWork unitOfWork, INotificationService notificationService)
        {
            _commentRepo = commentRepo;
            _postRepo = postRepo;
            _userRepo = userRepo;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
        }

        public async Task<CommentResponseDto?> CreateCommentAsync(int postId, string userId, CreateCommentDto dto)
        {
            if (!await _postRepo.ExistsAsync(postId)) return null;

            var user = await _userRepo.GetByIdAsync(userId);
            var comment = new Comment
            {
                Content = dto.Content,
                CreatedAt = DateTime.UtcNow,
                PostID = postId,
                UserID = userId,
                Media = dto.Media?.ConvertAll(m => new CommentMedia { MediaURL = m.MediaURL, MediaType = m.MediaType })
            };

            await _commentRepo.AddAsync(comment);
            await _unitOfWork.CommitAsync();

            var response = _mapper.Map<CommentResponseDto>(comment);
            response.AuthorName = user?.FullName ?? "Unknown";

            // Notify post owner
            var post = await _postRepo.GetByIdAsync(postId);
            if (post != null && post.UserID != userId)
            {
                await _notificationService.CreateNotificationAsync(
                    post.UserID, "New Comment", $"{response.AuthorName} commented on your post");
            }

            return response;
        }

        public async Task<PagedResult<CommentResponseDto>> GetCommentsAsync(int postId, int page, int pageSize)
        {
            if (!await _postRepo.ExistsAsync(postId)) return new PagedResult<CommentResponseDto>();
            
            var comments = await _commentRepo.GetPagedAsync(c => c.PostID == postId, q => q.OrderByDescending(c => c.CreatedAt), page, pageSize, c => c.User, c => c.Media, c => c.Reactions);
            var count = await _commentRepo.CountAsync(c => c.PostID == postId);
            return new PagedResult<CommentResponseDto>
            {
                Items = _mapper.Map<List<CommentResponseDto>>(comments),
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<bool> UpdateCommentAsync(int id, string userId, UpdateCommentDto dto)
        {
            var comment = await _commentRepo.GetByIdAsync(id);
            if (comment == null || comment.UserID != userId) return false;

            comment.Content = dto.Content;
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeleteCommentAsync(int id, string userId)
        {
            var comment = await _commentRepo.GetByIdAsync(id);
            if (comment == null || comment.UserID != userId) return false;

            _commentRepo.Remove(comment);
            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
