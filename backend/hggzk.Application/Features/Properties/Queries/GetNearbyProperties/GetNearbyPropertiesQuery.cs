using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetNearbyProperties;

/// <summary>
/// استعلام للحصول على العقارات القريبة من موقع محدد.
/// Query for retrieving nearby properties around a specified location.
/// </summary>
public class GetNearbyPropertiesQuery : IRequest<ResultDto<List<NearbyPropertyDto>>>
{
    /// <summary>
    /// خط العرض.
    /// latitude.
    /// </summary>
    public decimal Latitude { get; set; }
    /// <summary>
    /// خط الطول.
    /// longitude.
    /// </summary>
    public decimal Longitude { get; set; }
    /// <summary>
    /// نصف القطر بالكيلومترات.
    /// radius in kilometers.
    /// </summary>
    public double RadiusKm { get; set; } = 10;
    /// <summary>
    /// أقصى عدد للنتائج.
    /// maximum results.
    /// </summary>
    public int MaxResults { get; set; } = 20;
    /// <summary>
    /// معرّف نوع العقار.
    /// property type identifier.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }
}
