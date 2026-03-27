using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetUnitTypes
{
    /// <summary>
    /// يمثل استعلام جلب أنواع الوحدات حسب نوع العقار.
    /// Retrieves unit types for a specific property type.
    /// </summary>
    public class GetUnitTypesByPropertyTypeQuery : IRequest<PaginatedResult<UnitTypeDto>>
    {
        /// <summary>
        /// معرّف نوع العقار.
        /// property type identifier.
        /// </summary>
        public Guid PropertyTypeId { get; set; }

        /// <summary>
        /// رقم الصفحة.
        /// page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة.
        /// page size.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }
} 
