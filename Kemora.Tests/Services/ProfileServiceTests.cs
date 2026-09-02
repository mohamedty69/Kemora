using AutoMapper;
using FluentAssertions;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Infrastructure.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Moq;
using System.IO;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Services
{
    public class ProfileServiceTests
    {
        private readonly Mock<UserManager<ApplicationUser>> _mockUserManager;
        private readonly Mock<IMapper> _mockMapper;
        private readonly Mock<IImageService> _mockImageService;
        private readonly ProfileService _service;

        public ProfileServiceTests()
        {
            var store = new Mock<IUserStore<ApplicationUser>>();
            _mockUserManager = new Mock<UserManager<ApplicationUser>>(store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
            _mockMapper = new Mock<IMapper>();
            _mockImageService = new Mock<IImageService>();

            _service = new ProfileService(_mockUserManager.Object, _mockMapper.Object, _mockImageService.Object);
        }

        [Fact]
        public async Task UploadProfilePictureAsync_WhenNoFile_ReturnsError()
        {
            // Act
            var (succeeded, error, url) = await _service.UploadProfilePictureAsync("user1", null!, "testing.jpg");

            // Assert
            succeeded.Should().BeFalse();
            error.Should().Be("No file uploaded.");
        }

        [Fact]
        public async Task UploadProfilePictureAsync_WhenInvalidExtension_ReturnsError()
        {
            // Arrange
            var stream = new MemoryStream(new byte[1024]);

            // Act
            var (succeeded, error, url) = await _service.UploadProfilePictureAsync("user1", stream, "script.js");

            // Assert
            succeeded.Should().BeFalse();
            error.Should().Be("Only JPG, PNG and WEBP files are allowed.");
        }

        [Fact]
        public async Task UploadProfilePictureAsync_WhenFileTooLarge_ReturnsError()
        {
            // Arrange
            var stream = new MemoryStream(new byte[6 * 1024 * 1024]); // 6MB

            // Act
            var (succeeded, error, url) = await _service.UploadProfilePictureAsync("user1", stream, "large.jpg");

            // Assert
            succeeded.Should().BeFalse();
            error.Should().Be("File size must not exceed 5MB.");
        }

        [Fact]
        public async Task UploadProfilePictureAsync_WhenUserNotFound_ReturnsError()
        {
            // Arrange
            var stream = new MemoryStream(new byte[1024]);
            _mockUserManager.Setup(m => m.FindByIdAsync("invalid")).ReturnsAsync((ApplicationUser)null!);

            // Act
            var (succeeded, error, url) = await _service.UploadProfilePictureAsync("invalid", stream, "image.png");

            // Assert
            succeeded.Should().BeFalse();
            error.Should().Be("User not found.");
        }

        [Fact]
        public async Task UploadProfilePictureAsync_WhenValid_UpdatesUserAndReturnsUrl()
        {
            // Arrange
            var stream = new MemoryStream(new byte[1024]);

            var user = new ApplicationUser { Id = "user1" };
            _mockUserManager.Setup(m => m.FindByIdAsync("user1")).ReturnsAsync(user);
            _mockImageService.Setup(m => m.UploadImageAsync(It.IsAny<Stream>(), "image.jpg")).ReturnsAsync("http://cloudinary.com/image.jpg");

            // Act
            var (succeeded, error, url) = await _service.UploadProfilePictureAsync("user1", stream, "image.jpg");

            // Assert
            succeeded.Should().BeTrue();
            url.Should().Be("http://cloudinary.com/image.jpg");
            user.ProfilePictureUrl.Should().Be("http://cloudinary.com/image.jpg");
            _mockUserManager.Verify(m => m.UpdateAsync(user), Times.Once);
        }
    }
}
