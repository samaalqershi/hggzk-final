using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Analytics.Services;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم تسجيل أحداث التحليلات الخاصة بالعميل.
    /// Client analytics event tracking controller.
    /// </summary>
    public class AnalyticsController : BaseClientController
    {
        /// <summary>
        /// خدمة تتبع التحليلات.
        /// Analytics tracking service.
        /// </summary>
        private readonly IAnalyticsTrackerService _analytics;

        /// <summary>
        /// يهيئ نسخة جديدة من [AnalyticsController].
        /// Initializes a new instance of [AnalyticsController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم داخل المتحكم. MediatR mediator used by the controller.</param>
        /// <param name="analytics">خدمة تتبع الأحداث التحليلية. Analytics tracking service.</param>
        public AnalyticsController(IMediator mediator, IAnalyticsTrackerService analytics)
            : base(mediator)
        {
            _analytics = analytics;
        }

        /// <summary>
        /// يسجل ظهور قسم في واجهة العميل.
        /// Records a section impression in the client UI.
        /// </summary>
        [HttpPost("section-impression")]
        [AllowAnonymous]
        public async Task<IActionResult> RecordSectionImpression([FromBody] SectionImpressionRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.SectionId))
                return BadRequest(new { success = false, message = "sectionId is required" });

            var props = new Dictionary<string, string>
            {
                ["sectionId"] = request.SectionId,
                ["timestamp"] = DateTime.UtcNow.ToString("o")
            };
            await _analytics.TrackEventAsync("section_impression", props);
            return NoContent();
        }

        /// <summary>
        /// يسجل تفاعل المستخدم مع قسم أو عنصر.
        /// Records a user interaction with a section or item.
        /// </summary>
        [HttpPost("section-interaction")]
        [AllowAnonymous]
        public async Task<IActionResult> RecordSectionInteraction([FromBody] SectionInteractionRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.SectionId) || string.IsNullOrWhiteSpace(request.InteractionType))
                return BadRequest(new { success = false, message = "sectionId and interactionType are required" });

            var props = new Dictionary<string, string>
            {
                ["sectionId"] = request.SectionId,
                ["interactionType"] = request.InteractionType,
                ["timestamp"] = DateTime.UtcNow.ToString("o")
            };
            if (!string.IsNullOrWhiteSpace(request.ItemId))
                props["itemId"] = request.ItemId!;
            if (request.Metadata != null)
            {
                foreach (var kv in request.Metadata)
                {
                    var key = kv.Key?.ToString();
                    if (string.IsNullOrWhiteSpace(key)) continue;
                    var value = kv.Value?.ToString() ?? string.Empty;
                    // Prefix to avoid collisions with reserved keys
                    props[$"meta_{key}"] = value;
                }
            }

            await _analytics.TrackEventAsync("section_interaction", props);
            return NoContent();
        }

        /// <summary>
        /// طلب تسجيل ظهور قسم.
        /// Request model for a section impression.
        /// </summary>
        public class SectionImpressionRequest
        {
            /// <summary>
            /// معرّف القسم.
            /// Section identifier.
            /// </summary>
            public string SectionId { get; set; } = string.Empty;
        }

        /// <summary>
        /// طلب تسجيل تفاعل مع قسم.
        /// Request model for a section interaction.
        /// </summary>
        public class SectionInteractionRequest
        {
            /// <summary>
            /// معرّف القسم.
            /// Section identifier.
            /// </summary>
            public string SectionId { get; set; } = string.Empty;
            /// <summary>
            /// نوع التفاعل.
            /// Interaction type.
            /// </summary>
            public string InteractionType { get; set; } = string.Empty;
            /// <summary>
            /// معرّف العنصر المرتبط.
            /// Related item identifier.
            /// </summary>
            public string? ItemId { get; set; }
            /// <summary>
            /// بيانات وصفية إضافية.
            /// Additional metadata.
            /// </summary>
            public Dictionary<string, object>? Metadata { get; set; }
        }
    }
}
