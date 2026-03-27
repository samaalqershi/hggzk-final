using MediatR;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Application.Common.Behaviors;

/// <summary>
/// سلوك ضمن خط MediatR لتسجيل مرور الطلب عبر مرحلة التفويض على مستوى الطبقة التطبيقية.
/// MediatR pipeline behavior that logs when a request passes through the application-layer authorization stage.
/// </summary>
public class AuthorizationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<AuthorizationBehavior<TRequest, TResponse>> _logger;

    /// <summary>
    /// يهيئ سلوك التفويض بالمسجل المناسب لنوع الطلب الحالي.
    /// Initializes the authorization behavior with a logger scoped to the current request type.
    /// </summary>
    /// <param name="logger">مسجل السلوك. Behavior logger.</param>
    public AuthorizationBehavior(ILogger<AuthorizationBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// يسجل عبور الطلب لمرحلة التفويض ثم يمرره إلى المعالج التالي دون فرض سياسة مستقلة.
    /// Logs the authorization stage and forwards the request without enforcing a separate policy by itself.
    /// </summary>
    /// <param name="request">الطلب الجاري معالجته. Request being processed.</param>
    /// <param name="next">المعالج التالي في السلسلة. Next pipeline delegate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>الاستجابة النهائية للطلب. Final response produced by the pipeline.</returns>
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Checking authorization for {RequestName}", typeof(TRequest).Name);

        var response = await next();
        _logger.LogInformation("Authorization check completed for {RequestName}", typeof(TRequest).Name);

        return response;
    }
}
