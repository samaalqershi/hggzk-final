namespace YemenBooking.Application.Common.Exceptions;

/// <summary>
/// Represents a not-found exception.
/// يمثل استثناء عدم العثور.
/// </summary>
public class NotFoundException : Exception
{
    /// <summary>
    /// Gets the object type.
    /// يحصل على نوع الكائن.
    /// </summary>
    public string ObjectType { get; }

    /// <summary>
    /// Gets the object identifier.
    /// يحصل على معرّف الكائن.
    /// </summary>
    public string? ObjectId { get; }

    /// <summary>
    /// Creates a not-found exception with the object type and optional identifier.
    /// ينشئ استثناء عدم العثور مع نوع الكائن والمعرّف الاختياري.
    /// </summary>
    /// <param name="objectType">The missing object type. نوع الكائن غير الموجود.</param>
    /// <param name="objectId">The missing object identifier. معرف الكائن غير الموجود.</param>
    public NotFoundException(string objectType, string? objectId = null) 
        : base($"{objectType} {(objectId != null ? $"with ID '{objectId}'" : "")} was not found")
    {
        ObjectType = objectType;
        ObjectId = objectId;
    }

    /// <summary>
    /// Creates a not-found exception with a custom message.
    /// ينشئ استثناء عدم العثور برسالة مخصصة.
    /// </summary>
    /// <param name="objectType">The missing object type. نوع الكائن غير الموجود.</param>
    /// <param name="objectId">The missing object identifier. معرف الكائن غير الموجود.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public NotFoundException(string objectType, string? objectId, string message) 
        : base(message)
    {
        ObjectType = objectType;
        ObjectId = objectId;
    }

    /// <summary>
    /// Creates a not-found exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء عدم العثور مع استثناء داخلي للحفاظ على سلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="objectType">The missing object type. نوع الكائن غير الموجود.</param>
    /// <param name="objectId">The missing object identifier. معرف الكائن غير الموجود.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public NotFoundException(string objectType, string? objectId, string message, Exception innerException) 
        : base(message, innerException)
    {
        ObjectType = objectType;
        ObjectId = objectId;
    }
}
