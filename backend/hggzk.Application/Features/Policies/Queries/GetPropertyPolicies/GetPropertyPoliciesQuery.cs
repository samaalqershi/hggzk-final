using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Policies.Queries.GetPropertyPolicies;

/// <summary>
/// يمثل استعلام جلب سياسات عقار محدد.
/// Retrieves the policies for a specific property.
/// </summary>
public class GetPropertyPoliciesQuery : IRequest<ResultDto<IEnumerable<PolicyDto>>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
}
