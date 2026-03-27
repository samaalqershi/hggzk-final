using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Services.Payments
{
    /// <summary>
    /// يمثل خدمة تضمن وجود العملة داخل قاعدة البيانات.
    /// Represents a service that ensures a currency exists in the database.
    /// </summary>
    public class CurrencyEnsureService : ICurrencyEnsureService
    {
        private readonly YemenBookingDbContext _db;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة ضمان وجود العملة.
        /// Creates a new instance of the currency ensure service.
        /// </summary>
        public CurrencyEnsureService(YemenBookingDbContext db)
        {
            _db = db;
        }

        /// <summary>
        /// يضمن وجود العملة المطلوبة ويضيف سجلًا افتراضيًا عند الحاجة.
        /// Ensures the requested currency exists and creates a default record when needed.
        /// </summary>
        public async Task EnsureCurrencyExistsAsync(string currencyCode, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(currencyCode)) return;
            var code = currencyCode.Trim().ToUpperInvariant();
            var exists = await _db.Currencies.AnyAsync(c => c.Code == code, cancellationToken);
            if (exists) return;

            // إنشاء عملة افتراضية ببيانات أولية بسيطة
            var currency = new Currency
            {
                Code = code,
                ArabicCode = code,
                Name = code,
                ArabicName = code,
                IsDefault = false,
                ExchangeRate = 1m,
                LastUpdated = DateTime.UtcNow
            };
            await _db.Currencies.AddAsync(currency, cancellationToken);
            await _db.SaveChangesAsync(cancellationToken);
        }
    }
}
