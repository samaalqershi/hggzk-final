using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Contracts.Services.Wallets
{
    /// <summary>
    /// نتيجة الاستعلام عن رصيد المحفظة. Wallet balance inquiry result.
    /// </summary>
    public class WalletBalanceResult
    {
        /// <summary>
        /// هل نجح الاستعلام. Whether the inquiry succeeded.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// رصيد المحفظة الحالي. Current wallet balance.
        /// </summary>
        public decimal Balance { get; set; }

        /// <summary>
        /// العملة. Currency.
        /// </summary>
        public string Currency { get; set; } = "YER";

        /// <summary>
        /// رسالة توضيحية. Informational message.
        /// </summary>
        public string Message { get; set; } = string.Empty;
    }

    /// <summary>
    /// خدمة منطق الأعمال الخاصة بمحفظة جوالي. Business service for Jwali wallet payments.
    /// </summary>
    public interface IJwaliWalletService
    {
        /// <summary>
        /// تنفيذ عملية دفع حجز عبر محفظة جوالي باستخدام قسيمة (Voucher). الخدمة تنفذ داخلياً استعلام الفاتورة ثم عملية السحب النقدي (Cashout). Processes a booking payment through Jwali wallet using a voucher. The service internally performs invoice inquiry and then the cashout operation.
        /// </summary>
        /// <param name="booking">كيان الحجز المرتبط بالدفع. Booking entity tied to the payment.</param>
        /// <param name="amount">المبلغ المطلوب دفعه (يجب أن يطابق مبلغ الفاتورة). Amount to be paid (must match the invoice amount).</param>
        /// <param name="voucher">كود القسيمة / الفاتورة القادم من تطبيق جوالي. Voucher or invoice code coming from the Jwali app.</param>
        /// <param name="receiverMobile">رقم جوال المستلم (عادة رقم جوال العميل). Receiver mobile number (usually the customer's mobile number).</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة معالجة الدفع عبر جوالي. Jwali payment processing result.</returns>
        Task<PaymentResult> ProcessBookingPaymentAsync(
            Booking booking,
            decimal amount,
            string voucher,
            string? receiverMobile,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// استرداد مبلغ لعملية دفع تمت عبر محفظة جوالي (E-Commerce Refund). Refund an amount for a payment processed via Jwali wallet (E-Commerce Refund).
        /// </summary>
        /// <param name="payment">كيان الدفعة الأصلية. Original payment entity.</param>
        /// <param name="booking">كيان الحجز المرتبط بالدفعة. Booking entity linked to the payment.</param>
        /// <param name="refundAmount">المبلغ المطلوب استرداده. Refund amount.</param>
        /// <param name="reason">سبب الاسترداد كما سيظهر في جوالي. Refund reason as shown in Jwali.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة عملية الاسترداد. Refund operation result.</returns>
        Task<RefundResult> RefundAsync(
            Payment payment,
            Booking booking,
            decimal refundAmount,
            string reason,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// الاستعلام عن رصيد محفظة التطبيق. Query the application wallet balance. يستخدم للتحقق من كفاية الرصيد قبل عمليات الاسترداد. Used to verify sufficient funds before refunds.
        /// </summary>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة الاستعلام عن الرصيد. Wallet balance inquiry result.</returns>
        Task<WalletBalanceResult> GetApplicationWalletBalanceAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// التحقق من كفاية الرصيد لعملية استرداد محددة. Check whether the balance is sufficient for a specific refund operation.
        /// </summary>
        /// <param name="refundAmount">مبلغ الاسترداد المطلوب. Requested refund amount.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة التحقق: true إذا كان الرصيد كافياً. Validation result: true when the balance is sufficient.</returns>
        Task<(bool IsSufficient, decimal CurrentBalance, string Message)> CheckBalanceSufficiencyAsync(
            decimal refundAmount,
            CancellationToken cancellationToken = default);
    }
}
