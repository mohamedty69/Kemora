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
    public class PostService : IPostService
    {
        private readonly IPostRepository _postRepo;
        private readonly IMapper _mapper;
        private readonly IUserRepository _userRepo;

        private readonly IUnitOfWork _unitOfWork;

        public PostService(IPostRepository postRepo, IMapper mapper, IUserRepository userRepo, IUnitOfWork unitOfWork)
        {
            _postRepo = postRepo;
            _mapper = mapper;
            _userRepo = userRepo;
            _unitOfWork = unitOfWork;
        }

        public async Task<PostListResponseDto> CreateAsync(string userId, CreatePostDto dto)
        {
            var user = await _userRepo.GetByIdAsync(userId);
            var post = new Post
            {
                Content = dto.Content,
                CreatedAt = DateTime.UtcNow,
                UserID = userId,
                LocationId = dto.LocationId,
                Media = dto.Media?.ConvertAll(m => new PostMedia { MediaURL = m.MediaURL, MediaType = m.MediaType })
            };

            await _postRepo.AddAsync(post);
            await _unitOfWork.CommitAsync();

            var response = _mapper.Map<PostListResponseDto>(post);
            response.AuthorName = user?.FullName ?? "Unknown";
            return response;
        }

        public async Task<PagedResult<PostListResponseDto>> GetPostsAsync(string? currentUserId, int page, int pageSize)
        {
            var posts = await _postRepo.GetPagedAsync(null, q => q.OrderByDescending(p => p.CreatedAt), page, pageSize, p => p.User, p => p.Media, p => p.Reactions, p => p.Comments, p => p.Location);
            var count = await _postRepo.CountAsync();
            
            var postsList = posts.ToList();
            var dtos = _mapper.Map<List<PostListResponseDto>>(postsList);
            if (!string.IsNullOrEmpty(currentUserId))
            {
                for (int i = 0; i < postsList.Count; i++)
                {
                    dtos[i].IsLikedByMe = postsList[i].Reactions.Any(r => r.UserID == currentUserId && r.ReactionType == "Like");
                }
            }

            return new PagedResult<PostListResponseDto>
            {
                Items = dtos,
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<PostDetailResponseDto?> GetPostAsync(int id, string? currentUserId)
        {
            var post = await _postRepo.GetByIdWithDetailsAsync(id);
            if (post == null) return null;
            
            var dto = _mapper.Map<PostDetailResponseDto>(post);
            if (!string.IsNullOrEmpty(currentUserId))
            {
                dto.IsLikedByMe = post.Reactions.Any(r => r.UserID == currentUserId && r.ReactionType == "Like");
            }
            return dto;
        }

        public async Task<PagedResult<PostListResponseDto>> GetMyPostsAsync(string userId, int page, int pageSize)
        {
            var posts = await _postRepo.GetPagedAsync(p => p.UserID == userId, q => q.OrderByDescending(p => p.CreatedAt), page, pageSize, p => p.User, p => p.Media, p => p.Reactions, p => p.Comments, p => p.Location);
            var count = await _postRepo.CountAsync(p => p.UserID == userId);
            
            var postsList = posts.ToList();
            var dtos = _mapper.Map<List<PostListResponseDto>>(postsList);
            foreach (var d in dtos) d.IsLikedByMe = postsList.Any(p => p.PostID == d.PostID && p.Reactions.Any(r => r.UserID == userId && r.ReactionType == "Like"));

            return new PagedResult<PostListResponseDto>
            {
                Items = dtos,
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<bool> UpdatePostAsync(int id, string userId, UpdatePostDto dto)
        {
            var post = await _postRepo.GetByIdAsync(id);
            if (post == null || post.UserID != userId) return false;

            post.Content = dto.Content;
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> DeletePostAsync(int id, string userId)
        {
            var post = await _postRepo.GetByIdWithDetailsAsync(id);
            if (post == null || post.UserID != userId) return false;

            _postRepo.Remove(post);
            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<bool> ToggleLikeAsync(int postId, string userId)
        {
            if (!await _postRepo.ExistsAsync(postId)) return false;

            var reactionRepo = _unitOfWork.Repository<PostReaction>();
            // Search for ANY reaction by this user on this post to handle toggle correctly
            var existingReaction = await reactionRepo.FirstOrDefaultAsync(r => r.PostID == postId && r.UserID == userId);
            
            if (existingReaction != null)
            {
                reactionRepo.Remove(existingReaction);
            }
            else
            {
                await reactionRepo.AddAsync(new PostReaction
                {
                    PostID = postId,
                    UserID = userId,
                    ReactionType = "Like",
                    ReactedAt = DateTime.UtcNow
                });
            }

            await _unitOfWork.CommitAsync();
            return true;
        }

        public async Task<CommentResponseDto?> AddCommentAsync(int postId, string userId, CreateCommentDto dto)
        {
            var post = await _postRepo.GetByIdAsync(postId);
            if (post == null) return null;

            var user = await _userRepo.GetByIdAsync(userId);
            var comment = new Comment
            {
                PostID = postId,
                UserID = userId,
                Content = dto.Content,
                ParentCommentId = dto.ParentCommentId,
                CreatedAt = DateTime.UtcNow
            };

            post.Comments ??= new List<Comment>();
            post.Comments.Add(comment);

            await _unitOfWork.CommitAsync();

            var response = _mapper.Map<CommentResponseDto>(comment);
            response.AuthorName = user?.FullName ?? "Unknown";
            response.AuthorProfilePicture = user?.ProfilePictureUrl;
            return response;
        }
    }
}
