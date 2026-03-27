using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ApproveProperty;

/// <summary>
/// طلب اعتماد العقار.
/// Request to approve property.
/// </summary>
public class ApprovePropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// معرّف المشرف.
    /// administrator identifier.
    /// </summary>
    public Guid AdminId { get; set; }
} 
