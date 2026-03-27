using MediatR;
using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.SearchAdvancedProperty
{
    /// <summary>
    /// استعلام البحث المتقدم عن العقارات.
    /// Query for advanced property search.
    /// </summary>
    public class AdvancedPropertySearchQuery : IRequest<PaginatedResult<Properties.DTOs.AdvancedPropertyDto>>
    {
        /// <summary>
        /// معرّف نوع العقار.
        /// property type identifier.
        /// </summary>
        public Guid? PropertyTypeId { get; set; }
        /// <summary>
        /// تاريخ البداية.
        /// start date.
        /// </summary>
        public DateTime? FromDate { get; set; }
        /// <summary>
        /// تاريخ النهاية.
        /// end date.
        /// </summary>
        public DateTime? ToDate { get; set; }
        /// <summary>
        /// الحد الأدنى للسعر.
        /// minimum price.
        /// </summary>
        public decimal? MinPrice { get; set; }
        /// <summary>
        /// الحد الأقصى للسعر.
        /// maximum price.
        /// </summary>
        public decimal? MaxPrice { get; set; }
        /// <summary>
        /// العملة.
        /// currency.
        /// </summary>
        public string Currency { get; set; }
        /// <summary>
        /// مرشحات الحقول الأساسية.
        /// primary field filters.
        /// </summary>
        public Dictionary<Guid, IEnumerable<string>> PrimaryFieldFilters { get; set; }
        /// <summary>
        /// مرشحات الحقول.
        /// field filters.
        /// </summary>
        public Dictionary<Guid, IEnumerable<string>> FieldFilters { get; set; }
        /// <summary>
        /// معرّفات أنواع الوحدات.
        /// unit type identifiers.
        /// </summary>
        public IEnumerable<Guid> UnitTypeIds { get; set; }
        /// <summary>
        /// معرّفات المزايا.
        /// amenity identifiers.
        /// </summary>
        public IEnumerable<Guid> AmenityIds { get; set; }
        /// <summary>
        /// معرّفات الخدمات.
        /// service identifiers.
        /// </summary>
        public IEnumerable<Guid> ServiceIds { get; set; }
        /// <summary>
        /// الفرز حسب.
        /// sort by.
        /// </summary>
        public string SortBy { get; set; }
        /// <summary>
        /// تصاعدي.
        /// sorted in ascending order.
        /// </summary>
        public bool IsAscending { get; set; } = false;
        /// <summary>
        /// رقم الصفحة.
        /// page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// حجم الصفحة.
        /// page size.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }
} 
