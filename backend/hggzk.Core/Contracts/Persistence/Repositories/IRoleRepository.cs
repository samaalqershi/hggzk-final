using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الدور repository.
/// Role repository repository interface.
/// </summary>
public interface IRoleRepository : IRepository<Role>
{
    /// <summary>
    /// يجلب الدور حسب المعرّف.
    /// Gets role by id.
    /// </summary>
    Task<Role?> GetRoleByIdAsync(Guid roleId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع الأدوار.
    /// Gets all roles.
    /// </summary>
    Task<IEnumerable<Role>> GetAllRolesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// ينشئ الدور.
    /// Creates role.
    /// </summary>
    Task<Role> CreateRoleAsync(Role role, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الدور.
    /// Updates role.
    /// </summary>
    Task<Role> UpdateRoleAsync(Role role, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف الدور.
    /// Deletes role.
    /// </summary>
    Task<bool> DeleteRoleAsync(Guid roleId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يربط الدور إلى المستخدم.
    /// Assigns role to user.
    /// </summary>
    Task<bool> AssignRoleToUserAsync(Guid userId, Guid roleId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الدور من المستخدم.
    /// Removes role from user.
    /// </summary>
    Task<bool> RemoveRoleFromUserAsync(Guid userId, Guid roleId, CancellationToken cancellationToken = default);

}
