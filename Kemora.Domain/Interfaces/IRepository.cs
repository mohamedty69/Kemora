using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Domain.Interfaces
{
    public interface IRepository<T> where T : class
    {
        Task<T?> GetByIdAsync(object id);
        Task<IEnumerable<T>> GetAllAsync(params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes);
        Task<IEnumerable<T>> FindAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes);
        Task<IEnumerable<T>> GetSortedAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate, System.Func<System.Linq.IQueryable<T>, System.Linq.IOrderedQueryable<T>>? orderBy, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes);
        Task<IEnumerable<T>> GetPagedAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate, System.Func<System.Linq.IQueryable<T>, System.Linq.IOrderedQueryable<T>>? orderBy, int page, int size, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes);
        Task<int> CountAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate = null);
        Task<T?> FirstOrDefaultAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes);
        Task<bool> AnyAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate);
        Task AddAsync(T entity);
        void Update(T entity);
        void Remove(T entity);
        Task<bool> ExistsAsync(int id);
    }
}
