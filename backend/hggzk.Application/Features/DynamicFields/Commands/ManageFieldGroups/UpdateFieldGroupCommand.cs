namespace YemenBooking.Application.Features.DynamicFields.Commands.ManageFieldGroups;

using global::YemenBooking.Application.Common.Models;
using MediatR;
using Unit = MediatR.Unit;

/// <summary>
/// يحدّث مجموعة حقول موجودة.
/// Updates an existing field group.
/// </summary>
public class UpdateFieldGroupCommand : IRequest<ResultDto<Unit>>
{
    /// <summary>
    /// معرف المجموعة المراد تحديثها.
    /// Identifier of the group to update.
    /// </summary>
    public string GroupId { get; set; } = string.Empty;

    /// <summary>
    /// اسم المجموعة الداخلي.
    /// Internal group name.
    /// </summary>
    public string GroupName { get; set; } = string.Empty;

    /// <summary>
    /// الاسم المعروض للمجموعة.
    /// Display name of the group.
    /// </summary>
    public string DisplayName { get; set; } = string.Empty;

    /// <summary>
    /// وصف المجموعة.
    /// Group description.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int SortOrder { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المجموعة قابلة للطي.
    /// Indicates whether the group can be collapsed.
    /// </summary>
    public bool IsCollapsible { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المجموعة موسعة افتراضيًا.
    /// Indicates whether the group is expanded by default.
    /// </summary>
    public bool IsExpandedByDefault { get; set; }
}
