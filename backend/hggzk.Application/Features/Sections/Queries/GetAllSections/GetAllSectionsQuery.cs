using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Features.Sections.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetAllSections
{
    /// <summary>
    /// استعلام جلب all الأقسام.
    /// Get All Sections query.
    /// </summary>
    public class GetAllSectionsQuery : IRequest<IEnumerable<SectionDto>>
    {
    }
}

