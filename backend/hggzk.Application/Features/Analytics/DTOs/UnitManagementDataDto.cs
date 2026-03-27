using System.Collections.Generic;
using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة UnitManagementDataDto.
    /// UnitManagementDataDto class.
    /// </summary>
    public class UnitManagementDataDto
    {
        /// <summary>
        /// خاصية Unit.
        /// Unit property.
        /// </summary>
        public BaseUnitDto Unit { get; set; }
        /// <summary>
        /// خاصية CurrentAvailability.
        /// CurrentAvailability property.
        /// </summary>
        public string CurrentAvailability { get; set; }
        /// <summary>
        /// خاصية ActivePricingRules.
        /// ActivePricingRules property.
        /// </summary>
        public IEnumerable<PricingRuleDto> ActivePricingRules { get; set; }
        /// <summary>
        /// خاصية UpcomingBookings.
        /// UpcomingBookings property.
        /// </summary>
        public IEnumerable<UpcomingBookingDto> UpcomingBookings { get; set; }
        /// <summary>
        /// خاصية AvailabilityCalendar.
        /// AvailabilityCalendar property.
        /// </summary>
        public IEnumerable<AvailabilityCalendarDto> AvailabilityCalendar { get; set; }
    }
} 