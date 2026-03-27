using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Analytics.Services;

namespace YemenBooking.Infrastructure.Services.Analytics
{
    /// <summary>
    /// Provides analytics event tracking for application telemetry.
    /// يوفر تتبع أحداث التحليلات لقياس استخدام التطبيق.
    /// </summary>
    public class AnalyticsTrackerService : IAnalyticsTrackerService
    {
        private readonly ILogger<AnalyticsTrackerService> _logger;

        /// <summary>
        /// Initializes the service with a logger instance.
        /// يهيئ الخدمة باستخدام مسجل أحداث.
        /// </summary>
        public AnalyticsTrackerService(ILogger<AnalyticsTrackerService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Tracks an analytics event with the supplied properties.
        /// يسجل حدثًا تحليليًا مع الخصائص الممررة.
        /// </summary>
        public Task TrackEventAsync(string eventName, Dictionary<string, string> properties)
        {
            _logger.LogInformation("تتبع حدث: {EventName} بخصائص: {@Properties}", eventName, properties);
            return Task.CompletedTask;
        }
    }
} 
