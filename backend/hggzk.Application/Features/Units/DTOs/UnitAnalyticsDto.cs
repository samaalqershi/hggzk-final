using System;

namespace YemenBooking.Application.Features.Units.DTOs;

/// <summary>
/// فئة UnitAnalyticsDto.
/// UnitAnalyticsDto class.
/// </summary>
public class UnitAnalyticsDto
{
    /// <summary>
    /// خاصية UnitId.
    /// UnitId property.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// خاصية FromDate.
    /// FromDate property.
    /// </summary>
    public DateTime FromDate { get; set; }

    /// <summary>
    /// خاصية ToDate.
    /// ToDate property.
    /// </summary>
    public DateTime ToDate { get; set; }

    /// <summary>
    /// خاصية Currency.
    /// Currency property.
    /// </summary>
    public string Currency { get; set; } = "YER";

    /// <summary>
    /// خاصية TotalBookings.
    /// TotalBookings property.
    /// </summary>
    public int TotalBookings { get; set; }

    /// <summary>
    /// خاصية ConfirmedBookings.
    /// ConfirmedBookings property.
    /// </summary>
    public int ConfirmedBookings { get; set; }

    /// <summary>
    /// خاصية CompletedBookings.
    /// CompletedBookings property.
    /// </summary>
    public int CompletedBookings { get; set; }

    /// <summary>
    /// خاصية CancelledBookings.
    /// CancelledBookings property.
    /// </summary>
    public int CancelledBookings { get; set; }

    /// <summary>
    /// خاصية TotalRevenue.
    /// TotalRevenue property.
    /// </summary>
    public decimal TotalRevenue { get; set; }

    /// <summary>
    /// خاصية OccupancyRate.
    /// OccupancyRate property.
    /// </summary>
    public double OccupancyRate { get; set; }

    /// <summary>
    /// خاصية TotalDays.
    /// TotalDays property.
    /// </summary>
    public int TotalDays { get; set; }

    /// <summary>
    /// خاصية BookedDays.
    /// BookedDays property.
    /// </summary>
    public int BookedDays { get; set; }

    /// <summary>
    /// خاصية AverageRating.
    /// AverageRating property.
    /// </summary>
    public double AverageRating { get; set; }

    /// <summary>
    /// خاصية TotalReviews.
    /// TotalReviews property.
    /// </summary>
    public int TotalReviews { get; set; }

    /// <summary>
    /// خاصية ViewCount.
    /// ViewCount property.
    /// </summary>
    public int ViewCount { get; set; }

    /// <summary>
    /// خاصية BookingCount.
    /// BookingCount property.
    /// </summary>
    public int BookingCount { get; set; }
}
