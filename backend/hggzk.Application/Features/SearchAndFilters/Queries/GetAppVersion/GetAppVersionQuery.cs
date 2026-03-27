using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetAppVersion;

/// <summary>
/// استعلام جلب app الإصدار.
/// Get App Version query.
/// </summary>
public class GetAppVersionQuery : IRequest<ResultDto<AppVersionDto>>
{
    /// <summary>
    /// المنصة.
    /// Platform.
    /// </summary>
    public string Platform { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ الحالي الإصدار.
    /// Current Version value.
    /// </summary>
    public string CurrentVersion { get; set; } = string.Empty;
}

/// <summary>
/// استعلام جلب app الإصدار.
/// Get App Version query.
/// </summary>
public class AppVersionDto
{
    /// <summary>
    /// القيمة الخاصة بـ latest الإصدار.
    /// Latest Version value.
    /// </summary>
    public string LatestVersion { get; set; } = string.Empty;
    
    /// <summary>
    /// الحد الأدنى لـ imum required الإصدار.
    /// Minimum imum required version.
    /// </summary>
    public string MinimumRequiredVersion { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ تحديث required.
    /// Update Required value.
    /// </summary>
    public bool UpdateRequired { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ تحديث المتاح.
    /// Update Available value.
    /// </summary>
    public bool UpdateAvailable { get; set; }
    
    /// <summary>
    /// رابط تحديث.
    /// Update URL.
    /// </summary>
    public string? UpdateUrl { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ release الملاحظات.
    /// Release Notes value.
    /// </summary>
    public string? ReleaseNotes { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ release الملاحظات ar.
    /// Release Notes Ar value.
    /// </summary>
    public string? ReleaseNotesAr { get; set; }
}