using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyServices.Commands.RemoveServices
{
    /// <summary>
    /// يزيل خدمة من حجز قائم.
    /// Removes a service from an existing booking.
    /// </summary>
    public class RemoveServiceFromBookingCommand : IRequest<ResultDto<bool>>
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
    }
}
