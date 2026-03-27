using Microsoft.AspNetCore.Mvc;
using MediatR;
using YemenBooking.Application.Features.Properties.Queries.SearchProperties;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace YemenBooking.Api.Controllers;

    /// <summary>
    /// نقاط البحث عن العقارات عبر المعالجات.
    /// Search endpoints for properties.
    /// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SearchController : ControllerBase
{
    /// <summary>
    /// المرسل الوسيط للأوامر والاستعلامات.
    /// Mediator used to dispatch commands and queries.
    /// </summary>
    private readonly IMediator _mediator;
    /// <summary>
    /// مسجل الأحداث.
    /// Logger instance.
    /// </summary>
    private readonly ILogger<SearchController> _logger;

    /// <summary>
    /// ينشئ المتحكم مع المرسل الوسيط ومسجل الأحداث.
    /// Creates the controller with the mediator and logger.
    /// </summary>
    public SearchController(
        IMediator mediator,
        ILogger<SearchController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    /// <summary>
    /// يبحث في العقارات عبر الاستعلام المخصص.
    /// Searches properties through the dedicated query handler.
    /// </summary>
    [HttpPost("properties")]
    public async Task<ActionResult<ResultDto<SearchPropertiesResponse>>> SearchProperties(
        [FromBody] SearchPropertiesQuery query,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await _mediator.Send(query, cancellationToken);
            if (!result.IsSuccess)
                return BadRequest(result);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في البحث عن العقارات عبر المعالج");
            return BadRequest(ResultDto<SearchPropertiesResponse>.Failed("حدث خطأ أثناء البحث"));
        }
    }
}
