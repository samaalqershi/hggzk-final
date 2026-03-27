using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Policies.Commands.DeleteProperty;

/// <summary>
/// يمثل طلب حذف سياسة خاصة بعقار.
/// Deletes an existing policy for a property.
/// </summary>
public class DeletePropertyPolicyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف السياسة.
    /// policy identifier.
    /// </summary>
    public Guid PolicyId { get; set; }
} 
