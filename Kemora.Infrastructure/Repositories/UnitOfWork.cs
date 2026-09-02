using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using System.Threading.Tasks;
using System.Collections.Generic; // Added for Dictionary
using System; // Added for Activator

namespace Kemora.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private readonly Dictionary<string, object> _repositories = new();

        public UnitOfWork(ApplicationDbContext context)
        {
            _context = context;
        }

        public IRepository<T> Repository<T>() where T : class
        {
            var type = typeof(T).Name;

            if (!_repositories.ContainsKey(type))
            {
                var repositoryType = typeof(Repository<>);
                var repositoryInstance = Activator.CreateInstance(repositoryType.MakeGenericType(typeof(T)), _context);
                _repositories.Add(type, repositoryInstance!);
            }

            return (IRepository<T>)_repositories[type];
        }

        public async Task<int> CommitAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
