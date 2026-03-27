using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Features.Sections.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetSectionById
{
    /// <summary>
    /// استعلام جلب القسم by المعرف.
    /// Get Section By Id query.
    /// </summary>
    public class GetSectionByIdQuery : IRequest<ResultDto<SectionDto>>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid SectionId { get; set; }
    }
}

