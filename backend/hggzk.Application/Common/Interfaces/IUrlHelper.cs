namespace YemenBooking.Application.Common.Interfaces;

/// <summary>
/// Defines URL conversion helpers between internal storage paths and public absolute URLs.
/// يعرّف أدوات تحويل الروابط بين مسارات التخزين الداخلية والروابط العامة المطلقة.
/// </summary>
public interface IUrlHelper
{
    /// <summary>
    /// Converts a stored relative path into an absolute URL suitable for external clients.
    /// يحوّل مسارًا نسبيًا مخزنًا في النظام إلى رابط مطلق صالح للاستخدام الخارجي.
    /// </summary>
    /// <param name="relativePath">Relative path such as <c>/uploads/images/profile/abc.jpg</c>. المسار النسبي.</param>
    /// <returns>Absolute URL such as <c>https://example.com/uploads/images/profile/abc.jpg</c>. الرابط المطلق الناتج.</returns>
    string ToAbsoluteUrl(string? relativePath);

    /// <summary>
    /// Converts an absolute URL into a storage-friendly relative path.
    /// يحوّل رابطًا مطلقًا إلى مسار نسبي داخلي مناسب للتخزين.
    /// </summary>
    /// <param name="absoluteUrl">Absolute URL. الرابط المطلق.</param>
    /// <returns>Resulting relative path. المسار النسبي الناتج.</returns>
    string ToRelativePath(string? absoluteUrl);

    /// <summary>
    /// Gets the current server base URL.
    /// يجلب الرابط الأساسي الحالي للخادم.
    /// </summary>
    /// <returns>Base URL. الرابط الأساسي.</returns>
    string GetBaseUrl();
}
