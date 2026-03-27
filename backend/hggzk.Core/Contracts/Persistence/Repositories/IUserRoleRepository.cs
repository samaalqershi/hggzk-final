using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع المستخدم الدور repository.
/// User role repository repository interface.
/// </summary>
public interface IUserRoleRepository : IRepository<UserRole>
{
    /// <summary>
    /// يجلب المستخدم الأدوار.
    /// Gets user roles.
    /// </summary>
    Task<IEnumerable<UserRole>> GetUserRolesAsync(Guid userId, CancellationToken cancellationToken = default);

}
