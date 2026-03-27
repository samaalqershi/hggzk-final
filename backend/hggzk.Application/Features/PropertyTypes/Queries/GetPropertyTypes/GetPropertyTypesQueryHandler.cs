using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.PropertyTypes;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;
using System.Collections.Generic;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypes;

/// <summary>
/// يسترجع أنواع العقارات ويحسب ملخصاتها.
/// Retrieves property types and their summary data.
/// </summary>
public class GetPropertyTypesQueryHandler : IRequestHandler<GetPropertyTypesQuery, ResultDto<List<PropertyTypeDto>>>
{
    private readonly IPropertyTypeRepository _propertyTypeRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly ILogger<GetPropertyTypesQueryHandler> _logger;

    /// <summary>
    /// يهيئ معالج جلب أنواع العقارات.
    /// Initializes the property types query handler.
    /// </summary>
    public GetPropertyTypesQueryHandler(
        IPropertyTypeRepository propertyTypeRepository,
        IPropertyRepository propertyRepository,
        ILogger<GetPropertyTypesQueryHandler> logger)
    {
        _propertyTypeRepository = propertyTypeRepository;
        _propertyRepository = propertyRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج Get Property Types الوارد.
    /// Processes the incoming get property types query.
    /// </summary>
    public async Task<ResultDto<List<PropertyTypeDto>>> Handle(GetPropertyTypesQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام أنواع العقارات");

            // الحصول على جميع أنواع العقارات النشطة مع أنواع الوحدات التابعة لها
            var allPropertyTypes = await _propertyTypeRepository.GetAllPropertyTypesAsync(cancellationToken);
            var propertyTypes = allPropertyTypes?.Where(pt => pt.IsActive);

            if (propertyTypes == null || !propertyTypes.Any())
            {
                _logger.LogInformation("لم يتم العثور على أنواع عقارات");
                
                return ResultDto<List<PropertyTypeDto>>.Ok(
                    new List<PropertyTypeDto>(), 
                    "لا توجد أنواع عقارات متاحة حالياً"
                );
            }

            // تحويل البيانات إلى DTO مع حساب عدد العقارات لكل نوع
            var propertyTypeDtos = new List<PropertyTypeDto>();

            foreach (var propertyType in propertyTypes)
            {
                // حساب عدد العقارات النشطة من هذا النوع
                var propertiesCount = (await _propertyRepository.GetAllAsync(cancellationToken))?.Count(p => p.TypeId == propertyType.Id) ?? 0;

                var propertyTypeDto = new PropertyTypeDto
                {
                    Id = propertyType.Id,
                    Name = propertyType.Name ?? string.Empty,
                    Description = propertyType.Description ?? string.Empty,
                    PropertiesCount = propertiesCount,
                    Icon = propertyType.Icon ?? string.Empty,
                    UnitTypeIds = propertyType.UnitTypes?.Select(ut => ut.Id).ToList() ?? new List<Guid>()
                };

                propertyTypeDtos.Add(propertyTypeDto);
            }

            // ترتيب أنواع العقارات حسب عدد العقارات (الأكثر أولاً) ثم حسب الاسم
            propertyTypeDtos = propertyTypeDtos
                .OrderByDescending(pt => pt.PropertiesCount)
                .ThenBy(pt => GetTypeDisplayOrder(pt.Name))
                .ThenBy(pt => pt.Name)
                .ToList();

            _logger.LogInformation("تم الحصول على {Count} نوع عقار بنجاح", propertyTypeDtos.Count);

            return ResultDto<List<PropertyTypeDto>>.Ok(
                propertyTypeDtos, 
                $"تم الحصول على {propertyTypeDtos.Count} نوع عقار"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على أنواع العقارات");
            return ResultDto<List<PropertyTypeDto>>.Failed(
                $"حدث خطأ أثناء الحصول على أنواع العقارات: {ex.Message}", 
                "GET_PROPERTY_TYPES_ERROR"
            );
        }
    }

    private int GetTypeDisplayOrder(string typeName)
    {
        return typeName.ToLower() switch
        {
            "فندق" or "hotel" => 1,
            "منتجع" or "resort" => 2,
            "شاليه" or "chalet" => 3,
            "فيلا" or "villa" => 4,
            "استراحة" or "rest house" => 5,
            "شقة" or "apartment" => 6,
            "بيت شعبي" or "traditional house" => 7,
            "مخيم" or "camp" => 8,
            "نزل" or "hostel" => 9,
            _ => 999
        };
    }
}
