using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.SearchUnits
{
    /// <summary>
    /// استعلام البحث عن الوحدات.
    /// Search Units query.
    /// </summary>
    public class SearchUnitsQuery : IRequest<PaginatedResult<UnitDto>>
    {
        /// <summary>
        /// القيمة الخاصة بـ location.
        /// Location value.
        /// </summary>
        public string? Location { get; set; }

        /// <summary>
        /// الحد الأدنى للسعر.
        /// Minimum price.
        /// </summary>
        public decimal? MinPrice { get; set; }

        /// <summary>
        /// الحد الأقصى للسعر.
        /// Maximum price.
        /// </summary>
        public decimal? MaxPrice { get; set; }

        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// معرّف نوع الوحدة.
        /// Unit type identifier.
        /// </summary>
        public Guid? UnitTypeId { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ التحقق من in date.
        /// Check In Date value.
        /// </summary>
        public DateTime? CheckInDate { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ التحقق من out date.
        /// Check Out Date value.
        /// </summary>
        public DateTime? CheckOutDate { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ adults.
        /// Adults value.
        /// </summary>
        public int? Adults { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ children.
        /// Children value.
        /// </summary>
        public int? Children { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ has النشاط الحجوزات.
        /// Has Active Bookings value.
        /// </summary>
        public bool? HasActiveBookings { get; set; }

        /// <summary>
        /// رقم الصفحة.
        /// Page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة.
        /// Page size.
        /// </summary>
        public int PageSize { get; set; } = 10;

        /// <summary>
        /// القيمة الخاصة بـ الديناميكي الحقل الفلاتر.
        /// Dynamic Field Filters value.
        /// </summary>
        public IEnumerable<YemenBooking.Application.Features.Units.DTOs.UnitDynamicFieldFilterDto>? DynamicFieldFilters { get; set; }

        /// <summary>
        /// خط العرض.
        /// Latitude.
        /// </summary>
        public double? Latitude { get; set; }

        /// <summary>
        /// خط الطول.
        /// Longitude.
        /// </summary>
        public double? Longitude { get; set; }

        /// <summary>
        /// نصف القطر بالكيلومترات.
        /// Radius in kilometers.
        /// </summary>
        public double? RadiusKm { get; set; }

        /// <summary>
        /// معيار الفرز.
        /// Sort by value.
        /// </summary>
        public string? SortBy { get; set; }

        /// <summary>
        /// الاسم الجزئي المطابق.
        /// Matching partial name.
        /// </summary>
        public string? NameContains { get; set; }

        /// <summary>
        /// طريقة التسعير.
        /// Pricing strategy.
        /// </summary>
        public string? PricingMethod { get; set; }
    }
} 
