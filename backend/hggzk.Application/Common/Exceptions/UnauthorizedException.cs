namespace YemenBooking.Application.Common.Exceptions;

/// <summary>
/// Represents an unauthorized exception.
/// يمثل استثناء عدم تفويض.
/// </summary>
public class UnauthorizedException : Exception
{
    /// <summary>
    /// Gets the required operation type.
    /// يحصل على نوع العملية المطلوبة.
    /// </summary>
    public string? OperationType { get; }

    /// <summary>
    /// Gets the resource being accessed.
    /// يحصل على المورد المطلوب الوصول إليه.
    /// </summary>
    public string? Resource { get; }

    /// <summary>
    /// Gets the required permission.
    /// يحصل على الصلاحية المطلوبة.
    /// </summary>
    public string? RequiredPermission { get; }

    /// <summary>
    /// Creates an unauthorized exception with the default generic message.
    /// ينشئ استثناء عدم تفويض بالرسالة العامة الافتراضية.
    /// </summary>
    public UnauthorizedException() : base("Access denied")
    {
    }

    /// <summary>
    /// Creates an unauthorized exception with a custom message.
    /// ينشئ استثناء عدم تفويض برسالة مخصصة.
    /// </summary>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public UnauthorizedException(string message) : base(message)
    {
    }

    /// <summary>
    /// Creates an unauthorized exception that identifies the requested operation and resource.
    /// ينشئ استثناء عدم تفويض يحدد العملية والمورد المطلوبين.
    /// </summary>
    /// <param name="operationType">The operation type. نوع العملية.</param>
    /// <param name="resource">The target resource. المورد المستهدف.</param>
    public UnauthorizedException(string operationType, string resource) 
        : base($"Access denied to {operationType} on {resource}")
    {
        OperationType = operationType;
        Resource = resource;
    }

    /// <summary>
    /// Creates an unauthorized exception that specifies the required permission.
    /// ينشئ استثناء عدم تفويض يحدد الصلاحية المطلوبة للوصول.
    /// </summary>
    /// <param name="operationType">The operation type. نوع العملية.</param>
    /// <param name="resource">The target resource. المورد المستهدف.</param>
    /// <param name="requiredPermission">The required permission. الصلاحية المطلوبة.</param>
    public UnauthorizedException(string operationType, string resource, string requiredPermission) 
        : base($"Access denied to {operationType} on {resource}. Required permission: {requiredPermission}")
    {
        OperationType = operationType;
        Resource = resource;
        RequiredPermission = requiredPermission;
    }

    /// <summary>
    /// Creates an unauthorized exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء عدم تفويض مع استثناء داخلي للحفاظ على سلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public UnauthorizedException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
