namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// امتدادات مساعدة لخدمة التحقق العامة.
/// Convenience extensions for the shared validation service.
/// </summary>
public static class ValidationServiceExtensions
{
    /// <summary>
    /// اختصار عام لإجراء التحقق الافتراضي على البيانات باستخدام مسار الحجز الحالي.
    /// Provides a generic shorthand for the default validation path using the booking-validation route.
    /// </summary>
    /// <param name="service">خدمة التحقق. Validation service.</param>
    /// <param name="data">البيانات المطلوب التحقق منها. Data to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    public static Task<ValidationServiceResult> ValidateAsync(this IValidationService service, object data, CancellationToken cancellationToken = default)
        => service.ValidateBookingAsync(data, cancellationToken);
}
