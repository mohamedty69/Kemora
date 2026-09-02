using AutoMapper;
using FluentAssertions;
using Kemora.Application.DTOs;
using Kemora.Application.Services;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Moq;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Services
{
    public class PostServiceTests
    {
        private readonly Mock<IPostRepository> _mockPostRepo;
        private readonly Mock<IMapper> _mockMapper;
        private readonly Mock<IUserRepository> _mockUserRepo;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly PostService _service;

        public PostServiceTests()
        {
            _mockPostRepo = new Mock<IPostRepository>();
            _mockMapper = new Mock<IMapper>();
            _mockUserRepo = new Mock<IUserRepository>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();

            _service = new PostService(
                _mockPostRepo.Object,
                _mockMapper.Object,
                _mockUserRepo.Object,
                _mockUnitOfWork.Object);
        }

        [Fact]
        public async Task CreateAsync_CreatesPostAndReturnsDto()
        {
            // Arrange
            var dto = new CreatePostDto { Content = "Test Post" };
            var user = new ApplicationUser { Id = "user1", FullName = "Test User" };

            _mockUserRepo.Setup(r => r.GetByIdAsync("user1")).ReturnsAsync(user);
            
            var expectedResponse = new PostListResponseDto { Content = "Test Post" };
            _mockMapper.Setup(m => m.Map<PostListResponseDto>(It.IsAny<Post>()))
                       .Returns(expectedResponse);

            // Act
            var result = await _service.CreateAsync("user1", dto);

            // Assert
            result.Should().NotBeNull();
            result.AuthorName.Should().Be("Test User");

            _mockPostRepo.Verify(r => r.AddAsync(It.Is<Post>(p => p.Content == "Test Post" && p.UserID == "user1")), Times.Once);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
        }

        [Fact]
        public async Task CreateAsync_UserNotFound_CreatesPostWithUnknownAuthor()
        {
            // Arrange
            _mockUserRepo.Setup(r => r.GetByIdAsync("invalid")).ReturnsAsync((ApplicationUser)null);
            _mockMapper.Setup(m => m.Map<PostListResponseDto>(It.IsAny<Post>())).Returns(new PostListResponseDto());
            var dto = new CreatePostDto { Content = "Ghost Post" };

            // Act
            var result = await _service.CreateAsync("invalid", dto);

            // Assert
            result.Should().NotBeNull();
            result.AuthorName.Should().Be("Unknown");
            _mockPostRepo.Verify(r => r.AddAsync(It.IsAny<Post>()), Times.Once);
        }

        [Fact]
        public async Task DeleteAsync_WhenUserIsAuthor_DeletesSuccessfully()
        {
            // Arrange
            var post = new Post { PostID = 1, UserID = "author1" };
            _mockPostRepo.Setup(r => r.GetByIdWithDetailsAsync(1)).ReturnsAsync(post);

            // Act
            var result = await _service.DeletePostAsync(1, "author1");

            // Assert
            result.Should().BeTrue();
            _mockPostRepo.Verify(r => r.Remove(post), Times.Once);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
        }

        [Fact]
        public async Task DeleteAsync_WhenUserIsNotAuthor_ReturnsFalse()
        {
            // Arrange
            var post = new Post { PostID = 2, UserID = "author1" };
            _mockPostRepo.Setup(r => r.GetByIdWithDetailsAsync(2)).ReturnsAsync(post);

            // Act
            var result = await _service.DeletePostAsync(2, "hacker_guy");

            // Assert
            result.Should().BeFalse();
            _mockPostRepo.Verify(r => r.Remove(It.IsAny<Post>()), Times.Never);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Never);
        }

        [Fact]
        public async Task UpdateAsync_WhenPostDoesNotExist_ReturnsNull()
        {
            // Arrange
            _mockPostRepo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Post)null);
            var dto = new UpdatePostDto { Content = "New Content" };

            // Act
            var result = await _service.UpdatePostAsync(999, "user1", dto);

            // Assert
            result.Should().BeFalse();
        }

        [Fact]
        public async Task UpdateAsync_WhenUserNotOwner_ReturnsNull()
        {
            // Arrange
            var post = new Post { PostID = 3, UserID = "author1" };
            _mockPostRepo.Setup(r => r.GetByIdAsync(3)).ReturnsAsync(post);
            var dto = new UpdatePostDto { Content = "Hijacked" };

            // Act
            var result = await _service.UpdatePostAsync(3, "hacker", dto);

            // Assert
            result.Should().BeFalse();
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Never);
        }
    }
}
