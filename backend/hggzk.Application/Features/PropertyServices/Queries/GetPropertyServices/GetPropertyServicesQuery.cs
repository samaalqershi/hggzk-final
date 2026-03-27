using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using System;

namespace YemenBooking.Application.Features.PropertyServices.Queries.GetPropertyServices;

/// <summary>
/// يمثل استعلام جلب خدمات عقار محدد.
/// Retrieves the services of a specific property.
/// </summary>
public class GetPropertyServicesQuery : IRequest<ResultDto<IEnumerable<ServiceDto>>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
} 
