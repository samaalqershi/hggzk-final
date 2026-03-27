namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// عقد خدمة التحقق من صحة البيانات العامة عبر طبقة التطبيق.
/// Contract for cross-cutting data validation services used by the application layer.
/// </summary>
public interface IValidationService
{
    /// <summary>
    /// يتحقق من صحة بيانات الحجز.
    /// Validates booking data.
    /// </summary>
    /// <param name="bookingData">بيانات الحجز المراد التحقق منها. Booking payload to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    Task<ValidationServiceResult> ValidateBookingAsync(object bookingData, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة بيانات الوحدة.
    /// Validates unit data.
    /// </summary>
    /// <param name="unitData">بيانات الوحدة المراد التحقق منها. Unit payload to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    Task<ValidationServiceResult> ValidateUnitAsync(object unitData, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة بيانات المستخدم.
    /// Validates user data.
    /// </summary>
    /// <param name="userData">بيانات المستخدم المراد التحقق منها. User payload to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    Task<ValidationServiceResult> ValidateUserAsync(object userData, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة بيانات العقار.
    /// Validates property data.
    /// </summary>
    /// <param name="propertyData">بيانات العقار المراد التحقق منها. Property payload to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    Task<ValidationServiceResult> ValidatePropertyAsync(object propertyData, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة بيانات الدفع.
    /// Validates payment data.
    /// </summary>
    /// <param name="paymentData">بيانات الدفع المراد التحقق منها. Payment payload to validate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة التحقق التفصيلية. Detailed validation result.</returns>
    Task<ValidationServiceResult> ValidatePaymentAsync(object paymentData, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة البريد الإلكتروني.
    /// Validates an email address.
    /// </summary>
    /// <param name="email">عنوان البريد الإلكتروني. Email address.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>قيمة تشير إلى صلاحية البريد الإلكتروني. Value indicating whether the email is valid.</returns>
    Task<bool> IsValidEmailAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة رقم الهاتف.
    /// Validates a phone number.
    /// </summary>
    /// <param name="phone">رقم الهاتف. Phone number.</param>
    /// <param name="countryCode">رمز الدولة إن وجد. Optional country code.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>قيمة تشير إلى صلاحية رقم الهاتف. Value indicating whether the phone number is valid.</returns>
    Task<bool> IsValidPhoneAsync(string phone, string? countryCode = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من قوة كلمة المرور ويعيد تفاصيل التقييم.
    /// Validates password strength and returns detailed scoring information.
    /// </summary>
    /// <param name="password">كلمة المرور المراد تقييمها. Password to evaluate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>نتيجة تقييم كلمة المرور. Password validation result.</returns>
    Task<PasswordValidationResult> ValidatePasswordAsync(string password, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من صحة الرقم الوطني.
    /// Validates a national identifier.
    /// </summary>
    /// <param name="nationalId">الرقم الوطني. National identifier.</param>
    /// <param name="country">الدولة المرجعية إن وجدت. Optional country hint.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>قيمة تشير إلى صلاحية الرقم الوطني. Value indicating whether the national identifier is valid.</returns>
    Task<bool> IsValidNationalIdAsync(string nationalId, string? country = null, CancellationToken cancellationToken = default);
}
