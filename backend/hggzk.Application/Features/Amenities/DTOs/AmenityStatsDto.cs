using System.Collections.Generic;

namespace YemenBooking.Application.Features.Amenities.DTOs {
    /// <summary>
    /// DTO لإحصائيات المرافق
    /// Amenity statistics DTO
    /// </summary>
    public class AmenityStatsDto
    {
        /// <summary>
        /// خاصية TotalAmenities.
        /// TotalAmenities property.
        /// </summary>
        public int TotalAmenities { get; set; }
        /// <summary>
        /// خاصية ActiveAmenities.
        /// ActiveAmenities property.
        /// </summary>
        public int ActiveAmenities { get; set; }
        /// <summary>
        /// خاصية TotalAssignments.
        /// TotalAssignments property.
        /// </summary>
        public int TotalAssignments { get; set; }
        /// <summary>
        /// خاصية TotalRevenue.
        /// TotalRevenue property.
        /// </summary>
        public decimal TotalRevenue { get; set; }
        /// <summary>
        /// خاصية PopularAmenities.
        /// PopularAmenities property.
        /// </summary>
        public Dictionary<string, int> PopularAmenities { get; set; } = new();
        /// <summary>
        /// خاصية RevenueByAmenity.
        /// RevenueByAmenity property.
        /// </summary>
        public Dictionary<string, decimal> RevenueByAmenity { get; set; } = new();
    }
}

