using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IPostService
    {
        Task<PostListResponseDto> CreateAsync(string userId, CreatePostDto dto);
        Task<PagedResult<PostListResponseDto>> GetPostsAsync(string? currentUserId, int page, int pageSize);
        Task<PostDetailResponseDto?> GetPostAsync(int id, string? currentUserId);
        Task<PagedResult<PostListResponseDto>> GetMyPostsAsync(string userId, int page, int pageSize);
        Task<bool> UpdatePostAsync(int id, string userId, UpdatePostDto dto);
        Task<bool> DeletePostAsync(int id, string userId);
        Task<bool> ToggleLikeAsync(int postId, string userId);
        Task<CommentResponseDto?> AddCommentAsync(int postId, string userId, CreateCommentDto dto);
    }
}
