using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetAllUnitTypes
{
    /// <summary>
    /// يجلب جميع أنواع الوحدات.
    /// Retrieves all unit types.
    /// </summary>
    public class GetAllUnitTypesQuery : IRequest<PaginatedResult<UnitTypeDto>>
    {
        /// <summary>
        /// رقم الصفحة المطلوبة.
        /// Requested page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// عدد العناصر في الصفحة.
        /// Number of items per page.
        /// </summary>
        public int PageSize { get; set; } = 10;

        /// <summary>
        /// عبارة البحث.
        /// Search term.
        /// </summary>
        public string? SearchTerm { get; set; }
    }
} 
