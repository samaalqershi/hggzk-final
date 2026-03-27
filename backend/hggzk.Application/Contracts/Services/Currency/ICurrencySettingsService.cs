using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Contracts.Services.Currency
{
    /// <summary>
    /// خدمة لإدارة إعدادات العملات.
    /// Service for managing currency settings.
    /// </summary>
    public interface ICurrencySettingsService
    {
        /// <summary>
        /// يجلب قائمة العملات.
        /// Gets the list of currencies.
        /// </summary>
        Task<List<CurrencyDto>> GetCurrenciesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// يحفظ قائمة العملات أو يحدّثها.
        /// Saves or updates the currency list.
        /// </summary>
        Task SaveCurrenciesAsync(List<CurrencyDto> currencies, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحذف العملة نهائيًا بعد التحقق من عدم وجود مراجع مرتبطة بها.
        /// Permanently deletes a currency after verifying there are no related references.
        /// </summary>
        Task DeleteCurrencyAsync(string code, CancellationToken cancellationToken = default);
    }
}
