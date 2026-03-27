using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Contracts.Services.Configuration
{
    /// <summary>
    /// خدمة لإدارة إعدادات المدن.
    /// Service for managing city settings.
    /// </summary>
    public interface ICitySettingsService
    {
        /// <summary>
        /// يجلب قائمة المدن.
        /// Gets the list of cities.
        /// </summary>
        Task<List<CityDto>> GetCitiesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// يحفظ قائمة المدن أو يحدّثها.
        /// Saves or updates the city list.
        /// </summary>
        Task SaveCitiesAsync(List<CityDto> cities, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحذف مدينة بعد التحقق من عدم وجود كيانات مرتبطة بها.
        /// Deletes a city after verifying there are no dependent entities.
        /// </summary>
        Task DeleteCityAsync(string name, CancellationToken cancellationToken = default);
    }
} 
