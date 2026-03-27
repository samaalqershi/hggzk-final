using FluentValidation;
using MediatR;

namespace YemenBooking.Application.Common.Behaviors;

/// <summary>
/// سلوك ضمن خط MediatR لتطبيق جميع المدققات المسجلة قبل تنفيذ الطلب.
/// MediatR pipeline behavior that applies all registered validators before a request is executed.
/// </summary>
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    /// <summary>
    /// حقل _validators.
    /// _validators field.
    /// </summary>
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    /// <summary>
    /// يهيئ سلوك التحقق بالمدققات المرتبطة بنوع الطلب.
    /// Initializes the validation behavior with the validators registered for the request type.
    /// </summary>
    /// <param name="validators">مجموعة المدققات. Validator collection.</param>
    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    /// <summary>
    /// يشغل التحقق قبل تمرير الطلب إلى المعالج التالي ويرمي استثناءً عند وجود أخطاء.
    /// Runs validation before forwarding the request to the next handler and throws when failures are found.
    /// </summary>
    /// <param name="request">الطلب المراد التحقق منه. Request to validate.</param>
    /// <param name="next">المعالج التالي في السلسلة. Next pipeline delegate.</param>
    /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
    /// <returns>الاستجابة الناتجة إذا نجح التحقق. Response returned when validation succeeds.</returns>
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (_validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);
            var validationResults = await Task.WhenAll(_validators.Select(v => v.ValidateAsync(context, cancellationToken)));
            var failures = validationResults.SelectMany(r => r.Errors).Where(f => f != null).ToList();

            if (failures.Count != 0)
                throw new Exceptions.ValidationException(failures);
        }
        return await next();
    }
}
