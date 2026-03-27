using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories
{
    /// <summary>
    /// واجهة مستودع العملة الصرف repository.
    /// Currency exchange repository repository interface.
    /// </summary>
    public interface ICurrencyExchangeRepository : IRepository<CurrencyExchangeRate>
    {
        /// <summary>
        /// يجلب سعر الصرف.
        /// Gets exchange rate.
        /// </summary>
        /// <param name="fromCurrency">العملة المصدر</param>
        /// <param name="toCurrency">العملة الهدف</param>
        /// <returns>سعر الصرف</returns>
        Task<CurrencyExchangeRate?> GetExchangeRateAsync(string fromCurrency, string toCurrency);

        /// <summary>
        /// يجلب أحدث الأسعار لـ العملة.
        /// Gets the latest rates for currency.
        /// </summary>
        /// <param name="baseCurrency">العملة الأساسية</param>
        /// <returns>قائمة أسعار الصرف</returns>
        Task<List<CurrencyExchangeRate>> GetLatestRatesForCurrencyAsync(string baseCurrency);

        /// <summary>
        /// يجلب جميع الحالي الأسعار.
        /// Gets all current rates.
        /// </summary>
        /// <returns>قائمة أسعار الصرف</returns>
        Task<List<CurrencyExchangeRate>> GetAllCurrentRatesAsync();

        /// <summary>
        /// يحدّث سعر الصرف.
        /// Updates exchange rate.
        /// </summary>
        /// <param name="fromCurrency">العملة المصدر</param>
        /// <param name="toCurrency">العملة الهدف</param>
        /// <param name="rate">السعر الجديد</param>
        /// <returns>نتيجة العملية</returns>
        Task<bool> UpdateExchangeRateAsync(string fromCurrency, string toCurrency, decimal rate);

        /// <summary>
        /// ينفذ عملية جماعية على التحديث الأسعار.
        /// Performs a bulk operation on update rates.
        /// </summary>
        /// <param name="rates">قائمة أسعار الصرف الجديدة</param>
        /// <returns>نتيجة العملية</returns>
        Task<bool> BulkUpdateRatesAsync(List<CurrencyExchangeRate> rates);

        /// <summary>
        /// يجلب آخر التحديث التاريخ.
        /// Gets last update date.
        /// </summary>
        /// <returns>تاريخ آخر تحديث</returns>
        Task<DateTime?> GetLastUpdateDateAsync();

        /// <summary>
        /// ينفذ are الأسعار expired.
        /// Performs are rates expired.
        /// </summary>
        /// <param name="maxAgeHours">الحد الأقصى للعمر بالساعات</param>
        /// <returns>true إذا كانت منتهية الصلاحية</returns>
        Task<bool> AreRatesExpiredAsync(int maxAgeHours = 24);

        /// <summary>
        /// ينفذ convert amount.
        /// Performs convert amount.
        /// </summary>
        /// <param name="amount">المبلغ الأصلي</param>
        /// <param name="fromCurrency">العملة المصدر</param>
        /// <param name="toCurrency">العملة الهدف</param>
        /// <returns>المبلغ المحول</returns>
        Task<decimal> ConvertAmountAsync(decimal amount, string fromCurrency, string toCurrency);

        /// <summary>
        /// يجلب المدعومة العملات.
        /// Gets supported currencies.
        /// </summary>
        /// <returns>قائمة العملات المدعومة</returns>
        Task<List<string>> GetSupportedCurrenciesAsync();
    }

    /// <summary>
    /// كيان سعر صرف العملة.
    /// Currency exchange rate entity.
    /// </summary>
    public class CurrencyExchangeRate : BaseEntity<Guid>
    {
        /// <summary>
        /// العملة المصدر.
        /// Source currency.
        /// </summary>
        public string FromCurrency { get; set; } = string.Empty;

        /// <summary>
        /// العملة الهدف.
        /// Target currency.
        /// </summary>
        public string ToCurrency { get; set; } = string.Empty;

        /// <summary>
        /// سعر الصرف.
        /// Exchange rate.
        /// </summary>
        public decimal Rate { get; set; }

        /// <summary>
        /// آخر تحديث.
        /// Last updated timestamp.
        /// </summary>
        public DateTime LastUpdated { get; set; }

        /// <summary>
        /// مصدر البيانات.
        /// Data source.
        /// </summary>
        public string Source { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كان هذا السجل نشطًا.
        /// Indicates whether this record is active.
        /// </summary>
        public bool IsActive { get; set; } = true;
    }
}
