using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Infrastructure.Services.Payments
{
    /// <summary>
    /// يمثل خدمة جلب أسعار صرف العملات من المستودع الداخلي.
    /// Represents a service for retrieving exchange rates from the internal repository.
    /// </summary>
    public class CurrencyExchangeService : ICurrencyExchangeService
    {
        private readonly ICurrencyExchangeRepository _currencyExchangeRepository;
        private readonly ILogger<CurrencyExchangeService> _logger;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة أسعار الصرف.
        /// Creates a new instance of the exchange-rate service.
        /// </summary>
        public CurrencyExchangeService(
            ICurrencyExchangeRepository currencyExchangeRepository,
            ILogger<CurrencyExchangeService> logger)
        {
            _currencyExchangeRepository = currencyExchangeRepository;
            _logger = logger;
        }

        /// <summary>
        /// يعيد سعر الصرف بين عملتين إذا كان متاحًا.
        /// Returns the exchange rate between two currencies when available.
        /// </summary>
        public async Task<decimal?> GetExchangeRateAsync(string fromCurrency, string toCurrency, CancellationToken cancellationToken = default)
        {
            var exchangeRate = await _currencyExchangeRepository.GetExchangeRateAsync(fromCurrency, toCurrency);
            return exchangeRate?.Rate;
        }

        /// <summary>
        /// يعيد جميع أسعار الصرف المرتبطة بالعملة الأساسية.
        /// Returns all exchange rates for the base currency.
        /// </summary>
        public async Task<Dictionary<string, decimal>> GetAllExchangeRatesAsync(string baseCurrency, CancellationToken cancellationToken = default)
        {
            var rates = await _currencyExchangeRepository.GetLatestRatesForCurrencyAsync(baseCurrency);
            return rates.ToDictionary(rate => rate.ToCurrency, rate => rate.Rate, StringComparer.OrdinalIgnoreCase);
        }

        /// <summary>
        /// يتحقق من صحة رمز العملة وفق الطول القياسي.
        /// Validates a currency code against the standard length.
        /// </summary>
        public bool IsValidCurrencyCode(string currencyCode)
        {
            // Simple validation: currency code must be exactly 3 letters
            if (string.IsNullOrWhiteSpace(currencyCode) || currencyCode.Length != 3)
                return false;
            return true;
        }

        /// <summary>
        /// يعيد قائمة العملات المدعومة من المستودع.
        /// Returns the list of supported currencies from the repository.
        /// </summary>
        public async Task<IEnumerable<string>> GetSupportedCurrenciesAsync()
        {
            return await _currencyExchangeRepository.GetSupportedCurrenciesAsync();
        }
    }
}
