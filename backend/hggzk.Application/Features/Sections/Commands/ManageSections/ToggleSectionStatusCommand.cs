using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
    /// <summary>
    /// أمر toggle القسم الحالة.
    /// Toggle Section Status command.
    /// </summary>
    public class ToggleSectionStatusCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid SectionId { get; set; }
        /// <summary>
        /// يشير إلى ما إذا كان العنصر نشطًا.
        /// Indicates whether the item is active.
        /// </summary>
        public bool IsActive { get; set; }
    }
}

