using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الموظف repository.
/// Staff repository repository interface.
/// </summary>
public interface IStaffRepository : IRepository<Staff>
{
    /// <summary>
    /// يضيف الموظف.
    /// Adds staff.
    /// </summary>
    Task<Staff> AddStaffAsync(Staff staff, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الموظف حسب المعرّف.
    /// Gets staff by id.
    /// </summary>
    Task<Staff?> GetStaffByIdAsync(Guid staffId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الموظف.
    /// Updates staff.
    /// </summary>
    Task<Staff> UpdateStaffAsync(Staff staff, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الموظف.
    /// Removes staff.
    /// </summary>
    Task<bool> RemoveStaffAsync(Guid staffId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الموظف حسب العقار.
    /// Gets staff by property.
    /// </summary>
    Task<IEnumerable<Staff>> GetStaffByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الموظف حسب المستخدم.
    /// Gets staff by user.
    /// </summary>
    Task<Staff?> GetStaffByUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الموظف حسب position.
    /// Gets staff by position.
    /// </summary>
    Task<IEnumerable<Staff>> GetStaffByPositionAsync(string position, Guid? propertyId = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم حسب المعرّف.
    /// Gets user by id.
    /// </summary>
    Task<User?> GetUserByIdAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العقار حسب المعرّف.
    /// Gets property by id.
    /// </summary>
    Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

}
