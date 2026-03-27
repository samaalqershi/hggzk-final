namespace YemenBooking.Application.Common.Exceptions;

/// <summary>
/// Represents a conflict exception.
/// يمثل استثناء تعارض.
/// </summary>
public class ConflictException : Exception
{
    /// <summary>
    /// Gets the conflict type.
    /// يحصل على نوع التعارض.
    /// </summary>
    public string ConflictType { get; }

    /// <summary>
    /// Gets the conflicting object.
    /// يحصل على الكائن المتعارض.
    /// </summary>
    public object? ConflictingObject { get; }

    /// <summary>
    /// Gets the current stored object when the conflict was detected.
    /// يحصل على الكائن الحالي المخزن عند اكتشاف التعارض.
    /// </summary>
    public object? CurrentObject { get; }

    /// <summary>
    /// Creates a conflict exception with the specified conflict type and error message.
    /// ينشئ استثناء تعارض بنوع التعارض ورسالة الخطأ المحددين.
    /// </summary>
    /// <param name="conflictType">The conflict type. نوع التعارض.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public ConflictException(string conflictType, string message) : base(message)
    {
        ConflictType = conflictType;
    }

    /// <summary>
    /// Creates a conflict exception with the object that caused the conflict.
    /// ينشئ استثناء تعارض مع الكائن الذي تسبب في التعارض.
    /// </summary>
    /// <param name="conflictType">The conflict type. نوع التعارض.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="conflictingObject">The conflicting object. الكائن المتعارض.</param>
    public ConflictException(string conflictType, string message, object? conflictingObject) : base(message)
    {
        ConflictType = conflictType;
        ConflictingObject = conflictingObject;
    }

    /// <summary>
    /// Creates a conflict exception that includes both the incoming object and the existing persisted object.
    /// ينشئ استثناء تعارض يتضمن الكائن الوارد والكائن المخزن بالفعل.
    /// </summary>
    /// <param name="conflictType">The conflict type. نوع التعارض.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="conflictingObject">The conflicting object. الكائن المتعارض.</param>
    /// <param name="currentObject">The current stored object. الكائن الحالي المخزن.</param>
    public ConflictException(string conflictType, string message, object? conflictingObject, object? currentObject) : base(message)
    {
        ConflictType = conflictType;
        ConflictingObject = conflictingObject;
        CurrentObject = currentObject;
    }

    /// <summary>
    /// Creates a conflict exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء تعارض مع استثناء داخلي للحفاظ على سلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="conflictType">The conflict type. نوع التعارض.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public ConflictException(string conflictType, string message, Exception innerException) : base(message, innerException)
    {
        ConflictType = conflictType;
    }
}
