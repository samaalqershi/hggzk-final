namespace YemenBooking.Application.Common.Models;

/// <summary>
/// Represents the result of an operation, with or without data.
/// يمثل نتيجة عملية، مع بيانات أو بدونها.
/// </summary>
/// <typeparam name="T">The payload type returned by the operation. نوع البيانات المرجعة من العملية.</typeparam>
public class ResultDto<T>
{
    /// <summary>
    /// Gets or sets whether the operation succeeded.
    /// يحصل أو يعيّن ما إذا كانت العملية قد نجحت.
    /// </summary>
    public bool Success { get; set; }
    
    /// <summary>
    /// Gets or sets the returned payload.
    /// يحصل أو يعيّن البيانات المرجعة.
    /// </summary>
    public T? Data { get; set; }
    
    /// <summary>
    /// Gets or sets the success or error message.
    /// يحصل أو يعيّن رسالة النجاح أو الخطأ.
    /// </summary>
    public string? Message { get; set; }
    
    /// <summary>
    /// Gets or sets the error list.
    /// يحصل أو يعيّن قائمة الأخطاء.
    /// </summary>
    public IEnumerable<string> Errors { get; set; } = new List<string>();
    
    /// <summary>
    /// Gets or sets the error code.
    /// يحصل أو يعيّن كود الخطأ.
    /// </summary>
    public string? ErrorCode { get; set; }
    
    /// <summary>
    /// Gets or sets the UTC timestamp of the result.
    /// يحصل أو يعيّن الطابع الزمني UTC للنتيجة.
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Gets a read-only alias for `Success`.
    /// يعرض اسمًا بديلًا للخاصية `Success`.
    /// </summary>
    public bool IsSuccess => Success;
    
    /// <summary>
    /// Gets or sets the operation code.
    /// يحصل أو يعيّن كود العملية.
    /// </summary>
    public string? Code { get; set; }
    
    /// <summary>
    /// Gets or sets whether the client should show the message as a dialog.
    /// يحصل أو يعيّن ما إذا كان يجب عرض الرسالة كنافذة حوار.
    /// </summary>
    public bool ShowAsDialog { get; set; } = false;
    

    /// <summary>
    /// Creates a successful result.
    /// ينشئ نتيجة ناجحة.
    /// </summary>
    public static ResultDto<T> Ok(T? data, string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return new ResultDto<T>
        {
            Success = true,
            Data = data,
            Message = arabicMessage ?? englishMessage,
            ShowAsDialog = showAsDialog
        };
    }
    
    /// <summary>
    /// Alias for `Ok` to preserve existing call sites.
    /// اسم بديل لـ `Ok` للحفاظ على الاستدعاءات الحالية.
    /// </summary>
    public static ResultDto<T> Succeeded(T? data, string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return Ok(data, arabicMessage, englishMessage, showAsDialog);
    }
    
    /// <summary>
    /// Alias named `SuccessResult` for existing handler conventions.
    /// اسم بديل `SuccessResult` ليتوافق مع الاستخدام الحالي في المعالجات.
    /// </summary>
    public static ResultDto<T> SuccessResult(T? data, string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return Ok(data, arabicMessage, englishMessage, showAsDialog);
    }
        
    /// <summary>
    /// Creates a failed result.
    /// ينشئ نتيجة فاشلة.
    /// </summary>
    public static ResultDto<T> Failure(string arabicMessage, string? englishMessage = null, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto<T>
        {
            Success = false,
            Message = arabicMessage ?? englishMessage,
            ErrorCode = errorCode,
            Errors = new[] { arabicMessage ?? englishMessage ?? "خطأ غير محدد" },
            ShowAsDialog = showAsDialog
        };
    }
    
    /// <summary>
    /// Creates a failed result with multiple errors.
    /// ينشئ نتيجة فاشلة مع أخطاء متعددة.
    /// </summary>
    public static ResultDto<T> Failed(IEnumerable<string> errors, string? message = null, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto<T>
        {
            Success = false,
            Message = message ?? "حدثت أخطاء متعددة",
            ErrorCode = errorCode,
            Errors = errors,
            ShowAsDialog = showAsDialog
        };
    }
    
