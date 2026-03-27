using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع خدمة العقار repository.
/// Property service repository repository interface.
/// </summary>
public interface IPropertyServiceRepository : IRepository<PropertyService>
{
    /// <summary>
    /// ينشئ خدمة العقار.
    /// Creates property service.
    /// </summary>
    Task<PropertyService> CreatePropertyServiceAsync(PropertyService propertyService, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب خدمة العقار حسب المعرّف.
    /// Gets property service by id.
    /// </summary>
    Task<PropertyService?> GetPropertyServiceByIdAsync(Guid propertyServiceId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الخدمة حسب المعرّف.
    /// Gets service by id.
    /// </summary>
    Task<PropertyService?> GetServiceByIdAsync(Guid serviceId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث خدمة العقار.
    /// Updates property service.
    /// </summary>
    Task<PropertyService> UpdatePropertyServiceAsync(PropertyService propertyService, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف خدمة العقار.
    /// Deletes property service.
    /// </summary>
    Task<bool> DeletePropertyServiceAsync(Guid propertyServiceId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب خدمات العقار.
    /// Gets property services.
    /// </summary>
    Task<IEnumerable<PropertyService>> GetPropertyServicesAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الخدمات حسب النوع.
    /// Gets services by type.
    /// </summary>
    Task<IEnumerable<PropertyService>> GetServicesByTypeAsync(string serviceType, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العقار حسب المعرّف.
    /// Gets property by id.
    /// </summary>
    Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ الخدمة has الحجز references.
    /// Performs service has booking references.
    /// </summary>
    Task<bool> ServiceHasBookingReferencesAsync(Guid serviceId, CancellationToken cancellationToken = default);

}
