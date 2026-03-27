using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyTypes.Commands.DeleteProperty;

/// <summary>
/// يمثل طلب حذف نوع عقار.
/// Deletes an existing property type.
/// </summary>
public class DeletePropertyTypeCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف نوع العقار.
    /// property type identifier.
    /// </summary>
    public Guid PropertyTypeId { get; set; }
} 
