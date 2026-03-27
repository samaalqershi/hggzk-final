using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.DeleteUnit
{
    /// <summary>
    /// أمر حذف الوحدة in القسم الصورة.
    /// Delete Unit In Section Image command.
    /// </summary>
    public class DeleteUnitInSectionImageCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// Image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
        /// <summary>
        /// القيمة الخاصة بـ permanent.
        /// Permanent value.
        /// </summary>
        public bool Permanent { get; set; } = false;
    }
}

