using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.SearchLogs
{
    /// <summary>
    /// استعلام جلب البحث logs.
    /// Get Search Logs query.
    /// </summary>
    public class GetSearchLogsQuery : IRequest<PaginatedResult<SearchLogDto>>
    {
        /// <summary>
        /// القيمة الخاصة بـ from.
        /// From value.
        /// </summary>
        public DateTime? From { get; set; }
        /// <summary>
        /// القيمة الخاصة بـ to.
        /// To value.
        /// </summary>
        public DateTime? To { get; set; }
        /// <summary>
        /// معرّف المستخدم.
        /// User identifier.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// نوع البحث.
        /// Search type.
        /// </summary>
        public string? SearchType { get; set; }
        /// <summary>
        /// رقم الصفحة.
        /// Page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// حجم الصفحة.
        /// Page size.
        /// </summary>
        public int PageSize { get; set; } = 20;
    }
} 