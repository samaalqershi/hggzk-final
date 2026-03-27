using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Policies.Queries.GetPolicyById;

/// <summary>
/// يجلب تفاصيل سياسة محددة.
/// Retrieves a specific policy by its identifier.
/// </summary>
public class GetPolicyByIdQuery : IRequest<ResultDto<PolicyDetailsDto>>
{
    /// <summary>
    /// معرّف السياسة.
    /// Policy identifier.
    /// </summary>
    public Guid PolicyId { get; set; }
} 
