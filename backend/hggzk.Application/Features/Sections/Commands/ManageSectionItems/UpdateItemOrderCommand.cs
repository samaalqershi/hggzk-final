using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// أمر تحديث العنصر الترتيب.
    /// Update Item Order command.
    /// </summary>
    public class UpdateItemOrderCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid SectionId { get; set; }
        /// <summary>
        /// الترتيبات.
        /// Orders.
        /// </summary>
        public List<ItemOrder> Orders { get; set; } = new();
    }

    /// <summary>
    /// أمر تحديث العنصر الترتيب.
    /// Update Item Order command.
    /// </summary>
    public class ItemOrder
    {
        /// <summary>
        /// معرّف العنصر.
        /// Item identifier.
        /// </summary>
        public Guid ItemId { get; set; }
        /// <summary>
        /// ترتيب الفرز.
        /// Sort order.
        /// </summary>
        public int SortOrder { get; set; }
    }
}
