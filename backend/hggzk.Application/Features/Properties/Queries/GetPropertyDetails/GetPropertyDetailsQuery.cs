using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Queries.GetPropertyDetails;

/// <summary>
/// استعلام الحصول على تفاصيل العقار مع خيارات التضمين.
/// Query for retrieving property details with inclusion options.
/// </summary>
public class GetPropertyDetailsQuery : IRequest<ResultDto<PropertyDetailsDto>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// معرّف المستخدم.
    /// user identifier.
    /// </summary>
    public Guid? UserId { get; set; }
    /// <summary>
    /// دور المستخدم.
    /// user role.
    /// </summary>
    public string? UserRole { get; set; }
    /// <summary>
    /// تضمين الوحدات.
    /// include units.
    /// </summary>
    public bool IncludeUnits { get; set; } = true;
    /// <summary>
    /// تضمين الحقول الديناميكية.
    /// include dynamic fields.
    /// </summary>
    public bool IncludeDynamicFields { get; set; } = true;

}
