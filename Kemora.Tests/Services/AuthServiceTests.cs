using FluentAssertions;
using Kemora.Application.DTOs;
using Kemora.Application.Interfaces;
using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Kemora.Infrastructure.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using AutoMapper;
using Moq;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;
using System;
using Microsoft.Extensions.Configuration;

namespace Kemora.Tests.Services
{
    public class AuthServiceTests
    {
        private readonly Mock<UserManager<ApplicationUser>> _mockUserManager;
        private readonly Mock<SignInManager<ApplicationUser>> _mockSignInManager;
        private readonly Mock<ITokenService> _mockTokenService;
        private readonly Mock<IEmailService> _mockEmailService;
        private readonly Mock<IMapper> _mockMapper;
        private readonly Mock<IConfiguration> _mockConfiguration;
        private readonly ApplicationDbContext _dbContext;
        private readonly AuthService _service;

        public AuthServiceTests()
        {
            var store = new Mock<IUserStore<ApplicationUser>>();
            _mockUserManager = new Mock<UserManager<ApplicationUser>>(store.Object, null, null, null, null, null, null, null, null);
            
            var contextAccessor = new Mock<Microsoft.AspNetCore.Http.IHttpContextAccessor>();
            var claimsFactory = new Mock<IUserClaimsPrincipalFactory<ApplicationUser>>();
            _mockSignInManager = new Mock<SignInManager<ApplicationUser>>(_mockUserManager.Object, contextAccessor.Object, claimsFactory.Object, null, null, null, null);
            
            _mockTokenService = new Mock<ITokenService>();
            _mockEmailService = new Mock<IEmailService>();
            _mockMapper = new Mock<IMapper>();
            _mockConfiguration = new Mock<IConfiguration>();

            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .ConfigureWarnings(x => x.Ignore(InMemoryEventId.TransactionIgnoredWarning))
                .Options;
            _dbContext = new ApplicationDbContext(options);

            _service = new AuthService(
                _mockUserManager.Object,
                _mockSignInManager.Object,
                _mockTokenService.Object,
                _dbContext,
                _mockEmailService.Object,
                _mockMapper.Object,
                _mockConfiguration.Object);
        }

        [Fact]
        public async Task RegisterAsync_WithNewUser_CreatesUserWithCountryAndTokens()
        {
            // Arrange
            var registerDto = new RegisterDto
            {
                FullName = "Test Register",
                Email = "test@kemora.com",
                Country = "Egypt",
                Password = "Password123!"
            };

            _mockUserManager.Setup(u => u.FindByEmailAsync(registerDto.Email)).ReturnsAsync((ApplicationUser)null);
            _mockUserManager.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), registerDto.Password))
                .ReturnsAsync(IdentityResult.Success);
            _mockUserManager.Setup(u => u.GetUsersInRoleAsync("Admin")).ReturnsAsync(new List<ApplicationUser>());
            
            _mockTokenService.Setup(t => t.GenerateRefreshToken()).Returns("dummy-refresh-token");
            _mockTokenService.Setup(t => t.CreateTokenAsync(It.IsAny<ApplicationUser>())).ReturnsAsync("dummy-jwt-token");

            var mappedDto = new AuthResponseDto { UserId = "123", FullName = "Test Register", Country = "Egypt", Email = "test@kemora.com" };
            _mockMapper.Setup(m => m.Map<AuthResponseDto>(It.IsAny<ApplicationUser>())).Returns(mappedDto);

            // Act
            var result = await _service.RegisterAsync(registerDto);

            // Assert
            result.Succeeded.Should().BeTrue();
            result.Data.Should().NotBeNull();
            result.Data.Country.Should().Be("Egypt");
            result.Data.Token.Should().Be("dummy-jwt-token");
            
            _mockUserManager.Verify(u => u.CreateAsync(It.Is<ApplicationUser>(a => a.Country == "Egypt" && a.Email == "test@kemora.com"), "Password123!"), Times.Once);
            _mockEmailService.Verify(e => e.SendEmailAsync("test@kemora.com", It.IsAny<string>(), It.IsAny<string>()), Times.Once);
        }

        [Fact]
        public async Task RegisterAsync_WithExistingEmail_ReturnsError()
        {
            // Arrange
            var registerDto = new RegisterDto { Email = "test@kemora.com" };
            _mockUserManager.Setup(u => u.FindByEmailAsync(registerDto.Email)).ReturnsAsync(new ApplicationUser());

            // Act
            var result = await _service.RegisterAsync(registerDto);

            // Assert
            result.Succeeded.Should().BeFalse();
            result.Error.Should().Be("Email already exists");
            result.Data.Should().BeNull();
        }

        [Fact]
        public async Task LoginAsync_WithWrongPassword_ReturnsError()
        {
            // Arrange
            var loginDto = new LoginDto { Email = "user@k.com", Password = "wrongpassword" };
            var user = new ApplicationUser { Email = "user@k.com" };
            _mockUserManager.Setup(u => u.FindByEmailAsync(loginDto.Email)).ReturnsAsync(user);
            _mockSignInManager.Setup(s => s.CheckPasswordSignInAsync(user, loginDto.Password, false)).ReturnsAsync(SignInResult.Failed);

            // Act
            var result = await _service.LoginAsync(loginDto);

            // Assert
            result.Succeeded.Should().BeFalse();
            result.Error.Should().Be("Invalid Password");
        }
    }
}
