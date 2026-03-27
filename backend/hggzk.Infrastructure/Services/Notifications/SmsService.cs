using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Infrastructure.Services.Notifications
{
    /// <summary>
    /// يمثل خدمة إرسال الرسائل القصيرة عبر المزود المتاح.
    /// Represents the SMS sending service over the configured provider.
    /// </summary>
    public class SmsService : ISmsService
    {
        private readonly ILogger<SmsService> _logger;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة الرسائل القصيرة.
        /// Creates a new instance of the SMS service.
        /// </summary>
        public SmsService(ILogger<SmsService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// يسجل طلب الإرسال ويعيد نتيجة نجاح افتراضية حتى يجهز مزود SMS الخارجي.
        /// Logs the send request and returns a successful placeholder result until an external SMS provider is configured.
        /// </summary>
        public Task<bool> SendSmsAsync(string phoneNumber, string message, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("إرسال SMS إلى: {PhoneNumber}, الرسالة: {Message}", phoneNumber, message);
            // The default marketplace package ships with a logging stub until an external SMS gateway is configured.
            // الحزمة الافتراضية تعتمد تنفيذًا توثيقيًا يسجل الطلب فقط إلى أن يتم ربط مزود SMS خارجي.
            return Task.FromResult(true);
        }
    }
} 
