using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;

namespace YemenBooking.Application.Features.Payments.Queries.GetPaymentById
{
/// <summary>
/// يمثل استعلامًا ضمن نطاق المدفوعات.
/// Represents a payment-related query.
/// </summary>
    public class GetPaymentByIdQuery : IRequest<PaymentDetailsDto>
    {
        /// <summary>
        /// معرّف الدفع
        /// Payment identifier.
        /// </summary>
        public Guid PaymentId { get; set; }

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
        public GetPaymentByIdQuery(Guid paymentId)
        {
            PaymentId = paymentId;
        }
    }
}
