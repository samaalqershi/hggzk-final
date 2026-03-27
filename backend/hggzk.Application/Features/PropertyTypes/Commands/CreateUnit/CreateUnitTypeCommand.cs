using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyTypes.Commands.CreateUnit
{
    /// <summary>
    /// يمثل طلب إنشاء نوع وحدة جديد.
    /// Creates a new unit type.
    /// </summary>
    public class CreateUnitTypeCommand : IRequest<ResultDto<Guid>>
    {
        /// <summary>
        /// معرّف نوع العقار.
        /// Property type identifier.
        /// </summary>
        public Guid PropertyTypeId { get; set; }

        /// <summary>
        /// الاسم.
        /// Name.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// السعة القصوى.
        /// Maximum capacity.
        /// </summary>
        public int MaxCapacity { get; set; }

        /// <summary>
        /// الأيقونة.
        /// Icon.
        /// </summary>
        public string Icon { get; set; } = string.Empty;

        /// <summary>
        /// يشير إلى دعم البالغين.
        /// Indicates adult support.
        /// </summary>
        public bool IsHasAdults { get; set; } = false;

        /// <summary>
        /// يشير إلى دعم الأطفال.
        /// Indicates child support.
        /// </summary>
        public bool IsHasChildren { get; set; } = false;

        /// <summary>
        /// يشير إلى السماح بالحجوزات متعددة الأيام.
        /// Indicates multi-day bookings are allowed.
        /// </summary>
        public bool IsMultiDays { get; set; } = false;

        /// <summary>
        /// يشير إلى ضرورة تحديد الساعة.
        /// Indicates that an hour must be specified.
        /// </summary>
        public bool IsRequiredToDetermineTheHour { get; set; } = false;

        /// <summary>
        /// نسبة عمولة النظام.
        /// System commission rate.
        /// </summary>
        public decimal? SystemCommissionRate { get; set; }

    }
} 
