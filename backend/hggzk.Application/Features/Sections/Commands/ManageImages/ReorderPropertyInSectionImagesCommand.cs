using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.Commands.ManageImages;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// أمر reorder العقار in القسم الصور.
    /// Reorder Property In Section Images command.
    /// </summary>
    public class ReorderPropertyInSectionImagesCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// القيمة الخاصة بـ assignments.
        /// Assignments value.
        /// </summary>
        public List<ImageOrderAssignment> Assignments { get; set; } = new List<ImageOrderAssignment>();
    }
}

