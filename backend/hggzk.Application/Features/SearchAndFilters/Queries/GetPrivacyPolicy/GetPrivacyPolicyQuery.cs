using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetPrivacyPolicy;

/// <summary>
/// استعلام جلب الخصوصية policy.
/// Get Privacy Policy query.
/// </summary>
public class GetPrivacyPolicyQuery : IRequest<ResultDto<LegalDocumentDto>>
{
    /// <summary>
    /// القيمة الخاصة بـ language.
    /// Language value.
    /// </summary>
    public string Language { get; set; } = "ar";
}

// LegalDocumentDto تم تعريفه مسبقًا