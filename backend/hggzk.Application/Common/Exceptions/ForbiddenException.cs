namespace YemenBooking.Application.Common.Exceptions;

/// <summary>
/// Represents a forbidden exception.
/// يمثل استثناء منع.
/// </summary>
public class ForbiddenException : Exception
{
    /// <summary>
    /// Gets the forbidden operation type.
    /// يحصل على نوع العملية المحظورة.
    /// </summary>
    public string? OperationType { get; }

    /// <summary>
    /// Gets the forbidden resource.
    /// يحصل على المورد المحظور.
    /// </summary>
    public string? Resource { get; }

    /// <summary>
    /// Gets the reason for the prohibition.
    /// يحصل على سبب المنع.
    /// </summary>
    public string? Reason { get; }

    /// <summary>
    /// Creates a forbidden exception with the default generic message.
    /// ينشئ استثناء منع بالرسالة العامة الافتراضية.
    /// </summary>
    public ForbiddenException() : base("Operation forbidden")
    {
    }

    /// <summary>
    /// Creates a forbidden exception with a custom message.
    /// ينشئ استثناء منع برسالة مخصصة.
    /// </summary>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public ForbiddenException(string message) : base(message)
    {
    }

    /// <summary>
    /// Creates a forbidden exception that identifies the operation and resource.
    /// ينشئ استثناء منع يحدد العملية والمورد.
    /// </summary>
    /// <param name="operationType">The operation type. نوع العملية.</param>
    /// <param name="resource">The target resource. المورد المستهدف.</param>
    public ForbiddenException(string operationType, string resource) 
        : base($"Operation '{operationType}' is forbidden on resource '{resource}'")
    {
        OperationType = operationType;
        Resource = resource;
    }

    /// <summary>
    /// Creates a forbidden exception that identifies the operation, resource, and reason.
    /// ينشئ استثناء منع يحدد العملية والمورد وسبب المنع.
    /// </summary>
    /// <param name="operationType">The operation type. نوع العملية.</param>
    /// <param name="resource">The target resource. المورد المستهدف.</param>
    /// <param name="reason">The reason for the prohibition. سبب المنع.</param>
    public ForbiddenException(string operationType, string resource, string reason) 
        : base($"Operation '{operationType}' is forbidden on resource '{resource}'. Reason: {reason}")
    {
        OperationType = operationType;
        Resource = resource;
        Reason = reason;
    }

    /// <summary>
    /// Creates a forbidden exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء منع مع استثناء داخلي للحفاظ على سلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public ForbiddenException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
