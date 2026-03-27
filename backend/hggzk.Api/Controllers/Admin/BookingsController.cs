using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Bookings.Commands.CancelBooking;
using YemenBooking.Application.Features.Bookings.Commands.UpdateBooking;
using YemenBooking.Application.Features.Bookings.Commands.ConfirmBooking;
using YemenBooking.Application.Features.Bookings.Commands.CheckInOut;
using YemenBooking.Application.Features.Payments.Commands.RegisterBookingPayment;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingById;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingsByProperty;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingsByStatus;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingsByUnit;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingsByUser;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingServices;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingsByDateRange;
using YemenBooking.Application.Features.Bookings.Queries.GetBookingDetails;
using YemenBooking.Application.Features.Analytics.Queries.BookingAnalytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر نقاط إدارة الحجوزات في لوحة الإدارة.
    /// Provides admin endpoints for managing bookings.
    /// </summary>
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin,Owner,Staff")]
    public class BookingsController : ControllerBase
    {
    /// <summary>
    /// موزّع أوامر واستعلامات الحجز.
    /// Mediator used to dispatch booking operations.
    /// </summary>
        private readonly IMediator _mediator;
    /// <summary>
    /// خدمة المستخدم الحالي.
    /// Current user context service.
    /// </summary>
        private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ المتحكم بالاعتماديات المطلوبة لإدارة الحجوزات.
    /// Initializes the controller with the dependencies needed for booking management.
    /// </summary>
        /// <param name="mediator">MediatR dispatcher. مرسل MediatR.</param>
        /// <param name="currentUserService">Current user service. خدمة المستخدم الحالي.</param>
        public BookingsController(IMediator mediator, ICurrentUserService currentUserService)
        {
            _mediator = mediator;
            _currentUserService = currentUserService;
        }

        /// <summary>
        /// يلغي الحجز المحدد.
        /// Cancels the specified booking.
        /// </summary>
        [HttpPost("{bookingId}/cancel")]
        public async Task<IActionResult> CancelBooking(Guid bookingId, [FromBody] CancelBookingCommand command)
        {
            command.BookingId = bookingId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث بيانات الحجز.
        /// Updates booking information.
        /// </summary>
        [HttpPut("{bookingId}/update")]
        public async Task<IActionResult> UpdateBooking(Guid bookingId, [FromBody] UpdateBookingCommand command)
        {
            command.BookingId = bookingId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يؤكد الحجز باستخدام البيانات المرسلة.
        /// Confirms a booking using the supplied payload.
        /// </summary>
        [HttpPost("confirm")]
        public async Task<IActionResult> ConfirmBooking([FromBody] ConfirmBookingCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يؤكد الحجز اعتمادًا على المعرّف الوارد في المسار.
        /// Confirms the booking using the route identifier.
        /// </summary>
        [HttpPost("{bookingId}/confirm")]
        public async Task<IActionResult> ConfirmBookingById(Guid bookingId)
        {
            var result = await _mediator.Send(new ConfirmBookingCommand { BookingId = bookingId });
            return Ok(result);
        }

        /// <summary>
        /// يسجل وصول النزيل للحجز.
        /// Marks the booking as checked in.
        /// </summary>
        [HttpPost("{bookingId}/check-in")]
        public async Task<IActionResult> CheckIn(Guid bookingId)
        {
            var result = await _mediator.Send(new CheckInBookingCommand { BookingId = bookingId });
            return Ok(result);
        }

        /// <summary>
        /// يسجل مغادرة النزيل للحجز.
        /// Marks the booking as checked out.
        /// </summary>
        [HttpPost("{bookingId}/check-out")]
        public async Task<IActionResult> CheckOut(Guid bookingId)
        {
            var result = await _mediator.Send(new CheckOutBookingCommand { BookingId = bookingId });
            return Ok(result);
        }

        /// <summary>
        /// يغيّر حالة الحجز إلى مكتمل.
        /// Marks the booking as completed.
        /// </summary>
        [HttpPost("{bookingId}/complete")]
        public async Task<IActionResult> Complete(Guid bookingId)
        {
            var result = await _mediator.Send(new CompleteBookingCommand { BookingId = bookingId });
            return Ok(result);
        }

        /// <summary>
        /// يسجل دفعة مرتبطة بالحجز.
        /// Registers a payment for the booking.
        /// </summary>
        [HttpPost("{bookingId}/register-payment")]
        public async Task<IActionResult> RegisterPayment(Guid bookingId, [FromBody] RegisterBookingPaymentCommand command)
        {
            command.BookingId = bookingId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }


        /// <summary>
        /// يجلب الحجز المحدد بواسطة المعرّف.
        /// Retrieves the booking identified by the route value.
        /// </summary>
        [HttpGet("{bookingId}")]
        public async Task<IActionResult> GetBookingById(Guid bookingId)
        {
            var query = new GetBookingByIdQuery { BookingId = bookingId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تفاصيل الحجز الكاملة.
        /// Retrieves the full booking details.
        /// </summary>
        [HttpGet("{bookingId}/details")]
        public async Task<IActionResult> GetBookingDetails(Guid bookingId)
        {
            var query = new GetBookingDetailsQuery
            {
                BookingId = bookingId,
                UserId = _currentUserService.UserId
            };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب حجوزات عقار محدد.
        /// Retrieves bookings for a specific property.
        /// </summary>
        [HttpGet("property/{propertyId}")]
        public async Task<IActionResult> GetBookingsByProperty(Guid propertyId, [FromQuery] GetBookingsByPropertyQuery query)
        {
            query.PropertyId = propertyId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الحجوزات بحسب الحالة.
        /// Retrieves bookings by status.
        /// </summary>
        [HttpGet("status")]
        public async Task<IActionResult> GetBookingsByStatus([FromQuery] GetBookingsByStatusQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الحجوزات الخاصة بوحدة معينة.
        /// Retrieves bookings for a specific unit.
        /// </summary>
        [HttpGet("unit/{unitId}")]
        public async Task<IActionResult> GetBookingsByUnit(Guid unitId, [FromQuery] GetBookingsByUnitQuery query)
        {
            query.UnitId = unitId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الحجوزات الخاصة بمستخدم محدد.
        /// Retrieves bookings for a specific user.
        /// </summary>
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetBookingsByUser(Guid userId, [FromQuery] GetBookingsByUserQuery query)
        {
            query.UserId = userId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الخدمات المرتبطة بالحجز.
        /// Retrieves services attached to the booking.
        /// </summary>
        [HttpGet("{bookingId}/services")]
        public async Task<IActionResult> GetBookingServices(Guid bookingId)
        {
            var query = new GetBookingServicesQuery { BookingId = bookingId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقرير الحجوزات.
        /// Retrieves booking reporting data.
        /// </summary>
        [HttpGet("report")]
        public async Task<IActionResult> GetBookingReport([FromQuery] GetBookingReportQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب اتجاهات الحجوزات كسلسلة زمنية.
        /// Retrieves booking trends as a time series.
        /// </summary>
        [HttpGet("trends")]
        public async Task<IActionResult> GetBookingTrends([FromQuery] GetBookingTrendsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تحليل نافذة الحجز لعقار محدد.
        /// Retrieves booking window analysis for a property.
        /// </summary>
        [HttpGet("window-analysis/{propertyId}")]
        public async Task<IActionResult> GetBookingWindowAnalysis(Guid propertyId)
        {
            var query = new GetBookingWindowAnalysisQuery(propertyId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الحجوزات ضمن نطاق زمني محدد.
        /// Retrieves bookings within a date range.
        /// </summary>
        [HttpGet("by-date-range")]
        public async Task<IActionResult> GetBookingsByDateRange([FromQuery] GetBookingsByDateRangeQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
