using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetPrivacyPolicy;

/// <summary>
/// يعالج جلب الخصوصية policy ويعيد النتيجة المطلوبة.
/// Processes the Get Privacy Policy request and returns the requested result.
/// </summary>
public class GetPrivacyPolicyQueryHandler : IRequestHandler<GetPrivacyPolicyQuery, ResultDto<LegalDocumentDto>>
{
    private readonly ILegalDocumentRepository _legalDocumentRepository;
    private readonly ILogger<GetPrivacyPolicyQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetPrivacyPolicyQueryHandler.
    /// Initializes a new instance of GetPrivacyPolicyQueryHandler.
    /// </summary>
    /// <param name="legalDocumentRepository">مستودع القانوني المستند / legal Document repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    public GetPrivacyPolicyQueryHandler(
        ILegalDocumentRepository legalDocumentRepository,
        ILogger<GetPrivacyPolicyQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _legalDocumentRepository = legalDocumentRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<LegalDocumentDto>> Handle(GetPrivacyPolicyQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام سياسة الخصوصية. اللغة: {Language}", request.Language);

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // تطبيع اللغة
            var language = NormalizeLanguage(request.Language);

            // الحصول على سياسة الخصوصية من قاعدة البيانات
            var privacyPolicy = await _legalDocumentRepository.GetByTypeAndLanguageAsync(LegalDocumentType.PrivacyPolicy, language, cancellationToken);

            if (privacyPolicy == null)
            {
                _logger.LogWarning("لم يتم العثور على سياسة الخصوصية باللغة: {Language}", language);

                // محاولة الحصول على النسخة العربية كبديل
                if (language != "ar")
                {
                    privacyPolicy = await _legalDocumentRepository.GetByTypeAndLanguageAsync(
                        LegalDocumentType.PrivacyPolicy, "ar", cancellationToken);
                }

                // إذا لم توجد أي نسخة، إنشاء محتوى افتراضي
                if (privacyPolicy == null)
                {
                    _logger.LogWarning("لم يتم العثور على سياسة الخصوصية، إنشاء محتوى افتراضي");
                    
                    var defaultPrivacyPolicy = CreateDefaultPrivacyPolicy(language);
                    return ResultDto<LegalDocumentDto>.Ok(
                        defaultPrivacyPolicy, 
                        "تم إرجاع سياسة الخصوصية الافتراضية"
                    );
                }
            }

            // التحقق من أن المستند نشط
            if (!privacyPolicy.IsActive)
            {
                _logger.LogWarning("سياسة الخصوصية غير نشطة");
                
                var defaultPrivacyPolicy = CreateDefaultPrivacyPolicy(language);
                return ResultDto<LegalDocumentDto>.Ok(
                    defaultPrivacyPolicy, 
                    "سياسة الخصوصية الحالية غير نشطة، تم إرجاع النسخة الافتراضية"
                );
            }

            // إنشاء DTO للاستجابة
            var privacyPolicyDto = new LegalDocumentDto
            {
                Title = privacyPolicy.Title ?? GetDefaultTitle(language),
                Content = privacyPolicy.Content ?? GetDefaultContent(language),
                Version = privacyPolicy.Version ?? "1.0",
                LastUpdated = await _currentUserService.ConvertFromUtcToUserLocalAsync((privacyPolicy.UpdatedAt ?? privacyPolicy.CreatedAt)),
                // EffectiveDate = privacyPolicy.EffectiveDate // خاصية غير متوفرة في DTO
            };

            _logger.LogInformation("تم الحصول على سياسة الخصوصية بنجاح. الإصدار: {Version}, آخر تحديث: {LastUpdated}", 
                privacyPolicyDto.Version, privacyPolicyDto.LastUpdated);

            return ResultDto<LegalDocumentDto>.Ok(
                privacyPolicyDto, 
                "تم الحصول على سياسة الخصوصية بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على سياسة الخصوصية. اللغة: {Language}", request.Language);
            return ResultDto<LegalDocumentDto>.Failed(
                $"حدث خطأ أثناء الحصول على سياسة الخصوصية: {ex.Message}", 
                "GET_PRIVACY_POLICY_ERROR"
            );
        }
    }

    private ResultDto<LegalDocumentDto> ValidateRequest(GetPrivacyPolicyQuery request)
    {
        if (string.IsNullOrWhiteSpace(request.Language))
        {
            _logger.LogWarning("اللغة مطلوبة");
            return ResultDto<LegalDocumentDto>.Failed("اللغة مطلوبة", "LANGUAGE_REQUIRED");
        }

        var normalizedLanguage = NormalizeLanguage(request.Language);
        var supportedLanguages = new[] { "ar", "en" };
        
        if (!supportedLanguages.Contains(normalizedLanguage))
        {
            _logger.LogWarning("اللغة غير مدعومة: {Language}", request.Language);
            return ResultDto<LegalDocumentDto>.Failed(
                $"اللغة '{request.Language}' غير مدعومة. اللغات المدعومة: {string.Join(", ", supportedLanguages)}", 
                "UNSUPPORTED_LANGUAGE"
            );
        }

        return ResultDto<LegalDocumentDto>.Ok(null, "البيانات صحيحة");
    }

    private string NormalizeLanguage(string language)
    {
        return language.ToLowerInvariant().Trim() switch
        {
            "ar" or "arabic" or "عربي" => "ar",
            "en" or "english" or "انجليزي" => "en",
            _ => "ar" // العربية كلغة افتراضية
        };
    }

    private LegalDocumentDto CreateDefaultPrivacyPolicy(string language)
    {
        var dto = new LegalDocumentDto
        {
            Title = GetDefaultTitle(language),
            Content = GetDefaultContent(language),
            Version = "1.0",
            LastUpdated = DateTime.UtcNow,
        };
        // Convert default LastUpdated for presentation
        dto.LastUpdated = _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastUpdated).GetAwaiter().GetResult();
        return dto;
    }

    private string GetDefaultTitle(string language)
    {
        return language switch
        {
            "en" => "Privacy Policy",
            _ => "سياسة الخصوصية"
        };
    }

    private string GetDefaultContent(string language)
    {
        return language switch
        {
            "en" => @"# Privacy Policy

## Information We Collect
We collect information you provide directly to us, such as when you create an account, make a booking, or contact us.

## How We Use Your Information
We use the information we collect to:
- Provide, maintain, and improve our services
- Process transactions and send related information
- Send you technical notices and support messages
- Communicate with you about products, services, and events

## Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

## Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

## Contact Us
If you have any questions about this Privacy Policy, please contact us at support@yemenbooking.com.

Last updated: " + DateTime.UtcNow.ToString("yyyy-MM-dd"),

            _ => @"# سياسة الخصوصية

## المعلومات التي نجمعها
نجمع المعلومات التي تقدمها لنا مباشرة، مثل عند إنشاء حساب أو إجراء حجز أو الاتصال بنا.

## كيف نستخدم معلوماتك
نستخدم المعلومات التي نجمعها من أجل:
- تقديم خدماتنا والحفاظ عليها وتحسينها
- معالجة المعاملات وإرسال المعلومات ذات الصلة
- إرسال الإشعارات التقنية ورسائل الدعم
- التواصل معك حول المنتجات والخدمات والأحداث

## مشاركة المعلومات
لا نبيع أو نتاجر أو ننقل معلوماتك الشخصية إلى أطراف ثالثة دون موافقتك، باستثناء ما هو موضح في هذه السياسة.

## أمان البيانات
نطبق تدابير أمنية مناسبة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو التغيير أو الكشف أو التدمير.

## اتصل بنا
إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى الاتصال بنا على support@yemenbooking.com.

آخر تحديث: " + DateTime.UtcNow.ToString("yyyy-MM-dd")
        };
    }
}
