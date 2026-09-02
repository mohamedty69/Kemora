using FluentAssertions;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Application.Services;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using AutoMapper;
using Moq;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Services
{
    public class NotificationServiceTests
    {
        private readonly Mock<INotificationRepository> _mockNotifRepo;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly Mock<INotificationPusher> _mockPusher;
        private readonly Mock<IMapper> _mockMapper;
        private readonly NotificationService _service;

        public NotificationServiceTests()
        {
            _mockNotifRepo = new Mock<INotificationRepository>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();
            _mockPusher = new Mock<INotificationPusher>();
            _mockMapper = new Mock<IMapper>();

            _service = new NotificationService(
                _mockNotifRepo.Object,
                _mockUnitOfWork.Object,
                _mockPusher.Object,
                _mockMapper.Object);
        }

        [Fact]
        public async Task CreateNotificationAsync_SavesAndPushes()
        {
            // Act
            await _service.CreateNotificationAsync("user1", "Title", "Message");

            // Assert
            _mockNotifRepo.Verify(r => r.AddAsync(It.Is<Notification>(n =>
                n.UserID == "user1" && n.Title == "Title" && n.Message == "Message" && !n.IsRead)), Times.Once);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
            _mockPusher.Verify(p => p.PushToUserAsync("user1", "Title", "Message"), Times.Once);
        }

        [Fact]
        public async Task GetUnreadCountAsync_ReturnsCount()
        {
            // Arrange
            _mockNotifRepo.Setup(r => r.CountAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<Notification, bool>>>())).ReturnsAsync(5);

            // Act
            var count = await _service.GetUnreadCountAsync("user1");

            // Assert
            count.Should().Be(5);
        }

        [Fact]
        public async Task MarkAsReadAsync_WhenNotificationBelongsToUser_Marks()
        {
            // Arrange
            var notif = new Notification { NotificationID = 1, UserID = "user1", IsRead = false };
            _mockNotifRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(notif);

            // Act
            await _service.MarkAsReadAsync(1, "user1");

            // Assert
            notif.IsRead.Should().BeTrue();
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
        }

        [Fact]
        public async Task MarkAsReadAsync_WhenWrongUser_DoesNothing()
        {
            // Arrange
            var notif = new Notification { NotificationID = 1, UserID = "user1", IsRead = false };
            _mockNotifRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(notif);

            // Act
            await _service.MarkAsReadAsync(1, "user2");

            // Assert
            notif.IsRead.Should().BeFalse();
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Never);
        }
    }
}
