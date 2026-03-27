using System;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs {
    /// <summary>
    /// DTO لسجل عمليات البحث
    /// DTO for search logs
    /// </summary>
    public class SearchLogDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// خاصية SearchType.
        /// SearchType property.
        /// </summary>
        public string SearchType { get; set; }
        /// <summary>
        /// خاصية CriteriaJson.
        /// CriteriaJson property.
        /// </summary>
        public string CriteriaJson { get; set; }
        /// <summary>
        /// خاصية ResultCount.
        /// ResultCount property.
        /// </summary>
        public int ResultCount { get; set; }
        /// <summary>
        /// خاصية PageNumber.
        /// PageNumber property.
        /// </summary>
        public int PageNumber { get; set; }
        /// <summary>
        /// خاصية PageSize.
        /// PageSize property.
        /// </summary>
        public int PageSize { get; set; }
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
    }
} 