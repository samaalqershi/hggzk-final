using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetFAQs;

/// <summary>
/// يعالج جلب fa qs ويعيد النتيجة المطلوبة.
/// Processes the Get FA Qs request and returns the requested result.
/// </summary>
public class GetFAQsQueryHandler : IRequestHandler<GetFAQsQuery, ResultDto<List<FAQCategoryDto>>>
{
    private readonly IFAQRepository _faqRepository;
    private readonly ILogger<GetFAQsQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetFAQsQueryHandler.
    /// Initializes a new instance of GetFAQsQueryHandler.
    /// </summary>
    /// <param name="faqRepository">مستودع الأسئلة الشائعة / faq repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public GetFAQsQueryHandler(
        IFAQRepository faqRepository,
        ILogger<GetFAQsQueryHandler> logger)
    {
        _faqRepository = faqRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<List<FAQCategoryDto>>> Handle(GetFAQsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام الأسئلة الشائعة. اللغة: {Language}, الفئة: {Category}", 
                request.Language, request.Category ?? "جميع الفئات");

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // تطبيع اللغة
            var language = NormalizeLanguage(request.Language);

            // الحصول على الأسئلة الشائعة
            var faqs = await _faqRepository.GetActiveFAQsAsync(language, request.Category, cancellationToken);

            if (faqs == null || !faqs.Any())
            {
                _logger.LogInformation("لم يتم العثور على أسئلة شائعة للفئة: {Category}", request.Category ?? "جميع الفئات");
                
                return ResultDto<List<FAQCategoryDto>>.Ok(
                    new List<FAQCategoryDto>(), 
                    "لا توجد أسئلة شائعة متاحة حالياً"
                );
            }

            // تجميع الأسئلة حسب الفئات
            var categorizedFAQs = GroupFAQsByCategory(faqs);

            // ترتيب الفئات والأسئلة
            var sortedCategories = categorizedFAQs
                .OrderBy(c => GetCategoryDisplayOrder(c.CategoryName))
                .ThenBy(c => c.CategoryName)
                .ToList();

            foreach (var category in sortedCategories)
            {
                category.Questions = category.Questions
                    .OrderBy(q => q.DisplayOrder)
                    .ThenBy(q => q.Question)
                    .ToList();
            }

            _logger.LogInformation("تم الحصول على {CategoriesCount} فئة تحتوي على {QuestionsCount} سؤال شائع", 
                sortedCategories.Count, sortedCategories.Sum(c => c.Questions.Count));

            return ResultDto<List<FAQCategoryDto>>.Ok(
                sortedCategories, 
                $"تم الحصول على {sortedCategories.Sum(c => c.Questions.Count)} سؤال شائع في {sortedCategories.Count} فئة"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على الأسئلة الشائعة. اللغة: {Language}", request.Language);
            return ResultDto<List<FAQCategoryDto>>.Failed(
                $"حدث خطأ أثناء الحصول على الأسئلة الشائعة: {ex.Message}", 
                "GET_FAQS_ERROR"
            );
        }
    }

    private ResultDto<List<FAQCategoryDto>> ValidateRequest(GetFAQsQuery request)
    {
        if (string.IsNullOrWhiteSpace(request.Language))
        {
            _logger.LogWarning("اللغة مطلوبة");
            return ResultDto<List<FAQCategoryDto>>.Failed("اللغة مطلوبة", "LANGUAGE_REQUIRED");
        }

        // التحقق من دعم اللغة
        var supportedLanguages = new[] { "ar", "en", "arabic", "english" };
        var normalizedLanguage = NormalizeLanguage(request.Language);
        
        if (!supportedLanguages.Contains(normalizedLanguage.ToLower()))
        {
            _logger.LogWarning("اللغة غير مدعومة: {Language}", request.Language);
            return ResultDto<List<FAQCategoryDto>>.Failed("اللغة غير مدعومة", "UNSUPPORTED_LANGUAGE");
        }

        return ResultDto<List<FAQCategoryDto>>.Ok(null, "البيانات صحيحة");
    }

    private string NormalizeLanguage(string language)
    {
        return language.ToLower().Trim() switch
        {
            "ar" or "arabic" or "عربي" => "ar",
            "en" or "english" or "إنجليزي" => "en",
            _ => "ar" // افتراضي العربية
        };
    }

    private List<FAQCategoryDto> GroupFAQsByCategory(IEnumerable<Core.Entities.FAQ> faqs)
    {
        var groupedFAQs = faqs
            .GroupBy(f => f.Category ?? "عام")
            .Select(group => new FAQCategoryDto
            {
                CategoryName = group.Key,
                CategoryIcon = GetCategoryIcon(group.Key),
                Questions = group.Select(faq => new FAQItemDto
                {
                    Id = faq.Id,
                    Question = faq.Question ?? string.Empty,
                    Answer = faq.Answer ?? string.Empty,
                    DisplayOrder = faq.DisplayOrder,
                    HelpfulCount = 0,
                    NotHelpfulCount = 0
                }).ToList()
            })
            .ToList();

        return groupedFAQs;
    }

    private string? GetCategoryIcon(string categoryName)
    {
        return categoryName.ToLower() switch
        {
            "حجوزات" or "booking" => "📅",
            "دفع" or "payment" => "💳",
            "حساب" or "account" => "👤",
            "عام" or "general" => "❓",
            "تقني" or "technical" => "🔧",
            "سياسات" or "policies" => "📋",
            "خدمة العملاء" or "support" => "🎧",
            "عقارات" or "properties" => "🏨",
            _ => "❓"
        };
    }

    private int GetCategoryDisplayOrder(string categoryName)
    {
        return categoryName.ToLower() switch
        {
            "عام" or "general" => 1,
            "حجوزات" or "booking" => 2,
            "عقارات" or "properties" => 3,
            "دفع" or "payment" => 4,
            "حساب" or "account" => 5,
            "سياسات" or "policies" => 6,
            "تقني" or "technical" => 7,
            "خدمة العملاء" or "support" => 8,
            _ => 999
        };
    }
}
