using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الأسئلة الشائعة repository.
/// Faq repository repository interface.
/// </summary>
public interface IFAQRepository
{
    /// <summary>
    /// يجلب النشط fa qs.
    /// Gets active fa qs.
    /// </summary>
    /// <param name="language">رمز اللغة المطلوب. Requested language code.</param>
    /// <param name="category">اسم الفئة عند الحاجة. Optional category name.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>الأسئلة الشائعة المطابقة. Matching FAQ items.</returns>
    Task<IEnumerable<FAQ>> GetActiveFAQsAsync(
        string language = "ar",
        string? category = null,
        CancellationToken cancellationToken = default);
}
