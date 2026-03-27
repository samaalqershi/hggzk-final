using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// أمر add العناصر to القسم.
    /// Add Items To Section command.
    /// </summary>
    public class AddItemsToSectionCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid SectionId { get; set; }
        /// <summary>
        /// معرّفات العقار.
        /// Property identifiers.
        /// </summary>
        public List<Guid> PropertyIds { get; set; } = new();
        /// <summary>
        /// معرّفات الوحدة.
        /// Unit identifiers.
        /// </summary>
        public List<Guid> UnitIds { get; set; } = new();
    }
}

