using System;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Core.Interfaces;

/// <summary>
/// واجهة وحدة العمل لإدارة المستودعات وحفظ التغييرات.
/// Unit-of-work contract for repository access and persistence.
/// </summary>
public interface IUnitOfWork : IDisposable
{
    /// <summary>
    /// يعيد مستودعًا عامًا لنوع كيان محدد.
    /// Returns a generic repository for a specific entity type.
    /// </summary>
    /// <typeparam name="T">نوع الكيان. Entity type.</typeparam>
    /// <returns>مستودع عام مرتبط بسياق العمل الحالي. Generic repository bound to the current unit of work.</returns>
    IRepository<T> Repository<T>() where T : class;

    /// <summary>
    /// يحفظ جميع التغييرات المعلقة.
    /// Persists all pending changes.
    /// </summary>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>عدد السجلات المتأثرة. Number of affected rows.</returns>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ عملية مرجعة داخل معاملة آمنة مع استراتيجية إعادة المحاولة.
    /// Executes a value-returning operation inside a retry-safe transaction.
    /// </summary>
    /// <typeparam name="T">نوع القيمة المرجعة. Return type.</typeparam>
    /// <param name="operation">العملية المطلوب تنفيذها. Operation to execute.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة العملية. Operation result.</returns>
    Task<T> ExecuteInTransactionAsync<T>(Func<Task<T>> operation, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ عملية غير مرجعة داخل معاملة آمنة مع استراتيجية إعادة المحاولة.
    /// Executes a non-returning operation inside a retry-safe transaction.
    /// </summary>
    /// <param name="operation">العملية المطلوب تنفيذها. Operation to execute.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>مهمة تمثل اكتمال التنفيذ. Task representing operation completion.</returns>
    Task ExecuteInTransactionAsync(Func<Task> operation, CancellationToken cancellationToken = default);
}
