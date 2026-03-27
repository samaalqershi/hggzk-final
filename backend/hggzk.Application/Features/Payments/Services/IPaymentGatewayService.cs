namespace YemenBooking.Application.Features.Payments.Services;

/// <summary>
/// واجهة خدمة بوابة الدفع
/// Payment gateway service interface
/// </summary>
public interface IPaymentGatewayService
{
    /// <summary>
    /// معالجة الاسترداد عبر البوابة
    /// Process refund via gateway
    /// </summary>
    Task<(bool IsSuccess, string RefundId, string ErrorMessage)> ProcessRefundAsync(
        string originalTransactionId,
        decimal refundAmount,
        string reason,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// التحقق من حالة المعاملة
    /// Verify transaction status
    /// </summary>
    Task<(string Status, Dictionary<string, object> Details)> VerifyTransactionAsync(
        string transactionId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إلغاء المعاملة
    /// Cancel transaction
    /// </summary>
    Task<bool> CancelTransactionAsync(
        string transactionId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// معالجة دفعة سبأ كاش
    /// Process SabaCash payment
    /// </summary>
    Task<(bool IsSuccess, string TransactionId, string ErrorMessage)> ProcessSabaCashPaymentAsync(
        string sabaCashTransactionId,
        decimal amount,
        CancellationToken cancellationToken = default);
}
