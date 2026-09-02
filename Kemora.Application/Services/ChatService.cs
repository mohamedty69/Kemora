using AutoMapper;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class ChatService : IChatService
    {
        private readonly IRepository<Message> _messageRepo;
        private readonly IUserRepository _userRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public ChatService(IUnitOfWork unitOfWork, IUserRepository userRepo, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _messageRepo = unitOfWork.Repository<Message>();
            _userRepo = userRepo;
            _mapper = mapper;
        }

        public async Task<MessageDto> SendMessageAsync(string senderId, SendMessageDto dto)
        {
            var message = new Message
            {
                SenderID = senderId,
                ReceiverID = dto.ReceiverID,
                Content = dto.Content,
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            await _messageRepo.AddAsync(message);
            await _unitOfWork.CommitAsync();

            var sender = await _userRepo.GetByIdAsync(senderId);
            var receiver = await _userRepo.GetByIdAsync(dto.ReceiverID);

            message.Sender = (ApplicationUser)sender;
            message.Receiver = (ApplicationUser)receiver;

            var result = _mapper.Map<MessageDto>(message);
            result.SenderName = sender?.FullName ?? "Unknown";
            result.SenderProfilePicture = sender?.ProfilePictureUrl;
            result.ReceiverName = receiver?.FullName ?? "Unknown";
            result.ReceiverProfilePicture = receiver?.ProfilePictureUrl;

            return result;
        }

        public async Task<List<MessageDto>> GetConversationAsync(string userId, string contactId, int page, int pageSize)
        {
            var messages = await _messageRepo.GetPagedAsync(
                m => (m.SenderID == userId && m.ReceiverID == contactId) || (m.SenderID == contactId && m.ReceiverID == userId),
                q => q.OrderByDescending(m => m.SentAt),
                page, pageSize, m => m.Sender, m => m.Receiver);

            return _mapper.Map<List<MessageDto>>(messages);
        }

        public async Task<List<ConversationDto>> GetConversationsAsync(string userId)
        {
            // Get all messages where user is sender or receiver
            var allMessages = await _messageRepo.GetPagedAsync(
                m => m.SenderID == userId || m.ReceiverID == userId,
                q => q.OrderByDescending(m => m.SentAt),
                1, 1000, m => m.Sender, m => m.Receiver);

            // Group by contact
            var conversations = allMessages
                .GroupBy(m => m.SenderID == userId ? m.ReceiverID : m.SenderID)
                .Select(g => {
                    var lastMsg = g.First();
                    var contact = lastMsg.SenderID == userId ? lastMsg.Receiver : lastMsg.Sender;
                    return new ConversationDto
                    {
                        ContactId = contact.Id,
                        ContactName = contact.FullName,
                        ContactProfilePicture = contact.ProfilePictureUrl,
                        LastMessage = lastMsg.Content,
                        LastMessageAt = lastMsg.SentAt,
                        UnreadCount = g.Count(m => m.ReceiverID == userId && !m.IsRead)
                    };
                })
                .ToList();

            return conversations;
        }

        public async Task<bool> MarkAsReadAsync(string userId, string contactId)
        {
            var unreadMessages = await _messageRepo.GetPagedAsync(
                m => m.ReceiverID == userId && m.SenderID == contactId && !m.IsRead,
                null, 1, 100);

            foreach (var msg in unreadMessages)
            {
                msg.IsRead = true;
            }

            await _unitOfWork.CommitAsync();
            return true;
        }
    }
}