    /// <summary>
    /// Creates a failed result with a single error.
    /// ينشئ نتيجة فاشلة بخطأ واحد.
    /// </summary>
    public static ResultDto<T> Failed(string arabicMessage, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto<T>
        {
            Success = false,
            Message = arabicMessage,
            ErrorCode = errorCode,
            Errors = new[] { arabicMessage },
            ShowAsDialog = showAsDialog
        };
    }
}

/// <summary>
/// Represents an operation result without a payload.
/// يمثل نتيجة عملية بدون بيانات.
/// </summary>
public class ResultDto
{
    /// <summary>
    /// Gets or sets whether the operation succeeded.
    /// يحصل أو يعيّن ما إذا كانت العملية قد نجحت.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Gets or sets the success or error message.
    /// يحصل أو يعيّن رسالة النجاح أو الخطأ.
    /// </summary>
    public string? Message { get; set; }

    /// <summary>
    /// Gets or sets the error list.
    /// يحصل أو يعيّن قائمة الأخطاء.
    /// </summary>
    public IEnumerable<string> Errors { get; set; } = new List<string>();

    /// <summary>
    /// Gets or sets the error code.
    /// يحصل أو يعيّن كود الخطأ.
    /// </summary>
    public string? ErrorCode { get; set; }

    /// <summary>
    /// Gets or sets the UTC timestamp of the result.
    /// يحصل أو يعيّن الطابع الزمني UTC للنتيجة.
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Gets or sets whether the client should show the message as a dialog.
    /// يحصل أو يعيّن ما إذا كان يجب عرض الرسالة كنافذة حوار.
    /// </summary>
    public bool ShowAsDialog { get; set; } = false;

    /// <summary>
    /// Gets a read-only alias for `Success`.
    /// يعرض اسمًا بديلًا للخاصية `Success`.
    /// </summary>
    public bool IsSuccess => Success;
    
    /// <summary>
    /// Gets or sets the operation code.
    /// يحصل أو يعيّن كود العملية.
    /// </summary>
    public string? Code { get; set; }

    /// <summary>
    /// Creates a successful result.
    /// ينشئ نتيجة ناجحة.
    /// </summary>
    public static ResultDto Ok(string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return new ResultDto
        {
            Success = true,
            Message = arabicMessage ?? englishMessage,
            ShowAsDialog = showAsDialog
        };
    }

    /// <summary>
    /// Alias for `Ok` to preserve existing call sites.
    /// اسم بديل لـ `Ok` للحفاظ على الاستدعاءات الحالية.
    /// </summary>
    public static ResultDto Succeeded(string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return Ok(arabicMessage, englishMessage, showAsDialog);
    }
    /// <summary>
    /// Alias named `SuccessResult` for existing handler conventions.
    /// اسم بديل `SuccessResult` ليتوافق مع الاستخدام الحالي في المعالجات.
    /// </summary>
    public static ResultDto SuccessResult(string? arabicMessage = null, string? englishMessage = null, bool showAsDialog = false)
    {
        return Ok(arabicMessage, englishMessage, showAsDialog);
    }

    /// <summary>
    /// Creates a failed result.
    /// ينشئ نتيجة فاشلة.
    /// </summary>
    public static ResultDto Failure(string arabicMessage, string? englishMessage = null, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto
        {
            Success = false,
            Message = arabicMessage ?? englishMessage,
            ErrorCode = errorCode,
            Errors = new[] { arabicMessage ?? englishMessage ?? "خطأ غير محدد" },
            ShowAsDialog = showAsDialog
        };
    }

    /// <summary>
    /// Creates a failed result with multiple errors.
    /// ينشئ نتيجة فاشلة مع أخطاء متعددة.
    /// </summary>
    public static ResultDto Failed(IEnumerable<string> errors, string? message = null, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto
        {
            Success = false,
            Message = message ?? "حدثت أخطاء متعددة",
            ErrorCode = errorCode,
            Errors = errors,
            ShowAsDialog = showAsDialog
        };
    }
    
    /// <summary>
    /// Creates a failed result with multiple errors.
    /// ينشئ نتيجة فاشلة مع أخطاء متعددة.
    /// </summary>
    public static ResultDto Failed(string? message = null, string? errorCode = null, bool showAsDialog = false)
    {
        return new ResultDto
        {
            Success = false,
            Message = message ?? "حدثت أخطاء متعددة",
            ErrorCode = errorCode,
            Errors = new[] { message ?? "خطأ غير محدد" },
            ShowAsDialog = showAsDialog
        };
    }
}
