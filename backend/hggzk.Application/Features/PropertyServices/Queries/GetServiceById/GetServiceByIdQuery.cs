using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using System;

namespace YemenBooking.Application.Features.PropertyServices.Queries.GetServiceById;

/// <summary>
/// يمثل Get Service By Id استعلامًا.
/// Represents a Get Service By Id query.
/// </summary>
public class GetServiceByIdQuery : IRequest<ResultDto<ServiceDetailsDto>>
{
    /// <summary>
    /// معرّف الخدمة.
    /// Service identifier.
    /// </summary>
    public Guid ServiceId { get; set; }
} 
