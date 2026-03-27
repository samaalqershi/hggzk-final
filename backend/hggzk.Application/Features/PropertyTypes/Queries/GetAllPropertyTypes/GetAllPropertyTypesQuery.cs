using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetAllPropertyTypes
{
    /// <summary>
    /// يمثل استعلام جلب جميع أنواع العقارات.
    /// Retrieves all property types.
    /// </summary>
    public class GetAllPropertyTypesQuery : IRequest<PaginatedResult<PropertyTypeDto>>
    {
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
