using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Contracts.Services.Scheduling;
using System.Linq;

namespace YemenBooking.Infrastructure.Services.Search
{
    /// <summary>
    /// يمثل خدمة البحث في طبقة البنية التحتية.
    /// Represents the search service in the infrastructure layer.
    /// </summary>
    public class SearchService : ISearchService
    {
        private readonly ILogger<SearchService> _logger;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IAvailabilityService _availabilityService;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة البحث.
        /// Creates a new instance of the search service.
        /// </summary>
        /// <param name="logger">The logger used for diagnostics. المسجل المستخدم للتشخيص.</param>
        /// <param name="propertyRepository">The property repository. مستودع العقارات.</param>
        /// <param name="availabilityService">The availability service. خدمة التوفر.</param>
        public SearchService(
            ILogger<SearchService> logger,
            IPropertyRepository propertyRepository,
            IAvailabilityService availabilityService)
        {
            _logger = logger;
            _propertyRepository = propertyRepository;
            _availabilityService = availabilityService;
        }

        /// <summary>
        /// يبحث عن العقارات باستخدام نص البحث والمرشحات الاختيارية.
        /// Searches properties using the text query and optional filters.
        /// </summary>
        /// <param name="searchTerm">The search text. نص البحث.</param>
        /// <param name="checkIn">The optional check-in date. تاريخ الوصول الاختياري.</param>
        /// <param name="checkOut">The optional check-out date. تاريخ المغادرة الاختياري.</param>
        /// <param name="guestCount">The optional guest count. عدد الضيوف الاختياري.</param>
        /// <param name="propertyTypeId">The optional property type identifier. معرف نوع العقار الاختياري.</param>
        /// <param name="minPrice">The minimum price filter. الحد الأدنى للسعر.</param>
        /// <param name="maxPrice">The maximum price filter. الحد الأقصى للسعر.</param>
        /// <param name="city">The optional city filter. فلتر المدينة الاختياري.</param>
        /// <param name="latitude">The optional latitude. خط العرض الاختياري.</param>
        /// <param name="longitude">The optional longitude. خط الطول الاختياري.</param>
        /// <param name="radiusKm">The optional search radius in kilometers. نصف قطر البحث بالكيلومترات.</param>
        /// <param name="cancellationToken">The cancellation token. رمز الإلغاء.</param>
        /// <returns>The matching properties. العقارات المطابقة.</returns>
        public async Task<IEnumerable<Property>> SearchPropertiesAsync(
            string searchTerm,
            DateTime? checkIn = null,
            DateTime? checkOut = null,
            int? guestCount = null,
            Guid? propertyTypeId = null,
            decimal? minPrice = null,
            decimal? maxPrice = null,
            string? city = null,
            double? latitude = null,
            double? longitude = null,
            double? radiusKm = null,
            CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("البحث عن الكيانات باستخدام: {SearchTerm}", searchTerm);
            IEnumerable<Property> properties;
            if (latitude.HasValue && longitude.HasValue && radiusKm.HasValue)
            {
                properties = await _propertyRepository.GetPropertiesNearLocationAsync(latitude.Value, longitude.Value, radiusKm.Value, cancellationToken);
            }
            else
            {
                properties = await _propertyRepository.SearchPropertiesAsync(searchTerm, cancellationToken);
            }
            if (!string.IsNullOrEmpty(city))
                properties = properties.Where(p => p.City.Equals(city, StringComparison.OrdinalIgnoreCase));
            if (propertyTypeId.HasValue)
                properties = properties.Where(p => p.TypeId == propertyTypeId.Value);
            // Filter by availability.
            // التصفية حسب التوفر. / Filter by availability.
            if (checkIn.HasValue && checkOut.HasValue)
            {
                var results = new List<Property>();
                foreach (var prop in properties)
                {
                    var availableUnits = await _availabilityService.GetAvailableUnitsInPropertyAsync(prop.Id, checkIn.Value, checkOut.Value, guestCount ?? 1, cancellationToken);
                    if (availableUnits.Any())
                        results.Add(prop);
                }
                properties = results;
            }
            // Price filtering is intentionally deferred here.
            // يتم تأجيل تصفية السعر هنا بشكل مقصود. / Price filtering is intentionally deferred here.
            // Note: BasePrice was removed, and DailySchedules should be used instead.
            // if (minPrice.HasValue || maxPrice.HasValue)
            // {
            //     properties = properties.Where(p => p.Units.Any(u => ...));
            // }
            return properties;
        }

    }
}
