using System.Threading.Tasks;
using System;
using System.Linq;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Sections.Commands.ManageSectionItems;
using YemenBooking.Application.Features.Units.Commands.CreateUnit;
using YemenBooking.Application.Features.Units.Commands.DeleteUnit;
using YemenBooking.Application.Features.Units.Commands.UpdateUnit;
using YemenBooking.Application.Features.Units.Queries.GetUnitById;
using YemenBooking.Application.Features.Units.Queries.GetUnitDetails;
using YemenBooking.Application.Features.Units.Queries.SearchUnits;
using YemenBooking.Application.Features.Units.Queries.GetAdminUnitsSimple;
using YemenBooking.Application.Features.Units.Queries.GetUnitAnalytics;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير الوحدات مع الاستعلامات الإدارية والتفاصيل والتحليلات.
    /// Manages units with admin queries, details, and analytics.
    /// </summary>
    public class UnitsController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public UnitsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يعرض جميع الوحدات مع الفلاتر ودعم الصفحات.
        /// Returns all units with filters and pagination support.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllUnits([FromQuery] SearchUnitsQuery query)
        {
            // ✅ Logging للتحقق من القيم المُستلمة
            Console.WriteLine($"📥 Received Query: MinPrice={query.MinPrice}, MaxPrice={query.MaxPrice}, Location={query.Location}, UnitTypeId={query.UnitTypeId}");
            
            var result = await _mediator.Send(query);
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var img in result.Items.Select(i => i.Images).SelectMany(i => i))
            {
                // Ensure absolute Url for the image
                if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                {
                    // Ensure absolute Url for the main image
                    if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                }
            }
            return Ok(result);
        }

        /// <summary>
        /// يعرض قائمة مبسطة للوحدات بحسب العقار فقط.
        /// Returns a simplified unit list filtered by property only.
        /// </summary>
        [HttpGet("simple")]
        public async Task<IActionResult> GetSimpleUnits([FromQuery] Guid? propertyId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
        {
            var query = new GetAdminUnitsSimpleQuery
            {
                PropertyId = propertyId,
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            var result = await _mediator.Send(query);

            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var img in result.Items.SelectMany(i => i.Images))
            {
                if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
            }

            return Ok(result);
        }

        /// <summary>
        /// ينشئ وحدة جديدة.
        /// Creates a new unit.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUnit([FromBody] CreateUnitCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث بيانات وحدة موجودة.
        /// Updates an existing unit.
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUnit(Guid id, [FromBody] UpdateUnitCommand command)
        {
            command.UnitId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف وحدة من النظام.
        /// Deletes a unit from the system.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUnit(Guid id)
        {
            var command = new DeleteUnitCommand { UnitId = id };
            var result = await _mediator.Send(command);
            if (!result.Success)
                return Conflict(result);
            return Ok(result);
        }

        /// <summary>
        /// يربط الوحدة بعدة أقسام دفعة واحدة.
        /// Associates the unit with multiple sections in one request.
        /// </summary>
        [HttpPost("{id}/sections")]
        public async Task<IActionResult> AddUnitToSections(Guid id, [FromBody] AddUnitToSectionsCommand command)
        {
            command.UnitId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض بيانات وحدة بحسب المعرف.
        /// Returns unit data by identifier.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUnitById(Guid id)
        {
            var query = new GetUnitByIdQuery { UnitId = id };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض تفاصيل الوحدة مع الحقول الديناميكية عند الطلب.
        /// Returns unit details with dynamic fields when requested.
        /// </summary>
        [HttpGet("{unitId}/details")]
        public async Task<IActionResult> GetUnitDetails(Guid unitId, [FromQuery] bool includeDynamicFields = true)
        {
            var query = new GetUnitByIdQuery { UnitId = unitId, IncludeDynamicFields = includeDynamicFields };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض تحليلات الوحدة خلال النطاق الزمني المحدد.
        /// Returns unit analytics for the specified time range.
        /// </summary>
        [HttpGet("{unitId}/analytics")]
        public async Task<IActionResult> GetUnitAnalytics(
            Guid unitId,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate)
        {
            var query = new GetUnitAnalyticsQuery
            {
                UnitId = unitId,
                FromDate = fromDate,
                ToDate = toDate
            };

            var result = await _mediator.Send(query);
            return Ok(result);
        }

    }
}
