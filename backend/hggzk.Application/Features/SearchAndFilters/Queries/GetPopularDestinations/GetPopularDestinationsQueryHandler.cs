using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using PopularDestinationDto = YemenBooking.Application.Features.SearchAndFilters.DTOs.PopularDestinationDto;
using YemenBooking.Application.Features;


namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetPopularDestinations;

/// <summary>
/// يعالج جلب الشائعة destinations ويعيد النتيجة المطلوبة.
/// Processes the Get Popular Destinations request and returns the requested result.
/// </summary>
public class GetPopularDestinationsQueryHandler : IRequestHandler<GetPopularDestinationsQuery, ResultDto<List<PopularDestinationDto>>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<GetPopularDestinationsQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetPopularDestinationsQueryHandler.
    /// Initializes a new instance of GetPopularDestinationsQueryHandler.
    /// </summary>
    /// <param name="propertyRepository">مستودع البيانات العقارية / Real-estate repository.</param>
    /// <param name="bookingRepository">مستودع الحجز / booking repository.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public GetPopularDestinationsQueryHandler(
        IPropertyRepository propertyRepository,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        ILogger<GetPopularDestinationsQueryHandler> logger)
    {
        _propertyRepository = propertyRepository;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<List<PopularDestinationDto>>> Handle(GetPopularDestinationsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام الوجهات الشعبية. العدد المطلوب: {Count}", request.Count);

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // الحصول على جميع العقارات النشطة
            var activeProperties = await _propertyRepository.GetActivePropertiesAsync(cancellationToken);
            
            if (activeProperties == null || !activeProperties.Any())
            {
                _logger.LogInformation("لا توجد عقارات نشطة في النظام");
                return ResultDto<List<PopularDestinationDto>>.Ok(
                    GetDefaultDestinations(), 
                    "لا توجد عقارات متاحة، تم إرجاع الوجهات الافتراضية"
                );
            }

            // تجميع العقارات حسب المدينة
            var citiesWithProperties = activeProperties
                .Where(p => !string.IsNullOrWhiteSpace(p.City))
                .GroupBy(p => p.City!)
                .ToList();

            if (!citiesWithProperties.Any())
            {
                _logger.LogInformation("لا توجد مدن محددة في العقارات");
                return ResultDto<List<PopularDestinationDto>>.Ok(
                    GetDefaultDestinations(), 
                    "لا توجد مدن محددة، تم إرجاع الوجهات الافتراضية"
                );
            }

            var popularDestinations = new List<PopularDestinationDto>();

            // معالجة كل مدينة
            foreach (var cityGroup in citiesWithProperties)
            {
                var cityName = cityGroup.Key;
                var cityProperties = cityGroup.ToList();

                try
                {
                    // حساب متوسط السعر للمدينة
                    var averagePrice = await CalculateCityAveragePrice(cityProperties, cancellationToken);

                    // حساب شعبية المدينة بناءً على عدد الحجوزات
                    var popularityScore = await CalculateCityPopularityScore(cityProperties, cancellationToken);

                    var destination = new PopularDestinationDto
                    {
                        CityName = cityName,
                        PropertiesCount = cityProperties.Count,
                        AveragePrice = averagePrice,
                        ImageUrl = GetCityImageUrl(cityName),
                        Description = GetCityDescription(cityName)
                    };

                    popularDestinations.Add(destination);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "خطأ أثناء معالجة المدينة: {CityName}", cityName);
                }
            }

            // ترتيب الوجهات حسب الشعبية (عدد العقارات أولاً، ثم متوسط السعر)
            var sortedDestinations = popularDestinations
                .OrderByDescending(d => d.PropertiesCount)
                .ThenBy(d => d.AveragePrice)
                .Take(request.Count)
                .ToList();

            _logger.LogInformation("تم العثور على {Count} وجهة شعبية", sortedDestinations.Count);

            return ResultDto<List<PopularDestinationDto>>.Ok(
                sortedDestinations, 
                $"تم العثور على {sortedDestinations.Count} وجهة شعبية"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب الوجهات الشعبية");
            return ResultDto<List<PopularDestinationDto>>.Failed(
                $"حدث خطأ أثناء جلب الوجهات الشعبية: {ex.Message}", 
                "GET_POPULAR_DESTINATIONS_ERROR"
            );
        }
    }

    private ResultDto<List<PopularDestinationDto>> ValidateRequest(GetPopularDestinationsQuery request)
    {
        if (request.Count < 1 || request.Count > 50)
        {
            _logger.LogWarning("عدد الوجهات المطلوبة غير صحيح: {Count}", request.Count);
            return ResultDto<List<PopularDestinationDto>>.Failed(
                "عدد الوجهات يجب أن يكون بين 1 و 50", 
                "INVALID_COUNT"
            );
        }

        return ResultDto<List<PopularDestinationDto>>.Ok(null, "البيانات صحيحة");
    }

    private async Task<decimal> CalculateCityAveragePrice(List<Core.Entities.Property> cityProperties, CancellationToken cancellationToken)
    {
        try
        {
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب متوسط السعر للمدينة");
            return 0;
        }
    }

    private async Task<int> CalculateCityPopularityScore(List<Core.Entities.Property> cityProperties, CancellationToken cancellationToken)
    {
        try
        {
            var totalBookings = 0;

            foreach (var property in cityProperties)
            {
                var propertyBookings = await _bookingRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
                if (propertyBookings != null)
                {
                    totalBookings += propertyBookings.Count();
                }
            }

            return totalBookings;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب درجة شعبية المدينة");
            return 0;
        }
    }

    private string? GetCityImageUrl(string cityName)
    {
        // يمكن تخصيص الصور حسب المدينة
        var cityImages = new Dictionary<string, string>
        {
            { "صنعاء", "/images/cities/sanaa.jpg" },
            { "عدن", "/images/cities/aden.jpg" },
            { "تعز", "/images/cities/taiz.jpg" },
            { "الحديدة", "/images/cities/hodeidah.jpg" },
            { "إب", "/images/cities/ibb.jpg" },
            { "المكلا", "/images/cities/mukalla.jpg" },
            { "سيئون", "/images/cities/seiyun.jpg" }
        };

        return cityImages.GetValueOrDefault(cityName, "/images/cities/default.jpg");
    }

    private string? GetCityDescription(string cityName)
    {
        var cityDescriptions = new Dictionary<string, string>
        {
            { "صنعاء", "العاصمة التاريخية والثقافية لليمن" },
            { "عدن", "العاصمة الاقتصادية والميناء الرئيسي" },
            { "تعز", "المدينة الثقافية والتعليمية" },
            { "الحديدة", "الميناء الغربي الرئيسي على البحر الأحمر" },
            { "إب", "مدينة الخضرة والجمال الطبيعي" },
            { "المكلا", "عاصمة حضرموت الساحلية" },
            { "سيئون", "مدينة التراث والتاريخ في وادي حضرموت" }
        };

        return cityDescriptions.GetValueOrDefault(cityName, $"مدينة {cityName} الجميلة");
    }

    private List<PopularDestinationDto> GetDefaultDestinations()
    {
        return new List<PopularDestinationDto>
        {
            new PopularDestinationDto
            {
                CityName = "صنعاء",
                PropertiesCount = 0,
                AveragePrice = 50000,
                ImageUrl = "/images/cities/sanaa.jpg",
                Description = "العاصمة التاريخية والثقافية لليمن"
            },
            new PopularDestinationDto
            {
                CityName = "عدن",
                PropertiesCount = 0,
                AveragePrice = 45000,
                ImageUrl = "/images/cities/aden.jpg",
                Description = "العاصمة الاقتصادية والميناء الرئيسي"
            },
            new PopularDestinationDto
            {
                CityName = "تعز",
                PropertiesCount = 0,
                AveragePrice = 40000,
                ImageUrl = "/images/cities/taiz.jpg",
                Description = "المدينة الثقافية والتعليمية"
            },
            new PopularDestinationDto
            {
                CityName = "الحديدة",
                PropertiesCount = 0,
                AveragePrice = 35000,
                ImageUrl = "/images/cities/hodeidah.jpg",
                Description = "الميناء الغربي الرئيسي على البحر الأحمر"
            },
            new PopularDestinationDto
            {
                CityName = "إب",
                PropertiesCount = 0,
                AveragePrice = 30000,
                ImageUrl = "/images/cities/ibb.jpg",
                Description = "مدينة الخضرة والجمال الطبيعي"
            }
        };
    }
}
