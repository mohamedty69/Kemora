using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class ReactionService : IReactionService
    {
        private readonly IRepository<PostReaction> _postReactionRepo;
        private readonly IRepository<CommentReaction> _commentReactionRepo;
        private readonly IPostRepository _postRepo;
        private readonly ICommentRepository _commentRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;

        public ReactionService(IRepository<PostReaction> postReactionRepo, IRepository<CommentReaction> commentReactionRepo, IPostRepository postRepo, ICommentRepository commentRepo, IUnitOfWork unitOfWork, INotificationService notificationService)
        {
            _postReactionRepo = postReactionRepo;
            _commentReactionRepo = commentReactionRepo;
            _postRepo = postRepo;
            _commentRepo = commentRepo;
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
        }

        public async Task<bool> ReactToPostAsync(string userId, int postId, ReactToPostDto dto)
        {
            if (!await _postRepo.ExistsAsync(postId)) return false;

            var existing = await _postReactionRepo.FirstOrDefaultAsync(r => r.PostID == postId && r.UserID == userId);
            if (dto.Action == "add")
            {
                if (existing != null)
                {
                    existing.ReactionType = dto.ReactionType;
                    existing.ReactedAt = DateTime.UtcNow;
                }
                else
                {
                    await _postReactionRepo.AddAsync(new PostReaction
                    {
                        PostID = postId, UserID = userId, ReactionType = dto.ReactionType, ReactedAt = DateTime.UtcNow
                    });
                }
            }
            else
            {
                if (existing != null) _postReactionRepo.Remove(existing);
            }

            await _unitOfWork.CommitAsync();

            // Notify post owner about the reaction
            if (dto.Action == "add")
            {
                var post = await _postRepo.GetByIdAsync(postId);
                if (post != null && post.UserID != userId)
                {
                    await _notificationService.CreateNotificationAsync(
                        post.UserID, "New Reaction", $"Someone reacted to your post with {dto.ReactionType}");
                }
            }

            return true;
        }

        public async Task<bool> ReactToCommentAsync(string userId, int commentId, ReactToCommentDto dto)
        {
            if (!await _commentRepo.ExistsAsync(commentId)) return false;

            var existing = await _commentReactionRepo.FirstOrDefaultAsync(r => r.CommentID == commentId && r.UserID == userId);
            if (dto.Action == "add")
            {
                if (existing != null)
                {
                    existing.ReactionType = dto.ReactionType;
                    existing.ReactedAt = DateTime.UtcNow;
                }
                else
                {
                    await _commentReactionRepo.AddAsync(new CommentReaction
                    {
                        CommentID = commentId, UserID = userId, ReactionType = dto.ReactionType, ReactedAt = DateTime.UtcNow
                    });
                }
            }
            else
            {
                if (existing != null) _commentReactionRepo.Remove(existing);
            }

            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
