using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetFAQs;

/// <summary>
/// استعلام جلب fa qs.
/// Get FA Qs query.
/// </summary>
public class GetFAQsQuery : IRequest<ResultDto<List<FAQCategoryDto>>>
{
    /// <summary>
    /// القيمة الخاصة بـ language.
    /// Language value.
    /// </summary>
    public string Language { get; set; } = "ar";
    
    /// <summary>
    /// القيمة الخاصة بـ category.
    /// Category value.
    /// </summary>
    public string? Category { get; set; }
}

/// <summary>
/// استعلام جلب fa qs.
/// Get FA Qs query.
/// </summary>
public class FAQCategoryDto
{
    /// <summary>
    /// اسم category.
    /// Category name.
    /// </summary>
    public string CategoryName { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ category الأيقونة.
    /// Category Icon value.
    /// </summary>
    public string? CategoryIcon { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ questions.
    /// Questions value.
    /// </summary>
    public List<FAQItemDto> Questions { get; set; } = new();
}

/// <summary>
/// استعلام جلب fa qs.
/// Get FA Qs query.
/// </summary>
public class FAQItemDto
{
    /// <summary>
    /// المعرف.
    /// Identifier.
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ question.
    /// Question value.
    /// </summary>
    public string Question { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ answer.
    /// Answer value.
    /// </summary>
    public string Answer { get; set; } = string.Empty;
    
    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; }
    
    /// <summary>
    /// عدد helpful.
    /// Helpful count.
    /// </summary>
    public int HelpfulCount { get; set; }
    
    /// <summary>
    /// عدد not helpful.
    /// Not Helpful count.
    /// </summary>
    public int NotHelpfulCount { get; set; }
}