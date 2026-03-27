using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Wallets.Flosk;

namespace YemenBooking.Application.Contracts.Services.Wallets
{
    /// <summary>
    /// واجهة تكامل محفظة فلوسك لمعالجة إنشاء المفاتيح والمدفوعات والاسترجاعات.
    /// Contract for the Flosk wallet integration that handles key exchange, payments, and refunds.
    /// </summary>
    public interface IFloskWalletService
    {
        /// <summary>
        /// يتحقق مما إذا كانت العملة مدعومة من مزود فلوسك.
        /// Determines whether a currency is supported by the Flosk provider.
        /// </summary>
        /// <param name="currency">رمز العملة. Currency code.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>قيمة تشير إلى دعم العملة. Value indicating whether the currency is supported.</returns>
        Task<bool> IsCurrencySupportedAsync(string currency, CancellationToken cancellationToken = default);

        /// <summary>
        /// يلغي صلاحية المفتاح التجاري المخزن مؤقتاً لإجبار إعادة تحميله.
        /// Invalidates the cached merchant key so it can be reloaded from the provider.
        /// </summary>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        Task InvalidateMerchantKeyCacheAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// يطلب مفتاح بدء جلسة جديد من مزود فلوسك.
        /// Requests a new session or request key from the Flosk provider.
        /// </summary>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة طلب المفتاح. Key request response.</returns>
        Task<FloskRequestKeyResponse> RequestKeyAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// يؤكد المفتاح المطلوب عبر رمز التحقق لمرة واحدة.
        /// Verifies a previously requested key using a one-time password.
        /// </summary>
        /// <param name="requestId">معرف طلب المفتاح. Key request identifier.</param>
        /// <param name="otp">رمز التحقق لمرة واحدة. One-time password.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة تأكيد المفتاح. Key verification response.</returns>
        Task<FloskVerifyKeyResponse> VerifyKeyAsync(long requestId, string otp, CancellationToken cancellationToken = default);

        /// <summary>
        /// يبدأ عملية دفع جديدة لحجز محدد عبر فلوسك.
        /// Initiates a new payment for the specified booking through Flosk.
        /// </summary>
        /// <param name="booking">الحجز المستهدف. Target booking.</param>
        /// <param name="amount">المبلغ المراد تحصيله. Amount to charge.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة عملية الدفع. Payment operation result.</returns>
        Task<PaymentResult> InitiatePaymentAsync(Booking booking, decimal amount, CancellationToken cancellationToken = default);

        /// <summary>
        /// يؤكد دفعة معلقة باستخدام رمز تحقق مرسل للمستخدم.
        /// Confirms a pending payment using a verification code supplied by the user.
        /// </summary>
        /// <param name="payment">سجل الدفع المراد تأكيده. Payment record to confirm.</param>
        /// <param name="otp">رمز التحقق لمرة واحدة. One-time password.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة تأكيد الدفع. Payment confirmation result.</returns>
        Task<PaymentResult> ConfirmPaymentAsync(Payment payment, string otp, CancellationToken cancellationToken = default);

        /// <summary>
        /// ينفذ استرجاعاً جزئياً أو كاملاً لدفعة مرتبطة بحجز.
        /// Executes a full or partial refund for a payment associated with a booking.
        /// </summary>
        /// <param name="payment">الدفع الأصلي. Original payment.</param>
        /// <param name="booking">الحجز المرتبط. Related booking.</param>
        /// <param name="refundAmount">مبلغ الاسترجاع. Refund amount.</param>
        /// <param name="reason">سبب الاسترجاع. Refund reason.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة عملية الاسترجاع. Refund operation result.</returns>
        Task<RefundResult> RefundAsync(
            Payment payment,
            Booking booking,
            decimal refundAmount,
            string reason,
            CancellationToken cancellationToken = default);
    }
}
