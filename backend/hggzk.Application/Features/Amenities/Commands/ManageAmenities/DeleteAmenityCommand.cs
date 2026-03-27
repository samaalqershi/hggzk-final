using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class DeleteAmenityCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرف المرفق
    /// Amenity identifier
    /// </summary>
    public Guid AmenityId { get; set; }
} 