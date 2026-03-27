using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Bookings.Commands.CreateBooking;
using YemenBooking.Application.Features.Bookings.Commands.CancelBooking;
using YemenBooking.Application.Features.Bookings.Commands.AddServices;
using YemenBooking.Application.Features.Bookings.Commands.UpdateBooking;
using YemenBooking.Application.Features.Bookings.Queries.GetUserBookings;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingDetails;
using YemenBooking.Application.Features.Bookings.Queries.GetUserBookingSummary;
using YemenBooking.Application.Common.Models;
using BookingDto = YemenBooking.Application.Features.Bookings.Queries.GetUserBookings.BookingDto;
using BookingDetailsDto = YemenBooking.Application.Features.Bookings.DTOs.BookingDetailsDto;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم إدارة حجوزات العميل.
    /// Client booking management controller.
    /// </summary>
    public class BookingController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [BookingController].
        /// Initializes a new instance of [BookingController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الطلبات. MediatR mediator used to process requests.</param>
        public BookingController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// ينشئ حجزًا جديدًا.
        /// Creates a new booking.
        /// </summary>
        /// <param name="command">بيانات الحجز. Booking details.</param>
        /// <returns>تفاصيل الحجز الجديد. Newly created booking details.</returns>
        [HttpPost]
        public async Task<ActionResult<ResultDto<CreateBookingResponse>>> CreateBooking([FromBody] CreateBookingCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يلغي حجزًا موجودًا.
        /// Cancels an existing booking.
        /// </summary>
        /// <param name="command">بيانات إلغاء الحجز. Cancellation details.</param>
        /// <returns>نتيجة إلغاء الحجز. Cancellation result.</returns>
        [HttpPost("cancel")]
        public async Task<ActionResult<ResultDto<bool>>> CancelBooking([FromBody] CancelBookingCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يضيف خدمة إلى الحجز.
        /// Adds a service to the booking.
        /// </summary>
        /// <param name="command">بيانات الخدمة المراد إضافتها. Service details to add.</param>
        /// <returns>نتيجة إضافة الخدمة. Add-service result.</returns>
        [HttpPost("add-service")]
        public async Task<ActionResult<ResultDto<AddServicesToBookingResponse>>> AddServiceToBooking([FromBody] AddServicesToBookingCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد قائمة حجوزات المستخدم.
        /// Returns the user's bookings list.
        /// </summary>
        /// <param name="query">معايير البحث والفلترة. Search and filter parameters.</param>
        /// <returns>قائمة حجوزات المستخدم. User bookings list.</returns>
        [HttpGet]
        public async Task<ActionResult<ResultDto<PaginatedResult<BookingDto>>>> GetUserBookings([FromQuery] GetUserBookingsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث حجزًا موجودًا للعميل.
        /// Updates an existing booking for the client.
        /// </summary>
        /// <param name="bookingId">معرف الحجز. Booking identifier.</param>
        /// <param name="command">بيانات التعديل. Update details.</param>
        /// <returns>نتيجة عملية التعديل. Update result.</returns>
        [HttpPut("{bookingId}/update")]
        public async Task<ActionResult<ResultDto<bool>>> UpdateBooking(Guid bookingId, [FromBody] UpdateBookingCommand command)
        {
            command.BookingId = bookingId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد تفاصيل حجز محدد.
        /// Returns the details of a specific booking.
        /// </summary>
        /// <param name="id">معرف الحجز. Booking identifier.</param>
        /// <param name="userId">معرف المستخدم. User identifier.</param>
        /// <returns>تفاصيل الحجز. Booking details.</returns>
        [HttpGet("{id}")]
    public async Task<ActionResult<ResultDto<BookingDetailsDto>>> GetBookingDetails(Guid id, [FromQuery] Guid userId)
        {
            var query = new GetBookingDetailsQuery { BookingId = id, UserId = userId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد ملخص حجوزات المستخدم.
        /// Returns a summary of the user's bookings.
        /// </summary>
        /// <param name="userId">معرف المستخدم. User identifier.</param>
        /// <param name="year">السنة. Year.</param>
        /// <returns>ملخص الحجوزات. Booking summary.</returns>
        [HttpGet("summary/{userId}")]
        public async Task<ActionResult<ResultDto<UserBookingSummaryDto>>> GetUserBookingSummary(Guid userId, [FromQuery] int? year)
        {
            var query = new GetUserBookingSummaryQuery { UserId = userId, Year = year };
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
