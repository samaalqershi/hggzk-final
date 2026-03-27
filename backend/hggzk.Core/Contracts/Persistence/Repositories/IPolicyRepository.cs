using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع السياسة repository.
/// Policy repository repository interface.
/// </summary>
public interface IPolicyRepository : IRepository<PropertyPolicy>
{
    /// <summary>
    /// ينشئ سياسة العقار.
    /// Creates property policy.
    /// </summary>
    Task<PropertyPolicy> CreatePropertyPolicyAsync(PropertyPolicy propertyPolicy, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب السياسة حسب المعرّف.
    /// Gets policy by id.
    /// </summary>
    Task<PropertyPolicy?> GetPolicyByIdAsync(Guid policyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث سياسة العقار.
    /// Updates property policy.
    /// </summary>
    Task<PropertyPolicy> UpdatePropertyPolicyAsync(PropertyPolicy propertyPolicy, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف السياسة.
    /// Deletes policy.
    /// </summary>
    Task<bool> DeletePolicyAsync(Guid policyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العقار السياسات.
    /// Gets property policies.
    /// </summary>
    Task<IEnumerable<PropertyPolicy>> GetPropertyPoliciesAsync(Guid propertyId, CancellationToken cancellationToken = default);

}
