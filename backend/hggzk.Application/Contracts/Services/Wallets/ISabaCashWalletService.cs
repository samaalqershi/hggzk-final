using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Contracts.Services.Wallets
{
    /// <summary>
    /// خدمة منطق الأعمال الخاصة بمحفظة سبأ كاش. Business service for SabaCash wallet payments (via YottaPay).
    /// </summary>
    public interface ISabaCashWalletService
    {
        /// <summary>
        /// تهيئة عملية دفع جديدة عبر سبأ كاش (إنشاء عملية في YottaPay وإرسال OTP للعميل). Initiate a new SabaCash payment (create adjustment in YottaPay and send OTP to the customer).
        /// </summary>
        /// <param name="booking">كيان الحجز المرتبط بالدفع. Booking entity tied to the payment.</param>
        /// <param name="amount">المبلغ المطلوب دفعه. Amount to be paid.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة معالجة الدفع (عادة بحالة Pending في هذه المرحلة). Payment processing result, usually pending at this stage.</returns>
        Task<PaymentResult> InitiatePaymentAsync(Booking booking, decimal amount, CancellationToken cancellationToken = default);

        /// <summary>
        /// تأكيد عملية دفع سبأ كاش باستخدام رمز OTP المرسل للعميل. Confirm an existing SabaCash payment using the OTP sent to the customer.
        /// </summary>
        /// <param name="payment">كيان الدفع الموجود في النظام. Existing payment entity in the system.</param>
        /// <param name="otp">رمز التحقق المكون من 4 أرقام. 4-digit verification code.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة معالجة الدفع بعد التأكيد. Payment processing result after confirmation.</returns>
        Task<PaymentResult> ConfirmPaymentAsync(Payment payment, string otp, CancellationToken cancellationToken = default);

        /// <summary>
        /// استرداد مبلغ لعملية دفع تمت عبر محفظة سبأ كاش. Refund an amount for a payment processed via the SabaCash wallet.
        /// </summary>
        /// <param name="payment">كيان الدفعة الأصلية. Original payment entity.</param>
        /// <param name="booking">كيان الحجز المرتبط بالدفعة (يُستخدم للحصول على محفظة العميل). Booking entity tied to the payment (used to obtain the customer's wallet).</param>
        /// <param name="refundAmount">المبلغ المطلوب استرداده. Refund amount.</param>
        /// <param name="reason">سبب الاسترداد كما سيظهر في YottaPay. Refund reason as shown in YottaPay.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة عملية الاسترداد. Refund operation result.</returns>
        Task<RefundResult> RefundAsync(
            Payment payment,
            Booking booking,
            decimal refundAmount,
            string reason,
            CancellationToken cancellationToken = default);
    }
}
