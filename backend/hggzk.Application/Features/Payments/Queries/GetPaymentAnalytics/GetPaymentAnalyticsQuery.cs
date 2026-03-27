using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Payments.Queries.GetPaymentAnalytics
{
/// <summary>
/// يمثل استعلامًا ضمن نطاق المدفوعات.
/// Represents a payment-related query.
/// </summary>
    public class GetPaymentAnalyticsQuery : IRequest<ResultDto<PaymentAnalyticsDto>>
    {
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
        /// معرّف العقار
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }
    }
}
