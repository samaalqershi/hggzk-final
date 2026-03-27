namespace YemenBooking.Application.Common.Exceptions;

using FluentValidation.Results;

/// <summary>
/// Represents a validation exception.
/// يمثل استثناء تحقق من صحة البيانات.
/// </summary>
public class ValidationException : Exception
{
    /// <summary>
    /// Gets the validation errors.
    /// يحصل على أخطاء التحقق.
    /// </summary>
    public IEnumerable<string> Errors { get; }

    /// <summary>
    /// Gets the related field name, when available.
    /// يحصل على اسم الحقل المرتبط عند توفره.
    /// </summary>
    public string? Field { get; }

    /// <summary>
    /// Creates a validation exception from a single error message.
    /// ينشئ استثناء تحقق من رسالة خطأ واحدة.
    /// </summary>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public ValidationException(string message) : base(message)
    {
        Errors = new[] { message };
    }

    /// <summary>
    /// Creates a validation exception associated with a specific field.
    /// ينشئ استثناء تحقق مرتبطًا بحقل محدد.
    /// </summary>
    /// <param name="field">The field name associated with the error. اسم الحقل المرتبط بالخطأ.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public ValidationException(string field, string message) : base(message)
    {
        Field = field;
        Errors = new[] { message };
    }

    /// <summary>
    /// Creates a validation exception from a collection of error messages.
    /// ينشئ استثناء تحقق من مجموعة رسائل خطأ.
    /// </summary>
    /// <param name="errors">The validation error messages. رسائل أخطاء التحقق.</param>
    public ValidationException(IEnumerable<string> errors) : base("One or more validation errors occurred")
    {
        Errors = errors;
    }

    /// <summary>
    /// Creates a validation exception with a main message and detailed errors.
    /// ينشئ استثناء تحقق برسالة رئيسية وأخطاء تفصيلية.
    /// </summary>
    /// <param name="message">The main message. الرسالة الرئيسية.</param>
    /// <param name="errors">The detailed errors. الأخطاء التفصيلية.</param>
    public ValidationException(string message, IEnumerable<string> errors) : base(message)
    {
        Errors = errors;
    }

    /// <summary>
    /// Creates a validation exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء تحقق مع استثناء داخلي للاحتفاظ بسلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="message">The main message. الرسالة الرئيسية.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public ValidationException(string message, Exception innerException) : base(message, innerException)
    {
        Errors = new[] { message };
    }

    /// <summary>
    /// Creates a validation exception from raw FluentValidation failures.
    /// ينشئ استثناء تحقق من إخفاقات FluentValidation الخام.
    /// </summary>
    /// <param name="failures">The raw validation failures. إخفاقات التحقق الخام.</param>
    public ValidationException(IEnumerable<ValidationFailure> failures) : base("One or more validation errors occurred")
    {
        Errors = failures.Select(f => f.ErrorMessage);
    }
}
