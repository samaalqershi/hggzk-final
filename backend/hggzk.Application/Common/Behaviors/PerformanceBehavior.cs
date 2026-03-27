using MediatR;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace YemenBooking.Application.Common.Behaviors;

/// <summary>
/// سلوك ضمن خط MediatR لقياس زمن تنفيذ الطلبات وتسجيله لأغراض المتابعة.
/// MediatR pipeline behavior that measures and logs request execution time for observability.
/// </summary>
public class PerformanceBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<PerformanceBehavior<TRequest, TResponse>> _logger;

    /// <summary>
    /// يهيئ سلوك قياس الأداء مع المسجل المناسب.
    /// Initializes the performance behavior with the appropriate logger.
    /// </summary>
    /// <param name="logger">مسجل الأداء. Performance logger.</param>
    public PerformanceBehavior(ILogger<PerformanceBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// يقيس الزمن المستغرق لتنفيذ الطلب ويسجل النتيجة بعد اكتمال المعالجة.
    /// Measures the elapsed time for the request and logs the result after processing completes.
    /// </summary>
    /// <param name="request">الطلب الجاري معالجته. Request being processed.</param>
    /// <param name="next">المعالج التالي في السلسلة. Next pipeline delegate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>الاستجابة الناتجة من المعالج التالي. Response returned by the next handler.</returns>
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var stopwatch = Stopwatch.StartNew();
        
        _logger.LogInformation("Starting performance monitoring for {RequestName}", typeof(TRequest).Name);
        
        var response = await next();
        
        stopwatch.Stop();
        
        _logger.LogInformation("Completed {RequestName} in {ElapsedMilliseconds} ms", 
            typeof(TRequest).Name, stopwatch.ElapsedMilliseconds);
        
        return response;
    }
}
