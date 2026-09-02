using Kemora.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IChatService
    {
        Task<MessageDto> SendMessageAsync(string senderId, SendMessageDto dto);
        Task<List<MessageDto>> GetConversationAsync(string userId, string contactId, int page, int pageSize);
        Task<List<ConversationDto>> GetConversationsAsync(string userId);
        Task<bool> MarkAsReadAsync(string userId, string contactId);
    }
}
