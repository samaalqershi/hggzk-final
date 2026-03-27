using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reviews.Queries.GetReviewByBooking
{
    /// <summary>
    /// الحصول على تقييم مرتبط بحجز محدد (لوحة التحكم)
    /// </summary>
    public class GetReviewByBookingQuery : IRequest<ResultDto<AdminReviewDetailsDto>>
    {
        /// <summary>
        /// معرّف الحجز المطلوب جلب التقييم المرتبط به.
        /// Identifier of the booking whose review should be retrieved.
        /// </summary>
        public Guid BookingId { get; set; }
    }
}
