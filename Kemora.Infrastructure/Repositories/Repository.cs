using Kemora.Domain.Interfaces;
using Kemora.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Repositories
{
    public class Repository<T> : IRepository<T> where T : class
    {
        protected readonly ApplicationDbContext _ctx;
        protected readonly DbSet<T> _dbSet;

        public Repository(ApplicationDbContext ctx)
        {
            _ctx = ctx;
            _dbSet = ctx.Set<T>();
        }

        public virtual async Task<T?> GetByIdAsync(object id) => await _dbSet.FindAsync(id);
        public virtual async Task<IEnumerable<T>> GetAllAsync(params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;
            foreach (var include in includes) query = query.Include(include);
            return await query.ToListAsync();
        }

        public virtual async Task<IEnumerable<T>> FindAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet.Where(predicate);
            foreach (var include in includes) query = query.Include(include);
            return await query.ToListAsync();
        }

        public virtual async Task<IEnumerable<T>> GetSortedAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate, System.Func<System.Linq.IQueryable<T>, System.Linq.IOrderedQueryable<T>>? orderBy, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;
            if (predicate != null) query = query.Where(predicate);
            foreach (var include in includes) query = query.Include(include);
            if (orderBy != null) query = orderBy(query);
            return await query.ToListAsync();
        }

        public virtual async Task<IEnumerable<T>> GetPagedAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate, System.Func<System.Linq.IQueryable<T>, System.Linq.IOrderedQueryable<T>>? orderBy, int page, int size, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;
            if (predicate != null) query = query.Where(predicate);
            foreach (var include in includes) query = query.Include(include);
            if (orderBy != null) query = orderBy(query);
            return await query.Skip((page - 1) * size).Take(size).ToListAsync();
        }

        public virtual async Task<int> CountAsync(System.Linq.Expressions.Expression<System.Func<T, bool>>? predicate = null)
        {
            return predicate == null ? await _dbSet.CountAsync() : await _dbSet.CountAsync(predicate);
        }

        public virtual async Task<T?> FirstOrDefaultAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate, params System.Linq.Expressions.Expression<System.Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;
            foreach (var include in includes) query = query.Include(include);
            return await query.FirstOrDefaultAsync(predicate);
        }
        public virtual async Task<bool> AnyAsync(System.Linq.Expressions.Expression<System.Func<T, bool>> predicate) => await _dbSet.AnyAsync(predicate);
        public virtual async Task AddAsync(T entity) => await _dbSet.AddAsync(entity);
        public virtual void Update(T entity) => _dbSet.Update(entity);
        public virtual void Remove(T entity) => _dbSet.Remove(entity);
        
        public virtual async Task<bool> ExistsAsync(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity != null;
        }


    }
}
