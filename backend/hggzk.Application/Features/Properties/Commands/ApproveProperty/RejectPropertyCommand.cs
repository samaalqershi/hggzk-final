using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ApproveProperty;

/// <summary>
/// طلب رفض العقار.
/// Request to reject property.
/// </summary>
public class RejectPropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// السبب.
    /// reason.
    /// </summary>
    public string Reason { get; set; } = string.Empty;

    /// <summary>
    /// معرّف المشرف.
    /// administrator identifier.
    /// </summary>
    public Guid AdminId { get; set; }
} 
