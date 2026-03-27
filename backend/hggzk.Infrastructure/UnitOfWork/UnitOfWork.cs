using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Interfaces;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.UnitOfWork
{
    /// <summary>
    /// يوفر تنفيذ نمط وحدة العمل لإدارة المستودعات والمعاملات على سياق قاعدة البيانات.
    /// Provides a unit-of-work implementation for managing repositories and transactional operations on the database context.
    /// </summary>
    public class UnitOfWork : IUnitOfWork
    {
        private readonly YemenBookingDbContext _context;

        /// <summary>
        /// يهيئ مثيلاً جديداً من <see cref="UnitOfWork"/>.
        /// Initializes a new instance of the <see cref="UnitOfWork"/> class.
        /// </summary>
        /// <param name="context">سياق قاعدة البيانات المستخدم لتنفيذ العمليات. The database context used to execute operations.</param>
        public UnitOfWork(YemenBookingDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// ينشئ مستودعاً عاماً للنوع المطلوب باستخدام نفس السياق.
        /// Creates a generic repository for the requested entity type using the same context.
        /// </summary>
        /// <typeparam name="T">نوع الكيان المراد الوصول إليه. The entity type handled by the repository.</typeparam>
        /// <returns>مستودع عام مرتبط بالسياق الحالي. A generic repository bound to the current context.</returns>
        public IRepository<T> Repository<T>() where T : class
            => new BaseRepository<T>(_context);

        /// <summary>
        /// يحفظ جميع التغييرات المعلقة في قاعدة البيانات.
        /// Persists all pending changes to the database.
        /// </summary>
        /// <param name="cancellationToken">رمز إلغاء العملية. A token used to cancel the operation.</param>
        /// <returns>عدد السجلات المتأثرة. The number of state entries written to the database.</returns>
        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => await _context.SaveChangesAsync(cancellationToken);

        /// <summary>
        /// ينفذ عملية داخل معاملة مع استراتيجية إعادة المحاولة الخاصة بموفر قاعدة البيانات.
        /// Executes an operation inside a transaction using the provider retry strategy.
        /// </summary>
        /// <typeparam name="T">نوع القيمة المرجعة من العملية. The return type of the operation.</typeparam>
        /// <param name="operation">العملية المطلوب تنفيذها داخل المعاملة. The operation to execute inside the transaction.</param>
        /// <param name="cancellationToken">رمز إلغاء العملية. A token used to cancel the operation.</param>
        /// <returns>القيمة التي ترجعها العملية بعد نجاحها. The value returned by the operation after it succeeds.</returns>
        public async Task<T> ExecuteInTransactionAsync<T>(Func<Task<T>> operation, CancellationToken cancellationToken = default)
        {
            var strategy = _context.Database.CreateExecutionStrategy();

            return await strategy.ExecuteAsync<Func<Task<T>>, T>(
                state: operation,
                operation: async (context, state, ct) =>
                {
                    await using var transaction = await context.Database.BeginTransactionAsync(ct);
                    try
                    {
                        var result = await state();
                        await transaction.CommitAsync(ct);
                        return result;
                    }
                    catch
                    {
                        await transaction.RollbackAsync(ct);
                        throw;
                    }
                },
                verifySucceeded: null,
                cancellationToken: cancellationToken);
        }

        /// <summary>
        /// ينفذ عملية داخل معاملة مع استراتيجية إعادة المحاولة الخاصة بموفر قاعدة البيانات.
        /// Executes an operation inside a transaction using the provider retry strategy.
        /// </summary>
        /// <param name="operation">العملية المطلوب تنفيذها داخل المعاملة. The operation to execute inside the transaction.</param>
        /// <param name="cancellationToken">رمز إلغاء العملية. A token used to cancel the operation.</param>
        /// <returns>مهمة تمثل اكتمال العملية داخل المعاملة. A task representing completion of the transactional operation.</returns>
        public async Task ExecuteInTransactionAsync(Func<Task> operation, CancellationToken cancellationToken = default)
        {
            var strategy = _context.Database.CreateExecutionStrategy();

            await strategy.ExecuteAsync<Func<Task>, bool>(
                state: operation,
                operation: async (context, state, ct) =>
                {
                    await using var transaction = await context.Database.BeginTransactionAsync(ct);
                    try
                    {
                        await state();
                        await transaction.CommitAsync(ct);
                        return true;
                    }
                    catch
                    {
                        await transaction.RollbackAsync(ct);
                        throw;
                    }
                },
                verifySucceeded: null,
                cancellationToken: cancellationToken);
        }

        /// <summary>
        /// يحرر الموارد المرتبطة بسياق قاعدة البيانات.
        /// Releases the resources associated with the database context.
        /// </summary>
        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
