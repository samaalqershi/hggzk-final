using MediatR;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Application.Common.Behaviors;

/// <summary>
/// سلوك ضمن خط MediatR لتسجيل بداية ونهاية معالجة الطلبات.
/// MediatR pipeline behavior that logs when request processing starts and finishes.
/// </summary>
public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    /// <summary>
    /// يهيئ سلوك التسجيل مع المسجل الخاص بنوع الطلب.
    /// Initializes the logging behavior with a logger for the current request type.
    /// </summary>
    /// <param name="logger">مسجل السلوك. Behavior logger.</param>
    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// يسجل معالجة الطلب ويمرر التنفيذ إلى المعالج التالي.
    /// Logs request processing and forwards execution to the next handler.
    /// </summary>
    /// <param name="request">الطلب الجاري معالجته. Request being processed.</param>
    /// <param name="next">المعالج التالي في السلسلة. Next pipeline delegate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>الاستجابة النهائية للطلب. Final request response.</returns>
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Handling {RequestName}", typeof(TRequest).Name);
        var response = await next();
        _logger.LogInformation("Handled {RequestName}", typeof(TRequest).Name);
        return response;
    }
}
