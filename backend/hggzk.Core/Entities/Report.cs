using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YemenBooking.Core.Entities
{
/// <summary>
/// بلاغ يقدمه مستخدم عن محتوى أو سلوك.
/// Report submitted by a user about content or behavior.
/// </summary>
[Display(Name = "كيان البلاغات لإدارة بلاغات المستخدمين عن المحتوى والسلوك")]
public class Report : BaseEntity<Guid>
{
    /// <summary>
    /// معرف المستخدم المبلّغ.
    /// Reporting user identifier.
    /// </summary>
    [Display(Name = "معرف المستخدم المبلغ")]
    public Guid ReporterUserId { get; set; }

    /// <summary>
    /// المستخدم المبلّغ.
    /// Reporting user.
    /// </summary>
    [Display(Name = "المستخدم المبلغ")]
    [ForeignKey(nameof(ReporterUserId))]
    public User ReporterUser { get; set; }

    /// <summary>
    /// معرف المستخدم المبلّغ عنه عند وجوده.
    /// Reported user identifier, when available.
    /// </summary>
    [Display(Name = "معرف المستخدم المبلغ عنه")]
    public Guid? ReportedUserId { get; set; }

    /// <summary>
    /// المستخدم المبلّغ عنه.
    /// Reported user.
    /// </summary>
    [Display(Name = "المستخدم المبلغ عنه")]
    [ForeignKey(nameof(ReportedUserId))]
    public User ReportedUser { get; set; }

    /// <summary>
    /// معرف الكيان المبلّغ عنه عند وجوده.
    /// Reported property identifier, when available.
    /// </summary>
    [Display(Name = "معرف الكيان المبلغ عنه")]
    public Guid? ReportedPropertyId { get; set; }

    /// <summary>
    /// الكيان المبلّغ عنه.
    /// Reported property.
    /// </summary>
    [Display(Name = "الكيان المبلغ عنه")]
    [ForeignKey(nameof(ReportedPropertyId))]
    public Property ReportedProperty { get; set; }

    /// <summary>
    /// سبب البلاغ.
    /// Report reason.
    /// </summary>
    [Display(Name = "سبب البلاغ")]
    [Required]
    public string Reason { get; set; }

    /// <summary>
    /// وصف تفصيلي للبلاغ.
    /// Detailed report description.
    /// </summary>
    [Display(Name = "الوصف التفصيلي للبلاغ")]
    public string Description { get; set; }

    /// <summary>
    /// حالة البلاغ الحالية.
    /// Current report status.
    /// </summary>
    [Display(Name = "حالة البلاغ")]
    [Required]
    public string Status { get; set; } = "pending";

    /// <summary>
    /// ملاحظات الإجراء من قبل الإدارة.
    /// Administrative action notes.
    /// </summary>
    [Display(Name = "ملاحظات الإجراء من قبل الإدارة")]
    public string ActionNote { get; set; }

    /// <summary>
    /// معرف مسؤول الإدارة الذي اتخذ الإجراء عند وجوده.
    /// Administrator identifier who handled the report, when available.
    /// </summary>
    [Display(Name = "معرف مسؤول الإدارة الذي اتخذ الإجراء")]
    public Guid? AdminId { get; set; }
    }
}
