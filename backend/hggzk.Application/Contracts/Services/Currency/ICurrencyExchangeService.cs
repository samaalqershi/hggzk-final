using System.Collections.Generic;

namespace YemenBooking.Application.Contracts.Services.Currency;

/// <summary>
/// واجهة خدمة أسعار صرف العملات الخارجية. External currency exchange service interface.
/// </summary>
public interface ICurrencyExchangeService
{
    /// <summary>
    /// الحصول على سعر الصرف من خدمة خارجية. Get exchange rate from external service.
    /// </summary>
    /// <param name="fromCurrency">العملة المصدر. Source currency.</param>
    /// <param name="toCurrency">العملة الهدف. Target currency.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>سعر الصرف. Exchange rate.</returns>
    Task<decimal?> GetExchangeRateAsync(string fromCurrency, string toCurrency, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على جميع أسعار الصرف لعملة معينة من خدمة خارجية. Get all exchange rates for a currency from external service.
    /// </summary>
    /// <param name="baseCurrency">العملة الأساسية. Base currency.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>قاموس أسعار الصرف. Exchange rate dictionary.</returns>
    Task<Dictionary<string, decimal>> GetAllExchangeRatesAsync(string baseCurrency, CancellationToken cancellationToken = default);

    /// <summary>
    /// التحقق من صحة رمز العملة. Validate currency code.
    /// </summary>
    /// <param name="currencyCode">رمز العملة. Currency code.</param>
    /// <returns>true إذا كان رمز العملة صحيح. true when the currency code is valid.</returns>
    bool IsValidCurrencyCode(string currencyCode);

    /// <summary>
    /// الحصول على قائمة العملات المدعومة. Get list of supported currencies.
    /// </summary>
    /// <returns>قائمة رموز العملات المدعومة. Supported currency codes.</returns>
    Task<IEnumerable<string>> GetSupportedCurrenciesAsync();
}
