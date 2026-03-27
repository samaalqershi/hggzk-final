using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Staffs.Commands.ManageStaff
{
    /// <summary>
    /// أمر add الموظف.
    /// Add Staff command.
    /// </summary>
    public class AddStaffCommand : IRequest<ResultDto<Guid>>
    {
        /// <summary>
        /// معرّف المستخدم.
        /// User identifier.
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid PropertyId { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ position.
        /// Position value.
        /// </summary>
        public StaffPosition Position { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ permissions.
        /// Permissions value.
        /// </summary>
        public string Permissions { get; set; }
    }
} 