using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties;

/// <summary>
/// Provides persistence operations for property type-amenity links.
/// يوفّر عمليات الحفظ الخاصة بروابط نوع العقار بالمرافق.
/// </summary>
public class PropertyTypeAmenityRepository : BaseRepository<PropertyTypeAmenity>, IPropertyTypeAmenityRepository
{
    /// <summary>
    /// يهيئ مثيلاً جديدًا من PropertyTypeAmenityRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of PropertyTypeAmenityRepository with the shared database context.
    /// </summary>
    public PropertyTypeAmenityRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// Creates a property type-amenity link and stages it for persistence.
    /// ينشئ ربطًا بين نوع العقار والمرفق ويجهزه للحفظ.
    /// </summary>
    public async Task<PropertyTypeAmenity> CreatePropertyTypeAmenityAsync(PropertyTypeAmenity propertyTypeAmenity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyTypeAmenity, cancellationToken);
        return propertyTypeAmenity;
    }
}
