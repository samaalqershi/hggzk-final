using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Interfaces; // added back for IRepository & ISpecification
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Base
{
    /// <summary>
    /// تنفيذ مستودع عام.
    /// Generic repository implementation.
    /// </summary>
    public class BaseRepository<T> : IRepository<T> where T : class
    {
        protected readonly YemenBookingDbContext _context;
        protected readonly DbSet<T> _dbSet;

        /// <summary>
        /// ينشئ مثيلاً جديداً من BaseRepository.
        /// Initializes a new instance of BaseRepository.
        /// </summary>
        public BaseRepository(YemenBookingDbContext context)
        {
            _context = context;
            _dbSet = context.Set<T>();
        }

        /// <summary>
        /// يجلب السجل حسب المعرف.
        /// Gets the record by identifier.
        /// </summary>
        public async Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[] { id }, cancellationToken);

        /// <summary>
        /// يجلب جميع السجلات.
        /// Gets all records.
        /// </summary>
        public async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default)
            => await _dbSet.ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب السجلات المطابقة للشرط.
        /// Gets records matching the predicate.
        /// </summary>
        public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default)
            => await _dbSet.Where(predicate).ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب أول سجل مطابق أو فارغ.
        /// Gets the first matching record or null.
        /// </summary>
        public async Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(predicate, cancellationToken);

        /// <summary>
        /// يحسب السجلات.
        /// Counts records.
        /// </summary>
        public async Task<int> CountAsync(CancellationToken cancellationToken = default)
            => await _dbSet.CountAsync(cancellationToken);

        /// <summary>
        /// يحسب السجلات.
        /// Counts records.
        /// </summary>
        public async Task<int> CountAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default)
            => await _dbSet.CountAsync(predicate, cancellationToken);

        /// <summary>
        /// يتحقق من وجود سجل مطابق.
        /// Checks whether a matching record exists.
        /// </summary>
        public async Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default)
            => await _dbSet.AnyAsync(predicate, cancellationToken);

        /// <summary>
        /// يضيف الكيان.
        /// Adds the entity.
        /// </summary>
        public async Task<T> AddAsync(T entity, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(entity, cancellationToken);
            // لا نحفظ التغييرات هنا، يجب أن يتم الحفظ من خلال UnitOfWork
            return entity;
        }

        /// <summary>
        /// يضيف مجموعة كيانات.
        /// Adds a range of entities.
        /// </summary>
        public async Task AddRangeAsync(IEnumerable<T> entities, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddRangeAsync(entities, cancellationToken);
            // لا نحفظ التغييرات هنا، يجب أن يتم الحفظ من خلال UnitOfWork
        }

        /// <summary>
        /// يحدّث الكيان.
        /// Updates the entity.
        /// </summary>
        public async Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
        {
            TrackForUpdate(_dbSet, entity);
            // لا نحفظ التغييرات هنا، يجب أن يتم الحفظ من خلال UnitOfWork
        }

        /// <summary>
        /// يحدّث مجموعة كيانات.
        /// Updates a range of entities.
        /// </summary>
        public async Task UpdateRangeAsync(IEnumerable<T> entities, CancellationToken cancellationToken = default)
        {
            foreach (var entity in entities)
            {
                TrackForUpdate(_dbSet, entity);
            }
            // لا نحفظ التغييرات هنا، يجب أن يتم الحفظ من خلال UnitOfWork
        }

        /// <summary>
        /// يحذف الكيان.
        /// Deletes the entity.
        /// </summary>
        public async Task DeleteAsync(T entity, CancellationToken cancellationToken = default)
        {
            _dbSet.Remove(entity);
            // لا نحفظ التغييرات هنا، يجب أن يتم الحفظ من خلال UnitOfWork
        }

        /// <summary>
        /// يجلب صفحة من النتائج.
        /// Gets a paged result set.
        /// </summary>
        public async Task<(IEnumerable<T> Items, int TotalCount)> GetPagedAsync(
            int page,
            int pageSize,
            Expression<Func<T, bool>>? predicate = null,
            Expression<Func<T, object>>? orderBy = null,
            bool ascending = true,
            CancellationToken cancellationToken = default)
        {
            var query = _dbSet.AsQueryable();
            if (predicate != null) query = query.Where(predicate);
            var total = await query.CountAsync(cancellationToken);

            bool clientSideOrdered = false;
            List<T>? clientSideItems = null;

            if (orderBy != null)
            {
                // if (_context.Database.IsSqlite())
                if (false) // SQLite-only path disabled after switching to SQL Server
                {
                    Expression body = orderBy.Body;
                    while (body is UnaryExpression ue && (ue.NodeType == ExpressionType.Convert || ue.NodeType == ExpressionType.ConvertChecked))
                        body = ue.Operand;
                    var underlyingType = body.Type;

                    if (underlyingType == typeof(decimal) || underlyingType == typeof(decimal?))
                    {
                        try
                        {
                            if (underlyingType == typeof(decimal?))
                                body = Expression.Coalesce(body, Expression.Constant(0m));
                            var converted = Expression.Convert(body, typeof(double));
                            var param = orderBy.Parameters[0];
                            var doubleLambda = Expression.Lambda<Func<T, double>>(converted, param);
                            query = ascending ? query.OrderBy(doubleLambda) : query.OrderByDescending(doubleLambda);
                        }
                        catch (NotSupportedException)
                        {
                            // فشل الترجمة => ترتيب على العميل
                            clientSideItems = await query.ToListAsync(cancellationToken);
                            clientSideItems = ascending
                                ? clientSideItems.OrderBy(orderBy.Compile()).ToList()
                                : clientSideItems.OrderByDescending(orderBy.Compile()).ToList();
                            clientSideOrdered = true;
                        }
                        catch (Exception)
                        {
                            clientSideItems = await query.ToListAsync(cancellationToken);
                            clientSideItems = ascending
                                ? clientSideItems.OrderBy(orderBy.Compile()).ToList()
                                : clientSideItems.OrderByDescending(orderBy.Compile()).ToList();
                            clientSideOrdered = true;
                        }
                    }
                    else
                    {
                        query = ascending ? query.OrderBy(orderBy) : query.OrderByDescending(orderBy);
                    }
                }
                else
                {
                    query = ascending ? query.OrderBy(orderBy) : query.OrderByDescending(orderBy);
                }
            }

            if (clientSideOrdered && clientSideItems != null)
            {
                var pagedClient = clientSideItems.Skip((page - 1) * pageSize).Take(pageSize).ToList();
                return (pagedClient, total);
            }

            var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(cancellationToken);
            return (items, total);
        }

        /// <summary>
        /// يجلب صفحة من النتائج وفق المواصفة.
        /// Gets a paged result set using a specification.
        /// </summary>
        public async Task<(IEnumerable<T> Items, int TotalCount)> GetPagedWithSpecificationAsync(
            ISpecification<T> specification,
            CancellationToken cancellationToken = default)
        {
            var query = ApplySpecification(specification);
            var total = await query.CountAsync(cancellationToken);
            var items = await query.Skip(specification.Skip).Take(specification.Take).ToListAsync(cancellationToken);
            return (items, total);
        }

        /// <summary>
        /// يحفظ التغييرات.
        /// Saves changes.
        /// </summary>
        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => await _context.SaveChangesAsync(cancellationToken);

        /// <summary>
        /// يعيد مصدر الاستعلام الفعّال.
        /// Returns the active queryable source.
        /// </summary>
        public IQueryable<T> GetQueryable()
        {
            return _dbSet.AsQueryable();
        }

        /// <summary>
        /// يهيئ الكيان للتحديث مع الحفاظ على حالة Added للكيانات الجديدة داخل نفس دورة العمل.
        /// Prepares an entity for update while preserving Added state for newly-created tracked entities.
        /// </summary>
        protected TEntity TrackForUpdate<TEntity>(DbSet<TEntity> dbSet, TEntity entity) where TEntity : class
        {
            var entry = _context.Entry(entity);

            if (entry.State == EntityState.Detached)
            {
                var entityType = _context.Model.FindEntityType(typeof(TEntity));
                var primaryKey = entityType?.FindPrimaryKey();
                var keyProperties = primaryKey?.Properties;

                var localTracked = dbSet.Local.FirstOrDefault(local =>
                {
                    if (ReferenceEquals(local, entity))
                    {
                        return true;
                    }

                    if (keyProperties == null || keyProperties.Count == 0)
                    {
                        return false;
                    }

                    var localEntry = _context.Entry(local);
                    return keyProperties.All(key =>
                    {
                        var incomingValue = entry.Property(key.Name).CurrentValue;
                        var localValue = localEntry.Property(key.Name).CurrentValue;
                        return Equals(incomingValue, localValue);
                    });
                });

                if (localTracked != null && !ReferenceEquals(localTracked, entity))
                {
                    _context.Entry(localTracked).CurrentValues.SetValues(entity);
                    entity = localTracked;
                    entry = _context.Entry(entity);
                }
                else
                {
                    dbSet.Attach(entity);
                    entry = _context.Entry(entity);
                }
            }

            if (entry.State != EntityState.Added)
            {
                entry.State = EntityState.Modified;
            }

            return entity;
        }

        private IQueryable<T> ApplySpecification(ISpecification<T> spec, bool forCount = false)
        {
            var query = _dbSet.AsQueryable();
            if (spec.IsAsNoTracking) query = query.AsNoTracking();
            if (spec.IsSplitQuery) query = query.AsSplitQuery();
            if (spec.Criteria != null) query = query.Where(spec.Criteria);
            foreach (var include in spec.Includes) query = query.Include(include);
            foreach (var includeStr in spec.IncludeStrings) query = query.Include(includeStr);
            if (!forCount)
            {
                if (spec.OrderBy != null) query = query.OrderBy(spec.OrderBy);
                else if (spec.OrderByDescending != null) query = query.OrderByDescending(spec.OrderByDescending);
                if (spec.IsPagingEnabled) query = query.Skip(spec.Skip).Take(spec.Take);
            }
            return query;
        }
    }
}
