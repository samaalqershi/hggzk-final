namespace YemenBooking.Application.Features.DynamicFields.Commands.DeleteUnit;

using MediatR;
using YemenBooking.Application.Common.Models;
using Unit = MediatR.Unit;

/// <summary>
/// يحذف حقلًا ديناميكيًا من نوع الوحدة.
/// Deletes a dynamic field from a unit type.
/// </summary>
public class DeleteUnitTypeFieldCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرف الحقل المراد حذفه.
    /// Identifier of the field to delete.
    /// </summary>
    public string FieldId { get; set; }
} 
