using YemenBooking.Application.Common.Helpers;
using YemenBooking.Core.Indexing.Enums;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs;

/// <summary>
/// استراتيجية البحث المطبقة
/// Applied Search Strategy DTO
/// </summary>
public class SearchStrategyDto
{
    /// <summary>
    /// مستوى التخفيف
    /// Relaxation level
    /// </summary>
    public SearchRelaxationLevel Level { get; set; }

    /// <summary>
    /// اسم الاستراتيجية (بالعربية)
    /// Strategy name (Arabic)
    /// </summary>
    public string StrategyName { get; set; } = string.Empty;

    /// <summary>
    /// اسم الاستراتيجية (بالإنجليزية)
    /// Strategy name (English)
    /// </summary>
    public string StrategyNameEn { get; set; } = string.Empty;

    /// <summary>
    /// وصف الاستراتيجية
    /// Strategy description
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// رسالة للمستخدم
    /// Message to user
    /// </summary>
    public string? UserMessage { get; set; }

    /// <summary>
    /// اقتراحات لتحسين البحث
    /// Suggestions to improve search
    /// </summary>
    public List<string> SuggestedActions { get; set; } = new();

    /// <summary>
    /// معلومات التخفيف التفصيلية
    /// Detailed relaxation info
    /// </summary>
    public SearchRelaxationInfoDto? RelaxationInfo { get; set; }

    /// <summary>
    /// إنشاء استراتيجية من مستوى معين
    /// Create strategy from level
    /// </summary>
    public static SearchStrategyDto FromLevel(SearchRelaxationLevel level)
    {
        return level switch
        {
            SearchRelaxationLevel.Exact => new SearchStrategyDto
            {
                Level = level,
                StrategyName = "تطابق دقيق",
                StrategyNameEn = "Exact Match",
                Description = LocalizedText.Choose(
                    "جميع معايير البحث مطابقة تماماً",
                    "All search criteria match exactly")
            },
            SearchRelaxationLevel.MinorRelaxation => new SearchStrategyDto
            {
                Level = level,
                StrategyName = "تخفيف بسيط",
                StrategyNameEn = "Minor Relaxation",
                Description = LocalizedText.Choose(
                    "توسيع طفيف في معايير البحث (15-20%)",
                    "A slight expansion of the search criteria (15-20%)")
            },
            SearchRelaxationLevel.ModerateRelaxation => new SearchStrategyDto
            {
                Level = level,
                StrategyName = "تخفيف متوسط",
                StrategyNameEn = "Moderate Relaxation",
                Description = LocalizedText.Choose(
                    "توسيع متوسط في معايير البحث (30-40%)",
                    "A moderate expansion of the search criteria (30-40%)")
            },
            SearchRelaxationLevel.MajorRelaxation => new SearchStrategyDto
            {
                Level = level,
                StrategyName = "تخفيف كبير",
                StrategyNameEn = "Major Relaxation",
                Description = LocalizedText.Choose(
                    "توسيع كبير في معايير البحث (50%+)",
                    "A major expansion of the search criteria (50%+)")
            },
            SearchRelaxationLevel.AlternativeSuggestions => new SearchStrategyDto
            {
                Level = level,
                StrategyName = "اقتراحات بديلة",
                StrategyNameEn = "Alternative Suggestions",
                Description = LocalizedText.Choose(
                    "عرض خيارات بديلة بمعايير أساسية",
                    "Showing alternative options with core criteria")
            },
            _ => new SearchStrategyDto
            {
                Level = SearchRelaxationLevel.Exact,
                StrategyName = "تطابق دقيق",
                StrategyNameEn = "Exact Match",
                Description = LocalizedText.Choose("افتراضي", "Default")
            }
        };
    }
}
