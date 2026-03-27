using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Currency
{
    /// <summary>
    /// خدمة لضمان توفر العملة عند الحاجة.
    /// Service that ensures a currency exists when needed.
    /// </summary>
    public interface ICurrencyEnsureService
    {
        /// <summary>
        /// يتحقق من وجود العملة بالرمز المحدد، وينشئها إذا كانت مفقودة.
        /// Ensures that the currency identified by the given code exists, creating it if missing.
        /// </summary>
        Task EnsureCurrencyExistsAsync(string currencyCode, CancellationToken cancellationToken = default);
    }
}
