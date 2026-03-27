using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Features.Sections.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetActiveSectionsForHome
{
    /// <summary>
    /// استعلام جلب النشاط الأقسام for الرئيسية.
    /// Get Active Sections For Home query.
    /// </summary>
    public class GetActiveSectionsForHomeQuery : IRequest<IEnumerable<SectionDto>>
    {
        /// <summary>
        /// اسم المدينة.
        /// City name.
        /// </summary>
        public string? CityName { get; set; }
    }
}

