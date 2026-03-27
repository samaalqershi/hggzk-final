using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations for property policies.
    /// يوفّر عمليات الحفظ الخاصة بسياسات العقار.
    /// </summary>
    public class PolicyRepository : BaseRepository<PropertyPolicy>, IPolicyRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من PolicyRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of PolicyRepository with the shared database context.
        /// </summary>
        public PolicyRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new property policy and stages it for persistence.
    /// ينشئ سياسة عقار جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<PropertyPolicy> CreatePropertyPolicyAsync(PropertyPolicy propertyPolicy, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyPolicy, cancellationToken);
        return propertyPolicy;
    }

        /// <summary>
        /// Retrieves the specified property policy by its identifier.
        /// يسترجع سياسة العقار المحددة بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyPolicy?> GetPolicyByIdAsync(Guid policyId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{policyId}, cancellationToken);

    /// <summary>
    /// Updates an existing property policy.
    /// يحدّث سياسة العقار الموجودة.
    /// </summary>
    public async Task<PropertyPolicy> UpdatePropertyPolicyAsync(PropertyPolicy propertyPolicy, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, propertyPolicy);
    }

    /// <summary>
    /// Deletes the specified property policy.
    /// يحذف سياسة العقار المحددة.
    /// </summary>
    public async Task<bool> DeletePolicyAsync(Guid policyId, CancellationToken cancellationToken = default)
    {
        var pol = await GetPolicyByIdAsync(policyId, cancellationToken);
        if (pol == null) return false;
        _dbSet.Remove(pol);
        return true;
    }

        /// <summary>
        /// Retrieves all policies for the specified property.
        /// يسترجع جميع سياسات العقار المحدد.
        /// </summary>
        public async Task<IEnumerable<PropertyPolicy>> GetPropertyPoliciesAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(p => p.PropertyId == propertyId).ToListAsync(cancellationToken);

    }
} 
