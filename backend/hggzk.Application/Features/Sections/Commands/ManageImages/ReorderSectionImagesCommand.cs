using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Features.Properties.Commands.ManageImages;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// أمر reorder القسم الصور.
    /// Reorder Section Images command.
    /// </summary>
    public class ReorderSectionImagesCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// القيمة الخاصة بـ assignments.
        /// Assignments value.
        /// </summary>
        public List<ImageOrderAssignment> Assignments { get; set; } = new List<ImageOrderAssignment>();
    }
}

