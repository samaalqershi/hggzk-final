using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Amenities.Queries.GetAllAmenities;

/// <summary>
/// يعالج استعلام جميع المرافق ويعيد النتيجة.
/// Processes the amenities query and returns the result.
/// </summary>
public class GetAllAmenitiesQueryHandler : IRequestHandler<GetAllAmenitiesQuery, ResultDto<PaginatedResultDto<AmenityDto>>>
{
    private readonly IAmenityRepository _amenityRepository;
    private readonly ILogger<GetAllAmenitiesQueryHandler> _logger;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public GetAllAmenitiesQueryHandler(
        IAmenityRepository amenityRepository,
        ILogger<GetAllAmenitiesQueryHandler> logger)
    {
        _amenityRepository = amenityRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the amenities query and returns the result.
    /// </summary>
    public async Task<ResultDto<PaginatedResultDto<AmenityDto>>> Handle(GetAllAmenitiesQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام الحصول على جميع وسائل الراحة. البحث: {Search}, الصفحة: {Page}", 
                request.SearchTerm ?? "لا يوجد", request.PageNumber);

            // الحصول على وسائل الراحة من قاعدة البيانات
            var allAmenities = await _amenityRepository.GetAllAsync(cancellationToken);
            
            // تطبيق الفلاتر
            var query = allAmenities?.Where(a => a.IsActive && !a.IsDeleted) ?? Enumerable.Empty<Core.Entities.Amenity>();
            
            // فلترة حسب البحث
            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                var searchLower = request.SearchTerm.ToLower();
                query = query.Where(a => 
                    a.Name.ToLower().Contains(searchLower) || 
                    (a.Description != null && a.Description.ToLower().Contains(searchLower)));
            }

            // حساب الإجمالي
            var totalCount = query.Count();

            // تطبيق الترتيب والصفحات
            var pageNumber = request.PageNumber > 0 ? request.PageNumber : 1;
            var pageSize = request.PageSize > 0 ? request.PageSize : 10;
            
            var amenities = query
                .OrderBy(a => a.Name)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            // تحويل البيانات إلى DTO
            var amenityDtos = amenities.Select(amenity => new AmenityDto
            {
                Id = amenity.Id,
                Name = amenity.Name,
                NameEn = amenity.NameEn,
                Description = amenity.Description ?? string.Empty,
                DescriptionEn = amenity.DescriptionEn,
                Icon = amenity.Icon ?? string.Empty,
                IconUrl = amenity.Icon ?? string.Empty,
                IsActive = amenity.IsActive,
                CreatedAt = amenity.CreatedAt,
                UpdatedAt = amenity.UpdatedAt
            }).ToList();

            _logger.LogInformation("تم الحصول على {Count} وسيلة راحة من {Total}", amenityDtos.Count, totalCount);

            var paginatedResult = new PaginatedResultDto<AmenityDto>
            {
                Items = amenityDtos,
                Total = totalCount,
                Page = pageNumber,
                Limit = pageSize,
                TotalPages = (int)Math.Ceiling((double)totalCount / pageSize)
            };

            return ResultDto<PaginatedResultDto<AmenityDto>>.Ok(
                paginatedResult, 
                $"تم الحصول على {amenityDtos.Count} وسيلة راحة"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على وسائل الراحة");
            return ResultDto<PaginatedResultDto<AmenityDto>>.Failed(
                $"حدث خطأ أثناء الحصول على وسائل الراحة: {ex.Message}", 
                "GET_AMENITIES_ERROR"
            );
        }
    }
}
