using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Wallets.Flosk;

namespace YemenBooking.Application.Infrastructure.Services.Wallets
{
    public interface IFloskWalletService
    {
        Task<bool> IsCurrencySupportedAsync(string currency, CancellationToken cancellationToken = default);

        Task InvalidateMerchantKeyCacheAsync(CancellationToken cancellationToken = default);

        Task<FloskRequestKeyResponse> RequestKeyAsync(CancellationToken cancellationToken = default);

        Task<FloskVerifyKeyResponse> VerifyKeyAsync(long requestId, string otp, CancellationToken cancellationToken = default);

        Task<PaymentResult> InitiatePaymentAsync(Booking booking, decimal amount, CancellationToken cancellationToken = default);

        Task<PaymentResult> ConfirmPaymentAsync(Payment payment, string otp, CancellationToken cancellationToken = default);

        Task<RefundResult> RefundAsync(
            Payment payment,
            Booking booking,
            decimal refundAmount,
            string reason,
            CancellationToken cancellationToken = default);
    }
}
