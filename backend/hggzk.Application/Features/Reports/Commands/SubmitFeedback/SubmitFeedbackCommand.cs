using MediatR;

namespace YemenBooking.Application.Features.Reports.Commands.SubmitFeedback;

/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
public class SubmitFeedbackCommand : IRequest<SubmitFeedbackResponse>
{
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// يمثل الملاحظات النوع.
    /// Represents feedback type.
    /// </summary>
    public string FeedbackType { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل الموضوع.
    /// Represents subject.
    /// </summary>
    public string Subject { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل المحتوى.
    /// Represents content.
    /// </summary>
    public string Content { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل معلومات الجهاز.
    /// Represents device info.
    /// </summary>
    public DeviceInfoDto? DeviceInfo { get; set; }
    
    /// <summary>
    /// يمثل Screenshots Base 64.
    /// Represents screenshots base64.
    /// </summary>
    public List<string> ScreenshotsBase64 { get; set; } = new();
}

/// <summary>
/// يمثل معلومات الجهاز المرتبطة بالملاحظات.
/// represents device information attached to feedback
/// </summary>
public class DeviceInfoDto
{
    /// <summary>
    /// يمثل الجهاز النوع.
    /// Represents device type.
    /// </summary>
    public string DeviceType { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل نظام التشغيل.
    /// Represents operating system.
    /// </summary>
    public string OperatingSystem { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل إصدار نظام التشغيل.
    /// Represents os version.
    /// </summary>
    public string OsVersion { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل إصدار التطبيق.
    /// Represents app version.
    /// </summary>
    public string AppVersion { get; set; } = string.Empty;
}

/// <summary>
/// يمثل استجابة إرسال الملاحظات.
/// represents the feedback submission response
/// </summary>
public class SubmitFeedbackResponse
{
    /// <summary>
    /// يحدد ما إذا كان النجاح
    /// Indicates whether success.
    /// </summary>
    public bool Success { get; set; }
    
    /// <summary>
    /// يمثل الرقم المرجعي.
    /// Represents reference number.
    /// </summary>
    public string? ReferenceNumber { get; set; }
    
    /// <summary>
    /// يمثل الرسالة.
    /// Represents message.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}