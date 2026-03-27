using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Payments.Queries.GetAllPayments
{
/// <summary>
/// يمثل استعلامًا ضمن نطاق المدفوعات.
/// Represents a payment-related query.
/// </summary>
    public class GetAllPaymentsQuery : IRequest<PaginatedResult<YemenBooking.Application.Features.Payments.DTOs.PaymentDto>>
    {
        /// <summary>
        /// يمثل الحالة.
        /// Represents status.
        /// </summary>
        public string? Status { get; set; }
        /// <summary>
        /// طريقة الدفع المراد تصفيتها.
        /// Payment method used for filtering.
        /// </summary>
        public string? Method { get; set; }
        /// <summary>
        /// معرّف الحجز
        /// Booking identifier.
        /// </summary>
        public Guid? BookingId { get; set; }
        /// <summary>
        /// معرّف المستخدم
        /// User identifier.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// معرّف العقار
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }
        /// <summary>
        /// معرّف الوحدة
        /// Unit identifier.
        /// </summary>
        public Guid? UnitId { get; set; }
        /// <summary>
        /// يمثل الحد الأدنى للمبلغ.
        /// Represents min amount.
        /// </summary>
        public decimal? MinAmount { get; set; }
        /// <summary>
        /// يمثل الحد الأقصى للمبلغ.
        /// Represents max amount.
        /// </summary>
        public decimal? MaxAmount { get; set; }
        /// <summary>
        /// يمثل تاريخ البداية.
        /// Represents start date.
        /// </summary>
        public DateTime? StartDate { get; set; }
        /// <summary>
        /// يمثل تاريخ النهاية.
        /// Represents end date.
        /// </summary>
        public DateTime? EndDate { get; set; }
        /// <summary>
        /// يمثل رقم الصفحة.
        /// Represents page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// يمثل حجم الصفحة.
        /// Represents page size.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }
} 
