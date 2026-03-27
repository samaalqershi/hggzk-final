using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع المستخدم repository.
/// User repository repository interface.
/// </summary>
public interface IUserRepository : IRepository<User>
{
    /// <summary>
    /// ينشئ المستخدم.
    /// Creates user.
    /// </summary>
    Task<User> CreateUserAsync(User user, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم حسب المعرّف.
    /// Gets user by id.
    /// </summary>
    Task<User?> GetUserByIdAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم حسب البريد الإلكتروني.
    /// Gets user by email.
    /// </summary>
    Task<User?> GetUserByEmailAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم حسب social المزوّد المعرّف.
    /// Gets user by social provider id.
    /// </summary>
    Task<User?> GetUserBySocialProviderIdAsync(string provider, string providerUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب رقم الهاتف.
    /// Gets the item by phone.
    /// </summary>
    Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من البريد الإلكتروني exists.
    /// Checks email exists.
    /// </summary>
    Task<bool> CheckEmailExistsAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث المستخدم.
    /// Updates user.
    /// </summary>
    Task<User> UpdateUserAsync(User user, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ deactivate المستخدم.
    /// Performs deactivate user.
    /// </summary>
    Task<bool> DeactivateUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ activate المستخدم.
    /// Performs activate user.
    /// </summary>
    Task<bool> ActivateUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع المستخدمين.
    /// Gets all users.
    /// </summary>
    Task<IEnumerable<User>> GetAllUsersAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// يبحث عن المستخدمين.
    /// Searches users.
    /// </summary>
    Task<IEnumerable<User>> SearchUsersAsync(
        string searchTerm,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المالك حسب المعرّف.
    /// Gets owner by id.
    /// </summary>
    Task<User?> GetOwnerByIdAsync(Guid ownerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم الأدوار.
    /// Gets user roles.
    /// </summary>
    Task<IEnumerable<UserRole>> GetUserRolesAsync(Guid userId, CancellationToken cancellationToken = default);

}
