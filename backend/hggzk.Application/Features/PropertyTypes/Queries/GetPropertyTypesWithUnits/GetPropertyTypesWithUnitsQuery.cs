using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyTypes.DTOs;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypesWithUnits
{
    /// <summary>
    /// يمثل استعلام جلب أنواع العقارات مع أنواع الوحدات.
    /// Retrieves property types together with their unit types.
    /// </summary>
    public class GetPropertyTypesWithUnitsQuery : IRequest<ResultDto<List<PropertyTypeWithUnitsDto>>>
    {
    }
}
