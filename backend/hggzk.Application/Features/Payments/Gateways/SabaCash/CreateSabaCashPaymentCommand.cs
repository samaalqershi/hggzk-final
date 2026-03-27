using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Payments.Gateways.SabaCash
{
/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
    public class CreateSabaCashPaymentCommand : IRequest<ResultDto<Guid>>
    {
        /// <summary>
        /// معرّف الحجز
        /// Booking identifier.
        /// </summary>
        public Guid BookingId { get; set; }

        /// <summary>
        /// يمثل المبلغ.
        /// Represents amount.
        /// </summary>
        public decimal Amount { get; set; }

        /// <summary>
        /// يمثل معرّف Saba Cash العملية.
        /// Represents saba cash transaction id.
        /// </summary>
        public string SabaCashTransactionId { get; set; }

        /// <summary>
        /// يمثل Customer المحفظة.
        /// Represents customer wallet.
        /// </summary>
        public string CustomerWallet { get; set; }

        /// <summary>
        /// يمثل الملاحظات.
        /// Represents notes.
        /// </summary>
        public string Notes { get; set; } = string.Empty;
    }
}
