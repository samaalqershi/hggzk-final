using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع المستند القانوني repository.
/// Legal document repository repository interface.
/// </summary>
public interface ILegalDocumentRepository
{
    /// <summary>
    /// يجلب العنصر حسب النوع and اللغة.
    /// Gets the item by type and language.
    /// </summary>
    /// <param name="type">نوع المستند المطلوب. Requested document type.</param>
    /// <param name="language">رمز اللغة المطلوب. Requested language code.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>المستند المطابق أو `null`. Matching document or `null`.</returns>
    Task<LegalDocument?> GetByTypeAndLanguageAsync(
        LegalDocumentType type,
        string language,
        CancellationToken cancellationToken = default);
}
