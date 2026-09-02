using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using AutoMapper;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kemora.Application.Services
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notificationRepo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationPusher _pusher;
        private readonly IMapper _mapper;

        public NotificationService(INotificationRepository notificationRepo, IUnitOfWork unitOfWork, INotificationPusher pusher, IMapper mapper)
        {
            _notificationRepo = notificationRepo;
            _unitOfWork = unitOfWork;
            _pusher = pusher;
            _mapper = mapper;
        }

        public async Task<PagedResult<NotificationDto>> GetMyNotificationsAsync(string userId, int page, int pageSize)
        {
            var notifs = await _notificationRepo.GetPagedAsync(n => n.UserID == userId, q => q.OrderByDescending(n => n.CreatedAt), page, pageSize);
            var count = await _notificationRepo.CountAsync(n => n.UserID == userId);

            var items = _mapper.Map<List<NotificationDto>>(notifs);

            return new PagedResult<NotificationDto>
            {
                Items = items,
                TotalCount = count,
                PageNumber = page,
                PageSize = pageSize
            };
        }

        public async Task<int> GetUnreadCountAsync(string userId)
        {
            return await _notificationRepo.CountAsync(n => n.UserID == userId && !n.IsRead);
        }

        public async Task MarkAsReadAsync(int notificationId, string userId)
        {
            var n = await _notificationRepo.GetByIdAsync(notificationId);
            if (n != null && n.UserID == userId)
            {
                n.IsRead = true;
                await _unitOfWork.CommitAsync();
            }
        }

        public async Task MarkAllAsReadAsync(string userId)
        {
            var unread = await _notificationRepo.FindAsync(n => n.UserID == userId && !n.IsRead);
            foreach (var notification in unread)
            {
                notification.IsRead = true;
            }
            await _unitOfWork.CommitAsync();
        }

        public async Task CreateNotificationAsync(string userId, string title, string message)
        {
            var notification = new Notification
            {
                UserID = userId,
                Title = title,
                Message = message,
                CreatedAt = System.DateTime.UtcNow,
                IsRead = false
            };

            await _notificationRepo.AddAsync(notification);
            await _unitOfWork.CommitAsync();

            // Push real-time notification via SignalR
            await _pusher.PushToUserAsync(userId, title, message);
        }
    }
}
