using FluentAssertions;
using Kemora.Application.DTOs;
using System.Net;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Integration
{
    public class AuthIntegrationTests : BaseIntegrationTest
    {
        public AuthIntegrationTests(TestingWebAppFactory factory) : base(factory)
        {
        }

        [Fact]
        public async Task Register_ValidPayload_CreatesUserAndReturnsTokens()
        {
            // Arrange
            var registerDto = new RegisterDto
            {
                FullName = "Integration User",
                Email = "integration@test.com",
                Password = "Password123!",
                Country = "US"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/Auth/register", registerDto);

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var result = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
            result.Should().NotBeNull();
            result!.Token.Should().NotBeNullOrEmpty();
            result.Email.Should().Be("integration@test.com");
            result.Country.Should().Be("US");
        }
        
        [Fact]
        public async Task GoogleLogin_InvalidToken_ReturnsUnauthorized()
        {
            // Arrange
            var externalLoginDto = new ExternalLoginDto
            {
                Provider = "GOOGLE",
                IdToken = "invalid_token_xyz"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/Auth/google-login", externalLoginDto);

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        }
    }
}
