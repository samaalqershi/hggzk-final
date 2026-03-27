using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Staffs.Commands.ManageStaff;

/// <summary>
/// أمر تحديث الموظف.
/// Update Staff command.
/// </summary>
public class UpdateStaffCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الموظف.
    /// Staff identifier.
    /// </summary>
    public Guid StaffId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ position.
    /// Position value.
    /// </summary>
    public StaffPosition? Position { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ permissions.
    /// Permissions value.
    /// </summary>
    public string? Permissions { get; set; }
} 