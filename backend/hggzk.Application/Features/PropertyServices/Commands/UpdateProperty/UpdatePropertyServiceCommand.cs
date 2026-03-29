using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.PropertyServices.Commands.UpdateProperty;

/// <summary>
/// يمثل طلب تحديث خدمة مرتبطة بعقار.
/// Updates an existing property service.
/// </summary>
public class UpdatePropertyServiceCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الخدمة.
    /// service identifier.
    /// </summary>
    public Guid ServiceId { get; set; }
    /// <summary>
    /// الاسم.
    /// name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// الاسم بالإنجليزية.
    /// English name.
    /// </summary>
    public string? NameEn { get; set; }
    /// <summary>
    /// الأيقونة.
    /// icon.
    /// </summary>
    public string Icon { get; set; } = string.Empty;
    /// <summary>
    /// السعر.
    /// price.
    /// </summary>
    public MoneyDto? Price { get; set; }
    /// <summary>
    /// نموذج التسعير.
    /// pricing model.
    /// </summary>
    public PricingModel? PricingModel { get; set; }
    /// <summary>
    /// الوصف.
    /// description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// الوصف بالإنجليزية.
    /// English description.
    /// </summary>
    public string? DescriptionEn { get; set; }
}
