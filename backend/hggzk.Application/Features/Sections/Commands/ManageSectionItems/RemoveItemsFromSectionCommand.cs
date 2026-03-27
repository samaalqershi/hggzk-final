using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// أمر إزالة العناصر from القسم.
    /// Remove Items From Section command.
    /// </summary>
    public class RemoveItemsFromSectionCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid SectionId { get; set; }
        /// <summary>
        /// معرّفات العنصر.
        /// Item identifiers.
        /// </summary>
        public List<Guid> ItemIds { get; set; } = new();
    }
}

