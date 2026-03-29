using System;
using System.Linq;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetNearbyProperties;

/// <summary>
/// يعالج أمر الحصول على العقارات القريبة.
/// Handles the get nearby properties command.
/// </summary>
public class GetNearbyPropertiesQueryHandler : IRequestHandler<GetNearbyPropertiesQuery, ResultDto<List<NearbyPropertyDto>>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly ILogger<GetNearbyPropertiesQueryHandler> _logger;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [GetNearbyPropertiesQueryHandler].
    /// Initializes a new instance of [GetNearbyPropertiesQueryHandler].
    /// </summary>
    public GetNearbyPropertiesQueryHandler(
        IPropertyRepository propertyRepository,
        IReviewRepository reviewRepository,
        IPropertyImageRepository propertyImageRepository,
        IUnitRepository unitRepository,
        IDailyUnitScheduleRepository scheduleRepository,
        ILogger<GetNearbyPropertiesQueryHandler> logger)
    {
        _propertyRepository = propertyRepository;
        _reviewRepository = reviewRepository;
        _propertyImageRepository = propertyImageRepository;
        _unitRepository = unitRepository;
        _scheduleRepository = scheduleRepository;
        _logger = logger;
    }
    /// <summary>
    /// يعالج استعلام العقارات القريبة وفق الموقع ونطاق البحث.
    /// Handles retrieving nearby properties based on location and search radius.
    /// </summary>
    public async Task<ResultDto<List<NearbyPropertyDto>>> Handle(GetNearbyPropertiesQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام العقارات القريبة. الموقع: ({Latitude}, {Longitude}), نصف القطر: {RadiusKm} كم, العدد الأقصى: {MaxResults}", 
                request.Latitude, request.Longitude, request.RadiusKm, request.MaxResults);

            // Validate the input data.
            // التحقق من صحة البيانات المدخلة / Validate the input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Load all active properties.
            // الحصول على جميع العقارات النشطة / Load all active properties.
            var allProperties = await _propertyRepository.GetActivePropertiesAsync(cancellationToken);
            
            if (allProperties == null || !allProperties.Any())
            {
                _logger.LogInformation("لا توجد عقارات نشطة في النظام");
                
                return ResultDto<List<NearbyPropertyDto>>.Ok(
                    new List<NearbyPropertyDto>(), 
                    "لا توجد عقارات متاحة في المنطقة المحددة"
                );
            }

            // Filter by property type when provided.
            // فلترة العقارات حسب نوع العقار عند تحديده / Filter by property type when provided.
            if (request.PropertyTypeId.HasValue)
            {
                allProperties = allProperties.Where(p => p.TypeId == request.PropertyTypeId.Value);
            }

            // Calculate distances and keep properties within the requested radius.
            // حساب المسافة والاحتفاظ بالعقارات ضمن نصف القطر المحدد / Calculate distances and keep properties within the requested radius.
            var nearbyProperties = new List<(Core.Entities.Property Property, double Distance)>();

            foreach (var property in allProperties)
            {
                // Skip properties without coordinates.
                // تجاهل العقارات التي بلا إحداثيات / Skip properties without coordinates.
                if (property.Latitude == 0 || property.Longitude == 0)
                {
                    continue;
                }

                // Calculate distance.
                // حساب المسافة / Calculate distance.
                var distance = CalculateDistance(
                    (double)request.Latitude, (double)request.Longitude,
                    (double)property.Latitude, (double)property.Longitude);

                // Add the property when it is within the requested radius.
                // إضافة العقار إذا كان ضمن نصف القطر المحدد / Add the property when it is within the requested radius.
                if (distance <= request.RadiusKm)
                {
                    nearbyProperties.Add((Property: property, Distance: distance));
                }
            }

            if (!nearbyProperties.Any())
            {
                _logger.LogInformation("لا توجد عقارات ضمن نصف القطر المحدد: {RadiusKm} كم", request.RadiusKm);
                
                return ResultDto<List<NearbyPropertyDto>>.Ok(
                    new List<NearbyPropertyDto>(), 
                    $"لا توجد عقارات ضمن نصف قطر {request.RadiusKm} كم من الموقع المحدد"
                );
            }

            // Sort properties by distance.
            // ترتيب العقارات حسب المسافة / Sort properties by distance.
            var sortedProperties = nearbyProperties
                .OrderBy(p => p.Distance)
                .Take(request.MaxResults)
                .ToList();

            // Map to DTOs and load related data.
            // تحويل إلى DTOs مع جلب البيانات المرتبطة / Map to DTOs and load related data.
            var nearbyPropertyDtos = new List<NearbyPropertyDto>();

            foreach (var (property, distance) in sortedProperties)
            {
                // Use the cached average rating stored on the property.
                // استخدام متوسط التقييم المخزن في العقار / Use the cached average rating stored on the property.
                var averageRating = property.AverageRating;

                // Load the main image.
                // جلب الصورة الرئيسية / Load the main image.
                var propertyImages = await _propertyImageRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
                var mainImageUrl = propertyImages?.FirstOrDefault(img => img.IsMain)?.Url ?? 
                                  propertyImages?.FirstOrDefault()?.Url;

                // Load the minimum available price.
                // جلب أقل سعر متاح / Load the minimum available price.
                var minPrice = await GetMinAvailablePrice(property.Id, cancellationToken);

                var nearbyPropertyDto = new NearbyPropertyDto
                {
                    Id = property.Id,
                    Name = property.Name ?? string.Empty,
                    NameEn = property.NameEn,
                    Address = property.Address ?? string.Empty,
                    AddressEn = property.AddressEn,
                    DistanceKm = Math.Round(distance, 2),
                    AverageRating = Math.Round(averageRating, 1),
                    MinPrice = minPrice,
                    MainImageUrl = mainImageUrl
                };

                nearbyPropertyDtos.Add(nearbyPropertyDto);
            }

            _logger.LogInformation("تم العثور على {Count} عقار قريب من الموقع المحدد", nearbyPropertyDtos.Count);

            return ResultDto<List<NearbyPropertyDto>>.Ok(
                nearbyPropertyDtos, 
                $"تم العثور على {nearbyPropertyDtos.Count} عقار ضمن نصف قطر {request.RadiusKm} كم"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء البحث عن العقارات القريبة");
            return ResultDto<List<NearbyPropertyDto>>.Failed(
                $"حدث خطأ أثناء البحث عن العقارات القريبة: {ex.Message}", 
                "GET_NEARBY_PROPERTIES_ERROR"
            );
        }
    }

    private ResultDto<List<NearbyPropertyDto>> ValidateRequest(GetNearbyPropertiesQuery request)
    {
        // Validate coordinates.
        // التحقق من صحة الإحداثيات / Validate coordinates.
        if (Math.Abs(request.Latitude) > 90)
        {
            _logger.LogWarning("خط العرض غير صحيح: {Latitude}", request.Latitude);
            return ResultDto<List<NearbyPropertyDto>>.Failed("خط العرض يجب أن يكون بين -90 و 90", "INVALID_LATITUDE");
        }

        if (Math.Abs(request.Longitude) > 180)
        {
            _logger.LogWarning("خط الطول غير صحيح: {Longitude}", request.Longitude);
            return ResultDto<List<NearbyPropertyDto>>.Failed("خط الطول يجب أن يكون بين -180 و 180", "INVALID_LONGITUDE");
        }

        // Validate radius.
        // التحقق من نصف القطر / Validate radius.
        if (request.RadiusKm <= 0 || request.RadiusKm > 1000)
        {
            _logger.LogWarning("نصف القطر غير صحيح: {RadiusKm}", request.RadiusKm);
            return ResultDto<List<NearbyPropertyDto>>.Failed("نصف القطر يجب أن يكون بين 0.1 و 1000 كم", "INVALID_RADIUS");
        }

        // Validate the maximum result count.
        // التحقق من العدد الأقصى للنتائج / Validate the maximum result count.
        if (request.MaxResults < 1 || request.MaxResults > 100)
        {
            _logger.LogWarning("العدد الأقصى للنتائج غير صحيح: {MaxResults}", request.MaxResults);
            return ResultDto<List<NearbyPropertyDto>>.Failed("العدد الأقصى للنتائج يجب أن يكون بين 1 و 100", "INVALID_MAX_RESULTS");
        }

        return ResultDto<List<NearbyPropertyDto>>.Ok(null, "البيانات صحيحة");
    }

    private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
            const double R = 6371; // Earth's radius in kilometers / نصف قطر الأرض بالكيلومتر.

        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        var distance = R * c;

        return distance;
    }

    private double ToRadians(double degrees)
    {
        return degrees * (Math.PI / 180);
    }

    private async Task<decimal?> GetMinAvailablePrice(Guid propertyId, CancellationToken cancellationToken)
    {
        try
        {
            // Load all active units in the property.
            // الحصول على جميع الوحدات النشطة في العقار / Load all active units in the property.
            var units = await _unitRepository.GetActiveByPropertyIdAsync(propertyId, cancellationToken);
            
            if (units == null || !units.Any())
            {
                return null;
            }

            decimal? minPrice = null;

            foreach (var unit in units)
            {
                var displayPrice = await GetUnitDisplayPriceAsync(unit.Id, cancellationToken);
                if (displayPrice > 0)
                {
                    if (!minPrice.HasValue || displayPrice < minPrice.Value)
                    {
                        minPrice = displayPrice;
                    }
                }
            }

            return minPrice;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب أقل سعر متاح للعقار: {PropertyId}", propertyId);
            return null;
        }
    }

    private async Task<decimal> GetUnitDisplayPriceAsync(
        Guid unitId,
        CancellationToken cancellationToken)
    {
        var today = DateTime.UtcNow.Date;
        var searchEnd = today.AddDays(90);

        var schedules = (await _scheduleRepository.GetPricingForPeriodAsync(
                unitId,
                today,
                searchEnd))
            .Where(IsDisplayEligibleSchedule)
            .ToList();

        if (!schedules.Any())
        {
            return 0m;
        }

        var manuallyManagedSchedules = schedules
            .Where(IsManuallyManagedDisplaySchedule)
            .ToList();

        var effectiveSchedules = manuallyManagedSchedules.Any()
            ? manuallyManagedSchedules
            : schedules;

        var effectiveDate = effectiveSchedules.Min(s => s.Date.Date);

        return effectiveSchedules
            .Where(s => s.Date.Date == effectiveDate)
            .Min(s => s.PriceAmount!.Value);
    }

    private static bool IsDisplayEligibleSchedule(YemenBooking.Core.Entities.DailyUnitSchedule schedule)
    {
        return schedule.PriceAmount.HasValue &&
               schedule.PriceAmount.Value > 0 &&
               (schedule.Status == "Available" || schedule.Status == "Free");
    }

    private static bool IsManuallyManagedDisplaySchedule(YemenBooking.Core.Entities.DailyUnitSchedule schedule)
    {
        return !string.IsNullOrWhiteSpace(schedule.CreatedBy) &&
               !string.Equals(schedule.CreatedBy, "System", StringComparison.OrdinalIgnoreCase);
    }
}
