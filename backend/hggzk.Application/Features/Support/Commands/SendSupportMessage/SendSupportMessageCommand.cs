using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Support.Commands.SendSupportMessage;

    /// <summary>
    /// يمثل طلب إرسال رسالة دعم.
    /// Represents a request to send a support message.
    /// </summary>
public class SendSupportMessageCommand : IRequest<ResultDto<SendSupportMessageResponse>>
{
    /// <summary>
    /// اسم المستخدم المرسل للرسالة.
    /// Specifies the name of the user sending the message.
    /// </summary>
    public string UserName { get; set; } = string.Empty;
    /// <summary>
    /// البريد الإلكتروني للمستخدم.
    /// Specifies the user's email address.
    /// </summary>
    public string UserEmail { get; set; } = string.Empty;
    /// <summary>
    /// موضوع الرسالة.
    /// Specifies the support message subject.
    /// </summary>
    public string Subject { get; set; } = string.Empty;
    /// <summary>
    /// نص رسالة الدعم.
    /// Specifies the support message body.
    /// </summary>
    public string Message { get; set; } = string.Empty;
    /// <summary>
    /// نوع الجهاز المستخدم.
    /// Specifies the type of device used.
    /// </summary>
    public string? DeviceType { get; set; }
    /// <summary>
    /// نظام التشغيل.
    /// Specifies the operating system.
    /// </summary>
    public string? OperatingSystem { get; set; }
    /// <summary>
    /// إصدار نظام التشغيل.
    /// Specifies the operating system version.
    /// </summary>
    public string? OsVersion { get; set; }
    /// <summary>
    /// إصدار التطبيق.
    /// Specifies the application version.
    /// </summary>
    public string? AppVersion { get; set; }
}

    /// <summary>
    /// يمثل نتيجة إرسال رسالة الدعم.
    /// Represents the result of sending a support message.
    /// </summary>
public class SendSupportMessageResponse
{
    /// <summary>
    /// يحدد ما إذا كانت العملية قد نجحت.
    /// Indicates whether the operation completed successfully.
    /// </summary>
    public bool Success { get; set; }
    /// <summary>
    /// رقم مرجعي للمتابعة.
    /// Provides a reference number for follow-up.
    /// </summary>
    public string ReferenceNumber { get; set; } = string.Empty;
    /// <summary>
    /// رسالة توضح نتيجة العملية.
    /// A message describing the operation outcome.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}
