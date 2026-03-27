using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Staffs.Commands.ManageStaff
{
    /// <summary>
    /// أمر إزالة الموظف.
    /// Remove Staff command.
    /// </summary>
    public class RemoveStaffCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الموظف.
        /// Staff identifier.
        /// </summary>
        public Guid StaffId { get; set; }
    }
} 