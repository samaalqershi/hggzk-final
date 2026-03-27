using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common;
using System;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetTermsAndConditions;

/// <summary>
/// استعلام جلب الشروط and conditions.
/// Get Terms And Conditions query.
/// </summary>
public class GetTermsAndConditionsQuery : IRequest<ResultDto<LegalDocumentDto>>
{
    /// <summary>
    /// القيمة الخاصة بـ language.
    /// Language value.
    /// </summary>
    public string Language { get; set; } = "ar";
}