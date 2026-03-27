using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.PropertyServices.Commands.CreateProperty;

/// <summary>
/// يمثل طلب إنشاء خدمة مرتبطة بعقار.
/// Creates a service entry for a property.
/// </summary>
public class CreatePropertyServiceCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// الاسم.
    /// name.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    /// <summary>
    /// السعر.
    /// price.
    /// </summary>
    public MoneyDto Price { get; set; }
    /// <summary>
    /// نموذج التسعير.
    /// pricing model.
    /// </summary>
    public PricingModel PricingModel { get; set; }
    /// <summary>
    /// الأيقونة.
    /// icon.
    /// </summary>
    public string Icon { get; set; } = string.Empty;
    /// <summary>
    /// الوصف.
    /// description.
    /// </summary>
    public string? Description { get; set; }
} 
