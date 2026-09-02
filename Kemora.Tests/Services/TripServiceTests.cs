using AutoMapper;
using FluentAssertions;
using Kemora.Application.DTOs;
using Kemora.Application.Services;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Moq;
using System;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Services
{
    public class TripServiceTests
    {
        private readonly Mock<ITripRepository> _mockTripRepo;
        private readonly Mock<IPlaceRepository> _mockPlaceRepo;
        private readonly Mock<IRepository<TripPlace>> _mockTripPlaceRepo;
        private readonly Mock<IMapper> _mockMapper;
        private readonly Mock<IUnitOfWork> _mockUnitOfWork;
        private readonly TripService _service;

        public TripServiceTests()
        {
            _mockTripRepo = new Mock<ITripRepository>();
            _mockPlaceRepo = new Mock<IPlaceRepository>();
            _mockTripPlaceRepo = new Mock<IRepository<TripPlace>>();
            _mockMapper = new Mock<IMapper>();
            _mockUnitOfWork = new Mock<IUnitOfWork>();

            _service = new TripService(
                _mockTripRepo.Object,
                _mockPlaceRepo.Object,
                _mockTripPlaceRepo.Object,
                _mockMapper.Object,
                _mockUnitOfWork.Object);
        }

        [Fact]
        public async Task CreateAsync_CreatesTrip_ReturnsDto()
        {
            // Arrange
            var dto = new CreateTripDto
            {
                Name = "Cairo Trip",
                Description = "Explore Cairo",
                StartDate = DateTime.UtcNow,
                EndDate = DateTime.UtcNow.AddDays(3)
            };

            var expectedDto = new TripDetailDto { Name = "Cairo Trip" };
            _mockMapper.Setup(m => m.Map<TripDetailDto>(It.IsAny<Trip>())).Returns(expectedDto);

            // Act
            var result = await _service.CreateAsync("user1", dto);

            // Assert
            result.Should().NotBeNull();
            result.Name.Should().Be("Cairo Trip");
            _mockTripRepo.Verify(r => r.AddAsync(It.Is<Trip>(t => t.Name == "Cairo Trip" && t.UserID == "user1")), Times.Once);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
        }

        [Fact]
        public async Task GetAsync_WhenTripNotFound_ReturnsNull()
        {
            // Arrange
            _mockTripRepo.Setup(r => r.GetWithPlacesAsync(999)).ReturnsAsync((Trip?)null);

            // Act
            var result = await _service.GetAsync("user1", 999);

            // Assert
            result.Should().BeNull();
        }

        [Fact]
        public async Task DeleteAsync_WhenTripExists_ReturnsTrue()
        {
            // Arrange
            var trip = new Trip { TripID = 1, UserID = "user1", Name = "Test" };
            _mockTripRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(trip);

            // Act
            var result = await _service.DeleteAsync("user1", 1);

            // Assert
            result.Should().BeTrue();
            _mockTripRepo.Verify(r => r.Remove(trip), Times.Once);
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Once);
        }

        [Fact]
        public async Task DeleteAsync_WhenTripNotFound_ReturnsFalse()
        {
            // Arrange
            _mockTripRepo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Trip?)null);

            // Act
            var result = await _service.DeleteAsync("user1", 999);

            // Assert
            result.Should().BeFalse();
            _mockUnitOfWork.Verify(u => u.CommitAsync(), Times.Never);
        }
    }
}
