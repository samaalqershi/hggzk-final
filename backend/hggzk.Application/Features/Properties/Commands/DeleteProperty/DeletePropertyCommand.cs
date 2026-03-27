using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.DeleteProperty;

/// <summary>
/// طلب حذف العقار.
/// Request to delete property.
/// </summary>
public class DeletePropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
} 
