namespace YemenBooking.Application.Features.DynamicFields.Commands.ManageFieldGroups;

using global::YemenBooking.Application.Common.Models;
using MediatR;
using Unit = MediatR.Unit;

/// <summary>
/// ينشئ مجموعة حقول جديدة لنوع وحدة محدد.
/// Creates a new field group for a specific unit type.
/// </summary>
public class CreateFieldGroupCommand : IRequest<ResultDto<string>>
{
    /// <summary>
    /// معرف نوع الوحدة المستهدف.
    /// Target unit type identifier.
    /// </summary>
    public string unitTypeId { get; set; } = string.Empty;

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
    /// الاسم المعروض للمجموعة بالإنجليزية.
    /// English display name of the group.
    /// </summary>
    public string? DisplayNameEn { get; set; }

    /// <summary>
    /// وصف المجموعة.
    /// Group description.
    /// </summary>
    public string Description { get; set; } = string.Empty;
    /// <summary>
    /// وصف المجموعة بالإنجليزية.
    /// English group description.
    /// </summary>
    public string? DescriptionEn { get; set; }

    /// <summary>
    /// اسم المجموعة بالإنجليزية.
    /// English internal group name.
    /// </summary>
    public string? GroupNameEn { get; set; }

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int SortOrder { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المجموعة قابلة للطي.
    /// Indicates whether the group can be collapsed.
    /// </summary>
    public bool IsCollapsible { get; set; } = true;

    /// <summary>
    /// يحدد ما إذا كانت المجموعة موسعة افتراضيًا.
    /// Indicates whether the group is expanded by default.
    /// </summary>
    public bool IsExpandedByDefault { get; set; } = true;
}
