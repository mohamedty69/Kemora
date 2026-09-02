using Kemora.Application.DTOs;
using Kemora.Infrastructure.Data;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;

namespace Kemora.Tests.Integration
{
    public abstract class BaseIntegrationTest : IClassFixture<TestingWebAppFactory>, IAsyncLifetime
    {
        protected readonly TestingWebAppFactory _factory;
        protected readonly HttpClient _client;
        protected readonly IServiceScope _scope;
        protected readonly ApplicationDbContext _dbContext;

        protected BaseIntegrationTest(TestingWebAppFactory factory)
        {
            _factory = factory;
            _client = factory.CreateClient();
            _scope = factory.Services.CreateScope();
            _dbContext = _scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        }

        public async Task InitializeAsync()
        {
            await _dbContext.Database.EnsureDeletedAsync();
            await _dbContext.Database.EnsureCreatedAsync();

            await RoleSeeder.SeedRolesAsync(_scope.ServiceProvider);
        }

        public async Task DisposeAsync()
        {
            _scope.Dispose();
            await Task.CompletedTask;
        }

        protected async Task<string> AuthenticateAsync(string email, string password)
        {
            var response = await _client.PostAsJsonAsync("/api/v1/auth/login", new LoginDto { Email = email, Password = password });
            response.EnsureSuccessStatusCode();
            var result = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
            return result!.Token;
        }
    }
}
