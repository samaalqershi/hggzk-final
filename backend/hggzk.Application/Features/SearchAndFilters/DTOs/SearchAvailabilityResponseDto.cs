using System;
using System.Collections.Generic;
using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs {
    /// <summary>
    /// Response DTO for availability search
    /// </summary>
    public class SearchAvailabilityResponseDto
    {
        /// <summary>
        /// خاصية Availabilities.
        /// Availabilities property.
        /// </summary>
        public IEnumerable<DailyUnitScheduleDto> Availabilities { get; set; } = new List<DailyUnitScheduleDto>();
        /// <summary>
        /// خاصية Conflicts.
        /// Conflicts property.
        /// </summary>
        public IEnumerable<object> Conflicts { get; set; } = new List<object>();
        /// <summary>
        /// خاصية TotalCount.
        /// TotalCount property.
        /// </summary>
        public int TotalCount { get; set; }
        /// <summary>
        /// خاصية HasMore.
        /// HasMore property.
        /// </summary>
        public bool HasMore { get; set; }
    }

    /// <summary>
    /// Daily unit schedule DTO for availability search
    /// </summary>
    public class DailyUnitScheduleDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid UnitId { get; set; }
        /// <summary>
        /// خاصية Date.
        /// Date property.
        /// </summary>
        public DateTime Date { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; } = string.Empty;
        /// <summary>
        /// خاصية PriceAmount.
        /// PriceAmount property.
        /// </summary>
        public decimal? PriceAmount { get; set; }
        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        public string? Currency { get; set; }
        /// <summary>
        /// خاصية PriceType.
        /// PriceType property.
        /// </summary>
        public string? PriceType { get; set; }
        /// <summary>
        /// خاصية Reason.
        /// Reason property.
        /// </summary>
        public string? Reason { get; set; }
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
    }
}