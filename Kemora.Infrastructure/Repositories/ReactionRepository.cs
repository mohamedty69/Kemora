using Kemora.Domain.Entities;
using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Repositories
{
    public class ReactionRepository : IReactionRepository
    {
        private readonly ApplicationDbContext _ctx;

        public ReactionRepository(ApplicationDbContext ctx)
        {
            _ctx = ctx;
        }




    }
}
