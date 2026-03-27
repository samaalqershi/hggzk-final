using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using System;

namespace YemenBooking.Application.Features.PropertyServices.Queries.GetServicesByType;

/// <summary>
/// يمثل Get Services By Type استعلامًا.
/// Represents a Get Services By Type query.
/// </summary>
public class GetServicesByTypeQuery : IRequest<PaginatedResult<ServiceDto>>
{
    /// <summary>
    /// نوع الخدمة.
    /// Service type.
    /// </summary>
    public string ServiceType { get; set; } = string.Empty;

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
} 
