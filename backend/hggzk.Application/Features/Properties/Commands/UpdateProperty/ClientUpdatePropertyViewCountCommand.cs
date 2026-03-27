using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.UpdateProperty;

/// <summary>
/// طلب زيادة عدد مشاهدات العقار.
/// Request to increment a property view count.
/// </summary>
public class ClientUpdatePropertyViewCountCommand : IRequest<ResultDto<bool>>
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
    /// عنوان IP.
    /// IP address.
    /// </summary>
    public string? IpAddress { get; set; }
    /// <summary>
    /// معرّف الجلسة.
    /// session identifier.
    /// </summary>
    public string? SessionId { get; set; }
    /// <summary>
    /// وقت المشاهدة.
    /// viewed at.
    /// </summary>
    public DateTime ViewedAt { get; set; } = DateTime.UtcNow;
}
