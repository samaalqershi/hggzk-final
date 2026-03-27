namespace YemenBooking.Application.Features.DynamicFields.Commands.ManageFieldGroups;

using global::YemenBooking.Application.Common.Models;
using MediatR;
using Unit = MediatR.Unit;

/// <summary>
/// يحذف مجموعة حقول.
/// Deletes a field group.
/// </summary>
public class DeleteFieldGroupCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرف المجموعة المراد حذفها.
    /// Identifier of the group to delete.
    /// </summary>
    public string GroupId { get; set; }
} 
