using Kemora.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Domain.Interfaces
{
    public interface IPostRepository : IRepository<Post>
    {
        Task<Post?> GetByIdWithDetailsAsync(int id);
    }
}
