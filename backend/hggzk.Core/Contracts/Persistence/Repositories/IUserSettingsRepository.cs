using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع المستخدم الإعدادات repository.
/// User settings repository repository interface.
/// </summary>
public interface IUserSettingsRepository
{
    /// <summary>
    /// يجلب العنصر حسب المستخدم المعرّف.
    /// Gets the item by user id.
    /// </summary>
    /// <param name="userId">معرف المستخدم</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>إعدادات المستخدم</returns>
    Task<UserSettings?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينشئ .
    /// Creates .
    /// </summary>
    /// <param name="userSettings">إعدادات المستخدم</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>إعدادات المستخدم المنشأة</returns>
    Task<UserSettings> CreateAsync(UserSettings userSettings, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث .
    /// Updates .
    /// </summary>
    /// <param name="userSettings">إعدادات المستخدم</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>إعدادات المستخدم المحدثة</returns>
    Task<UserSettings> UpdateAsync(UserSettings userSettings, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    /// <param name="cancellationToken">رمز الإلغاء / Cancellation token.</param>
    /// <returns>عدد السجلات المتأثرة / Number of affected records.</returns>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);

}
