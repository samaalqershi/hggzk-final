using Microsoft.AspNetCore.Mvc;
using MediatR;
using YemenBooking.Application.Features.Scheduling.Commands.SetAvailability;
using YemenBooking.Application.Features.Scheduling.Commands.SetPricing;
using YemenBooking.Application.Features.Scheduling.Commands.CloneSchedule;
using YemenBooking.Application.Features.Scheduling.Queries.CheckAvailability;
using YemenBooking.Application.Features.Scheduling.Queries.GetSchedule;
using YemenBooking.Application.Features.Scheduling.Queries.CalculatePrice;

namespace YemenBooking.Api.Controllers.Admin;

/// <summary>
/// يوفّر إدارة الجدول اليومي للوحدات بما يشمل الإتاحة والتسعير.
/// Provides daily unit schedule management for availability and pricing.
/// </summary>
[ApiController]
[Route("api/admin/units/{unitId}/schedule")]
public class DailyScheduleController : BaseAdminController
{
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
    public DailyScheduleController(IMediator mediator) : base(mediator)
    {
    }

    #region Get Schedule (الحصول على الجدول)

    /// <summary>
    /// يجلب الجدول اليومي لنطاق تاريخي محدد.
    /// Retrieves the daily schedule for a specific date range.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetScheduleForPeriod(
        Guid unitId, 
        [FromQuery] DateTime startDate, 
        [FromQuery] DateTime endDate)
    {
        var query = new GetScheduleForPeriodQuery
        {
            UnitId = unitId,
            StartDate = startDate,
            EndDate = endDate
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    /// <summary>
    /// يجلب الجدول الشهري للوحدة.
    /// Retrieves the monthly schedule for the unit.
    /// </summary>
    [HttpGet("month/{year}/{month}")]
    public async Task<IActionResult> GetMonthlySchedule(Guid unitId, int year, int month)
    {
        var startDate = new DateTime(year, month, 1);
        var endDate = startDate.AddMonths(1).AddDays(-1);
        
        var query = new GetScheduleForPeriodQuery
        {
            UnitId = unitId,
            StartDate = startDate,
            EndDate = endDate
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    #endregion

    #region Availability Management (إدارة الإتاحة)

    /// <summary>
    /// يحدّد الإتاحة لفترة زمنية معينة.
    /// Sets availability for a specific period.
    /// </summary>
    [HttpPost("availability")]
    public async Task<IActionResult> SetAvailability(Guid unitId, [FromBody] SetAvailabilityForPeriodCommand command)
    {
        command.UnitId = unitId;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    /// <summary>
    /// يتحقق من توفر الوحدة ضمن فترة محددة.
    /// Checks unit availability for a specific period.
    /// </summary>
    [HttpGet("availability/check")]
    public async Task<IActionResult> CheckAvailability(
        Guid unitId, 
        [FromQuery] DateTime startDate, 
        [FromQuery] DateTime endDate)
    {
        var query = new CheckUnitAvailabilityQuery
        {
            UnitId = unitId,
            StartDate = startDate,
            EndDate = endDate
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    #endregion

    #region Pricing Management (إدارة التسعير)

    /// <summary>
    /// يحدد التسعير لفترة زمنية معينة.
    /// Sets pricing for a specific period.
    /// </summary>
    [HttpPost("pricing")]
    public async Task<IActionResult> SetPricing(Guid unitId, [FromBody] SetPricingForPeriodCommand command)
    {
        command.UnitId = unitId;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    /// <summary>
    /// يحسب السعر الإجمالي لفترة محددة.
    /// Calculates the total price for a specific period.
    /// </summary>
    [HttpPost("pricing/calculate")]
    public async Task<IActionResult> CalculatePrice(Guid unitId, [FromBody] CalculatePriceForPeriodQuery query)
    {
        query.UnitId = unitId;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    #endregion

    #region Clone Schedule (نسخ الجدول)

    /// <summary>
    /// ينسخ الجدول من فترة مرجعية إلى فترة أخرى.
    /// Clones a schedule from a source period to another period.
    /// </summary>
    [HttpPost("clone")]
    public async Task<IActionResult> CloneSchedule(Guid unitId, [FromBody] CloneScheduleCommand command)
    {
        command.UnitId = unitId;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    #endregion
}
