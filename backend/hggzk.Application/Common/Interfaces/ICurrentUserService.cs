using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Common.Interfaces;

/// <summary>
/// Contract for accessing identity, authorization, property, and timezone context for the current user.
/// عقد للوصول إلى معلومات الهوية والتفويض والسياق العقاري والزمني للمستخدم الحالي.
/// </summary>
public interface ICurrentUserService
{
    /// <summary>
    /// Identifier of the current user.
    /// معرف المستخدم الحالي.
    /// </summary>
    Guid UserId { get; }

    /// <summary>
    /// Username of the current user.
    /// اسم المستخدم الحالي.
    /// </summary>
    string Username { get; }

    /// <summary>
    /// Effective primary role used for quick authorization decisions inside the application.
    /// الدور الأساسي الفعلي المستخدم في قرارات الوصول السريعة داخل التطبيق.
    /// </summary>
    string Role { get; }

    /// <summary>
    /// High-level unified account category such as admin, owner, staff, or customer.
    /// نوع الحساب الموحّد عالي المستوى مثل مسؤول أو مالك أو موظف أو عميل.
    /// </summary>
    string AccountRole { get; }

    /// <summary>
    /// Permissions granted to the current user.
    /// الأذونات الممنوحة للمستخدم الحالي.
    /// </summary>
    IEnumerable<string> Permissions { get; }

    /// <summary>
    /// Full set of roles assigned to the current user as stored in the system.
    /// جميع الأدوار الممنوحة للمستخدم الحالي كما هي مخزنة في النظام.
    /// </summary>
    IEnumerable<string> UserRoles { get; }

    /// <summary>
    /// Correlation identifier used to relate requests and logs.
    /// معرف التتبع المستخدم لربط الطلبات والسجلات.
    /// </summary>
    string CorrelationId { get; }

    /// <summary>
    /// Property identifier associated with the current user when available.
    /// معرف العقار المرتبط بالمستخدم الحالي إن وجد.
    /// </summary>
    Guid? PropertyId { get; }

    /// <summary>
    /// Property name associated with the current user when available.
    /// اسم العقار المرتبط بالمستخدم الحالي إن وجد.
    /// </summary>
    string? PropertyName { get; }

    /// <summary>
    /// Property currency code associated with the current user's property when available.
    /// رمز العملة المرتبط بعقار المستخدم الحالي إن وجد.
    /// </summary>
    string? PropertyCurrency { get; }

    /// <summary>
    /// Staff identifier associated with the current user when available.
    /// معرف الموظف المرتبط بالمستخدم الحالي إن وجد.
    /// </summary>
    Guid? StaffId { get; }

    /// <summary>
    /// Checks whether the current user is a staff member in the specified property.
    /// يتحقق مما إذا كان المستخدم الحالي موظفًا ضمن عقار محدد.
    /// </summary>
    /// <param name="propertyId">Target property identifier. معرف العقار المستهدف.</param>
    /// <returns>A value indicating staff membership for the property. قيمة تشير إلى انتماء المستخدم طاقميًا للعقار.</returns>
    bool IsStaffInProperty(Guid propertyId);

    /// <summary>
    /// Retrieves the current user entity from the data store.
    /// يجلب كيان المستخدم الحالي من طبقة البيانات.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
    /// <returns>The current user entity. كيان المستخدم الحالي.</returns>
    Task<User> GetCurrentUserAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Checks asynchronously whether the current user has the specified role.
    /// يتحقق بشكل غير متزامن مما إذا كان المستخدم الحالي يمتلك الدور المحدد.
    /// </summary>
    /// <param name="role">Required role name. اسم الدور المطلوب.</param>
    /// <returns>A value indicating whether the role exists. نتيجة التحقق من وجود الدور.</returns>
    Task<bool> IsInRoleAsync(string role);

    /// <summary>
    /// Gets the current user's geolocation and timezone details.
    /// يجلب معلومات الموقع الجغرافي والمنطقة الزمنية للمستخدم الحالي.
    /// </summary>
    /// <returns>User location information. معلومات موقع المستخدم.</returns>
    Task<UserLocationInfo> GetUserLocationAsync();

    /// <summary>
    /// Converts a UTC value to the current user's local time.
    /// يحول توقيت UTC إلى التوقيت المحلي للمستخدم الحالي.
    /// </summary>
    /// <param name="utcDateTime">UTC date and time. التوقيت الموحّد المراد تحويله.</param>
    /// <returns>User-local date and time. التوقيت المحلي للمستخدم.</returns>
    Task<DateTime> ConvertFromUtcToUserLocalAsync(DateTime utcDateTime);

    /// <summary>
    /// Converts a user-local value to UTC.
    /// يحول التوقيت المحلي للمستخدم إلى UTC.
    /// </summary>
    /// <param name="localDateTime">User-local date and time. التوقيت المحلي للمستخدم.</param>
    /// <returns>Date and time converted to UTC. التوقيت بعد تحويله إلى UTC.</returns>
    Task<DateTime> ConvertFromUserLocalToUtcAsync(DateTime localDateTime);

    /// <summary>
    /// Gets the timezone identifier for the current user.
    /// يجلب معرف المنطقة الزمنية للمستخدم الحالي.
    /// </summary>
    /// <returns>Timezone identifier. معرف المنطقة الزمنية.</returns>
    Task<string> GetUserTimeZoneIdAsync();

    /// <summary>
    /// Gets the current UTC offset for the user.
    /// يجلب الإزاحة الزمنية الحالية للمستخدم مقارنةً بـ UTC.
    /// </summary>
    /// <returns>Current UTC offset. الإزاحة الزمنية الحالية.</returns>
    Task<TimeSpan> GetUserTimeZoneOffsetAsync();
}
