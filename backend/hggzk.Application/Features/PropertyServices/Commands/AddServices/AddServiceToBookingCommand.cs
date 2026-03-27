using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyServices.Commands.AddServices
{
    /// <summary>
    /// يضيف خدمة إلى حجز قائم.
    /// Adds a service to an existing booking.
    /// </summary>
    public class AddServiceToBookingCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الحجز.
        /// Booking identifier.
        /// </summary>
        public Guid BookingId { get; set; }

        /// <summary>
        /// معرّف الخدمة.
        /// Service identifier.
        /// </summary>
        public Guid ServiceId { get; set; }

        /// <summary>
        /// الكمية المطلوبة.
        /// Requested quantity.
        /// </summary>
        public int Quantity { get; set; }
    }
} 
