using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypes;

/// <summary>
/// يمثل استعلام جلب أنواع العقارات.
/// Retrieves property types.
/// </summary>
public class GetPropertyTypesQuery : IRequest<ResultDto<List<PropertyTypeDto>>>
{
    // لا توجد معلمات خاصة بهذا الاستعلام
}
