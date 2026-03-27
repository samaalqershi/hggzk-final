using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;
using FluentValidation;
using System.Text.RegularExpressions;

namespace YemenBooking.Infrastructure.Services.Common
{
    /// <summary>
    /// Provides validation helpers backed by FluentValidation.
    /// يوفّر أدوات تحقق من الصحة معتمدة على FluentValidation.
    /// </summary>
    public class ValidationService : IValidationService
    {
        private readonly IServiceProvider _serviceProvider;

        /// <summary>
        /// Initializes a new instance of ValidationService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من ValidationService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public ValidationService(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        /// <summary>
        /// Validates the supplied booking payload.
        /// يتحقق من صحة بيانات الحجز المقدمة.
        /// </summary>
        public Task<ValidationServiceResult> ValidateBookingAsync(object bookingData, CancellationToken cancellationToken = default)
            => ValidateAsyncCore(bookingData, cancellationToken);

        /// <summary>
        /// Validates the supplied unit payload.
        /// يتحقق من صحة بيانات الوحدة المقدمة.
        /// </summary>
        public Task<ValidationServiceResult> ValidateUnitAsync(object unitData, CancellationToken cancellationToken = default)
            => ValidateAsyncCore(unitData, cancellationToken);

        /// <summary>
        /// Validates the supplied user payload.
        /// يتحقق من صحة بيانات المستخدم المقدمة.
        /// </summary>
        public Task<ValidationServiceResult> ValidateUserAsync(object userData, CancellationToken cancellationToken = default)
            => ValidateAsyncCore(userData, cancellationToken);

        /// <summary>
        /// Validates the supplied property payload.
        /// يتحقق من صحة بيانات العقار المقدمة.
        /// </summary>
        public Task<ValidationServiceResult> ValidatePropertyAsync(object propertyData, CancellationToken cancellationToken = default)
            => ValidateAsyncCore(propertyData, cancellationToken);

        /// <summary>
        /// Validates the supplied payment payload.
        /// يتحقق من صحة بيانات الدفعة المقدمة.
        /// </summary>
        public Task<ValidationServiceResult> ValidatePaymentAsync(object paymentData, CancellationToken cancellationToken = default)
            => ValidateAsyncCore(paymentData, cancellationToken);

        private async Task<ValidationServiceResult> ValidateAsyncCore(object data, CancellationToken cancellationToken)
        {
            if (data == null)
            {
                return ValidationServiceResult.Failure("البيانات غير موجودة", "DataNull");
            }
            var dataType = data.GetType();
            var validatorType = typeof(IValidator<>).MakeGenericType(dataType);
            dynamic? validator = _serviceProvider.GetService(validatorType);
            if (validator != null)
            {
                var result = await validator.ValidateAsync((dynamic)data, cancellationToken);
                return MapValidationResult(result);
            }
            return ValidationServiceResult.Success();
        }

        /// <summary>
        /// Checks whether the email address has a valid format.
        /// يتحقق مما إذا كان البريد الإلكتروني بصيغة صحيحة.
        /// </summary>
        public Task<bool> IsValidEmailAsync(string email, CancellationToken cancellationToken = default)
        {
            var isValid = !string.IsNullOrWhiteSpace(email) &&
                          Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
            return Task.FromResult(isValid);
        }

        /// <summary>
        /// Checks whether the phone number has a valid format.
        /// يتحقق مما إذا كان رقم الهاتف بصيغة صحيحة.
        /// </summary>
        public Task<bool> IsValidPhoneAsync(string phone, string? countryCode = null, CancellationToken cancellationToken = default)
        {
            var isValid = !string.IsNullOrWhiteSpace(phone) &&
                          Regex.IsMatch(phone, @"^7\d{8}$");
            return Task.FromResult(isValid);
        }

        /// <summary>
        /// Validates password complexity and returns the detailed result.
        /// يتحقق من تعقيد كلمة المرور ويعيد النتيجة التفصيلية.
        /// </summary>
        public Task<PasswordValidationResult> ValidatePasswordAsync(string password, CancellationToken cancellationToken = default)
        {
            var result = new PasswordValidationResult();
            if (string.IsNullOrEmpty(password))
            {
                result.IsValid = false;
                result.Score = 0;
                result.Strength = PasswordStrength.VERY_WEAK;
                result.Requirements.Add("كلمة المرور لا يمكن أن تكون فارغة");
            }
            else
            {
                var score = password.Length * 5;
                if (Regex.IsMatch(password, "[A-Z]")) score += 10;
                if (Regex.IsMatch(password, "[a-z]")) score += 10;
                if (Regex.IsMatch(password, "[0-9]")) score += 10;
                if (Regex.IsMatch(password, "[^a-zA-Z0-9]")) score += 10;
                score = Math.Min(100, score);
                result.Score = score;
                result.IsValid = score >= 50;
                result.Strength = score switch
                {
                    <= 20 => PasswordStrength.VERY_WEAK,
                    <= 40 => PasswordStrength.WEAK,
                    <= 60 => PasswordStrength.FAIR,
                    <= 80 => PasswordStrength.GOOD,
                    _ => PasswordStrength.EXCELLENT
                };
                if (password.Length < 8)
                    result.Requirements.Add("كلمة المرور يجب أن تكون 8 أحرف على الأقل");
            }
            return Task.FromResult(result);
        }

        /// <summary>
        /// Checks whether the national ID matches the expected format.
        /// يتحقق مما إذا كان الرقم الوطني مطابقًا للصيغة المتوقعة.
        /// </summary>
        public Task<bool> IsValidNationalIdAsync(string nationalId, string? country = null, CancellationToken cancellationToken = default)
        {
            var isValid = !string.IsNullOrWhiteSpace(nationalId) &&
                          nationalId.Length >= 6 && nationalId.Length <= 20;
            return Task.FromResult(isValid);
        }

        private ValidationServiceResult MapValidationResult(FluentValidation.Results.ValidationResult result)
        {
            var vr = new ValidationServiceResult
            {
                IsValid = result.IsValid,
                Errors = result.Errors.Select(e => new ValidationError
                {
                    Code = e.ErrorCode ?? string.Empty,
                    Message = e.ErrorMessage,
                    Field = e.PropertyName,
                    Value = e.AttemptedValue
                }).ToList()
            };
            return vr;
        }
    }
}
