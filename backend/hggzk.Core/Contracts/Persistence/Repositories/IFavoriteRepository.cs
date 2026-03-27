using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع المفضلة repository.
/// Favorite repository repository interface.
/// </summary>
public interface IFavoriteRepository
{
    /// <summary>
    /// يجلب العنصر حسب المستخدم المعرّف.
    /// Gets the item by user id.
    /// </summary>
    Task<IEnumerable<Favorite>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على مفضلات المستخدم مع التصفح
    /// Get user favorites with pagination
    /// </summary>
    /// <param name="userId">معرف المستخدم</param>
    /// <param name="pageNumber">رقم الصفحة</param>
    /// <param name="pageSize">حجم الصفحة</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>قائمة المفضلات</returns>
    Task<(IEnumerable<Favorite> Items, int TotalCount)> GetUserFavoritesAsync(
        Guid userId, 
        int pageNumber = 1, 
        int pageSize = 10, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by id.
    /// </summary>
    /// <param name="id">معرف المفضلة</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>المفضلة</returns>
    Task<Favorite?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق مما إذا كان  موجودًا.
    /// Checks whether  exists.
    /// </summary>
    /// <param name="userId">معرف المستخدم</param>
    /// <param name="propertyId">معرف العقار</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>true إذا كانت المفضلة موجودة</returns>
    Task<bool> ExistsAsync(Guid userId, Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يضيف .
    /// Adds .
    /// </summary>
    /// <param name="favorite">المفضلة</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>المفضلة المضافة</returns>
    Task<Favorite> AddAsync(Favorite favorite, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينشئ المفضلة.
    /// Creates favorite.
    /// </summary>
    /// <param name="favorite">المفضلة المراد إنشاؤها</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>المفضلة التي تم حفظها</returns>
    Task<Favorite> CreateFavoriteAsync(Favorite favorite, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف .
    /// Deletes .
    /// </summary>
    /// <param name="id">معرف المفضلة</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>نتيجة الحذف</returns>
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف حسب المستخدم and العقار.
    /// Deletes by user and property.
    /// </summary>
    /// <param name="userId">معرف المستخدم</param>
    /// <param name="propertyId">معرف العقار</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>نتيجة الحذف</returns>
    Task<bool> DeleteByUserAndPropertyAsync(Guid userId, Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
