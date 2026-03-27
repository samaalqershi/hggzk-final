using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة BaseUnitDto.
    /// BaseUnitDto class.
    /// </summary>
    public class BaseUnitDto
    {
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public string UnitId { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public string PropertyId { get; set; }
        /// <summary>
        /// خاصية UnitName.
        /// UnitName property.
        /// </summary>
        public string UnitName { get; set; }
        /// <summary>
        /// خاصية UnitType.
        /// UnitType property.
        /// </summary>
        public string UnitType { get; set; }
        /// <summary>
        /// خاصية Capacity.
        /// Capacity property.
        /// </summary>
        public int Capacity { get; set; }
        // ملاحظة: تم حذف BasePrice - نعتمد على DailySchedules
        /// <summary>
        /// خاصية IsActive.
        /// IsActive property.
        /// </summary>
        public bool IsActive { get; set; }
    }
} 