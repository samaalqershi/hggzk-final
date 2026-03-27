using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع العقار repository.
/// Property repository repository interface.
/// </summary>
public interface IPropertyRepository : IRepository<Property>
{
    /// <summary>
    /// ينشئ عقارًا جديدًا ويعيد الكيان بعد تهيئته للحفظ.
    /// Creates a new property and returns the entity prepared for persistence.
    /// </summary>
    Task<Property> CreatePropertyAsync(Property property, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العقار حسب المعرّف.
    /// Gets property by id.
    /// </summary>
    Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العقار مع الوحدات.
    /// Gets property with units.
    /// </summary>
    Task<Property?> GetPropertyWithUnitsAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحدّث بيانات عقار موجود ويعيد الكيان بعد تطبيق التغييرات.
    /// Updates an existing property and returns the entity after applying the changes.
    /// </summary>
    Task<Property> UpdatePropertyAsync(Property property, CancellationToken cancellationToken = default);
    /// <summary>
    /// يعتمد العقار ويحوّله إلى حالة الموافقة.
    /// Approves the property and moves it to the approved state.
    /// </summary>
    Task<bool> ApprovePropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يرفض العقار مع تسجيل سبب الرفض.
    /// Rejects the property while recording the rejection reason.
    /// </summary>
    Task<bool> RejectPropertyAsync(Guid propertyId, string reason, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحذف العقار من السياق مع تطبيق سياسات الحذف المعتمدة.
    /// Deletes the property from the data context according to the configured deletion rules.
    /// </summary>
    Task<bool> DeletePropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العقارات حسب المالك.
    /// Gets properties by owner.
    /// </summary>
    Task<IEnumerable<Property>> GetPropertiesByOwnerAsync(Guid ownerId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يبحث عن العقارات.
    /// Searches properties.
    /// </summary>
    Task<IEnumerable<Property>> SearchPropertiesAsync(string searchTerm, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب البحث الاقتراحات.
    /// Gets search suggestions.
    /// </summary>
    Task<IReadOnlyList<string>> GetSearchSuggestionsAsync(string query, int limit = 10, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العقارات near location.
    /// Gets properties near location.
    /// </summary>
    Task<IEnumerable<Property>> GetPropertiesNearLocationAsync(double latitude, double longitude, double radiusKm, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب المالك حسب المعرّف.
    /// Gets owner by id.
    /// </summary>
    Task<User?> GetOwnerByIdAsync(Guid ownerId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب نوع العقار حسب المعرّف.
    /// Gets property type by id.
    /// </summary>
    Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يتحقق من النشط الحجوزات.
    /// Checks active bookings.
    /// </summary>
    Task<bool> CheckActiveBookingsAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العقار الحجز count.
    /// Gets property booking count.
    /// </summary>
    Task<int> GetPropertyBookingCountAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب الوحدات count.
    /// Gets units count.
    /// </summary>
    Task<int> GetUnitsCountAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب الخدمات count.
    /// Gets services count.
    /// </summary>
    Task<int> GetServicesCountAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب المزايا count.
    /// Gets amenities count.
    /// </summary>
    Task<int> GetAmenitiesCountAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب المدفوعات count.
    /// Gets payments count.
    /// </summary>
    Task<int> GetPaymentsCountAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب مزايا العقار.
    /// Gets property amenities.
    /// </summary>
    Task<IEnumerable<PropertyAmenity>> GetPropertyAmenitiesAsync(Guid propertyId, CancellationToken cancellationToken = default);
    /// <summary>
    /// ينفذ calculate performance metrics.
    /// Performs calculate performance metrics.
    /// </summary>
    Task<object> CalculatePerformanceMetricsAsync(Guid propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب cancellation السياسة.
    /// Gets cancellation policy.
    /// </summary>
    Task<PropertyPolicy?> GetCancellationPolicyAsync(Guid propertyId, CancellationToken cancellationToken = default);
}
