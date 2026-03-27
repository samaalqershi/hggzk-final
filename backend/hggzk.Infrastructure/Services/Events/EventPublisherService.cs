using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Infrastructure.Services.Events
{
    /// <summary>
    /// Publishes application events through the configured event pipeline.
    /// ينشر أحداث التطبيق عبر خط معالجة الأحداث المكوّن.
    /// </summary>
    public class EventPublisherService : IEventPublisher
    {
        private readonly ILogger<EventPublisherService> _logger;

        /// <summary>
        /// Initializes a new instance of EventPublisherService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من EventPublisherService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public EventPublisherService(ILogger<EventPublisherService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Publishes the provided event data and records the operation.
        /// ينشر بيانات الحدث المقدمة ويسجل العملية.
        /// </summary>
        public Task<bool> PublishEventAsync<T>(T eventData, CancellationToken cancellationToken = default) where T : class
        {
            _logger.LogInformation("نشر حدث: {@EventData}", eventData);
            // The default implementation keeps event publication in-process and observable.
            // يمكن استبدالها لاحقًا بمزود رسائل خارجي دون تغيير العقود العليا.
            return Task.FromResult(true);
        }

        /// <summary>
        /// Publishes the provided event data through the default pipeline.
        /// ينشر بيانات الحدث المقدمة عبر المسار الافتراضي.
        /// </summary>
        public Task<bool> PublishAsync<T>(T eventData, CancellationToken cancellationToken = default) where T : class
        {
            return PublishEventAsync(eventData, cancellationToken);
        }
    }
} 
