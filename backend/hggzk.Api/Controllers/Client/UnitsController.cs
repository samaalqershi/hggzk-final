using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Scheduling.Queries.CheckAvailability;
using YemenBooking.Application.Features.Units.Queries.GetAvailableUnits;
using YemenBooking.Application.Features.Units.Queries.GetUnitDetails;
using YemenBooking.Application.Features.Units.Commands.ReserveUnit;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features.Units.Queries.GetUnitAvailableDays;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر عمليات العميل المتعلقة بالوحدات.
    /// Exposes client operations for units.
    /// </summary>
    public class UnitsController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="UnitsController"/>.
        /// Creates a new <see cref="UnitsController"/> instance.
        /// </summary>
        public UnitsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يتحقق من توفر وحدة.
        /// Checks unit availability.
        /// </summary>
        /// <param name="query">بيانات التحقق.</param>
        /// <returns>نتيجة التوفر مع معلومات التسعير.</returns>
        [HttpPost("check-availability")]
        public async Task<ActionResult<ResultDto<AvailabilityCheckResultDto>>> CheckUnitAvailability([FromBody] CheckUnitAvailabilityQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يحجز وحدة للعميل.
        /// Reserves a unit for the client.
        /// </summary>
        /// <param name="command">بيانات الحجز.</param>
        /// <returns>نتيجة الحجز.</returns>
        [HttpPost("reserve")]
        public async Task<ActionResult<ResultDto<ClientUnitReservationResponse>>> ReserveUnit([FromBody] ClientReserveUnitCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الأيام المتاحة للوحدة.
        /// Retrieves the available days for a unit.
        /// </summary>
        [HttpGet("{unitId}/available-days")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<UnitAvailableDaysResponseDto>>> GetUnitAvailableDays(
            Guid unitId,
            [FromQuery] int months = 3,
            [FromQuery] Guid? excludeBookingId = null)
        {
            var query = new GetUnitAvailableDaysQuery
            {
                UnitId = unitId,
                Months = months,
                ExcludeBookingId = excludeBookingId
            };

            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الوحدات المتاحة.
        /// Retrieves available units.
        /// </summary>
        /// <param name="query">معايير البحث.</param>
        /// <returns>قائمة الوحدات المتاحة.</returns>
        [HttpGet("available")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<AvailableUnitsResponse>>> GetAvailableUnits([FromQuery] GetAvailableUnitsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تفاصيل وحدة محددة.
        /// Retrieves details for a specific unit.
        /// </summary>
        /// <param name="id">معرف الوحدة.</param>
        /// <param name="query">معايير جلب التفاصيل.</param>
        /// <returns>تفاصيل الوحدة.</returns>
        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<UnitDetailsDto>>> GetUnitDetails(Guid id, [FromQuery] GetUnitDetailsQuery query)
        {
            query.UnitId = id;
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
