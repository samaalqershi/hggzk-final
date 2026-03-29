namespace YemenBooking.Api.Infrastructure.Localization;

/// <summary>
/// Translates backend messages based on the current request culture.
/// يترجم رسائل الخادم بحسب ثقافة الطلب الحالية.
/// </summary>
public interface IBackendTextLocalizer
{
    /// <summary>
    /// Gets the normalized current language code.
    /// يجلب رمز اللغة الحالي بعد التطبيع.
    /// </summary>
    string CurrentLanguage { get; }

    /// <summary>
    /// Translates a single backend message or resource key.
    /// يترجم رسالة خادمية واحدة أو مفتاح مورد.
    /// </summary>
    string Translate(string? input);

    /// <summary>
    /// Translates a list of backend messages.
    /// يترجم مجموعة رسائل خادمية.
    /// </summary>
    IReadOnlyList<string> TranslateMany(IEnumerable<string>? values);
}
