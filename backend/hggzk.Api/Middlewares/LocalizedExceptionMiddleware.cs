using System.Text.Json;
using YemenBooking.Api.Infrastructure.Localization;
using YemenBooking.Application.Common.Exceptions;

namespace YemenBooking.Api.Middlewares;

/// <summary>
/// Converts unhandled exceptions into localized API payloads.
/// يحول الاستثناءات غير المعالجة إلى استجابات API مترجمة.
/// </summary>
public sealed class LocalizedExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<LocalizedExceptionMiddleware> _logger;

    public LocalizedExceptionMiddleware(
        RequestDelegate next,
        ILogger<LocalizedExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, IBackendTextLocalizer localizer)
    {
        try
        {
            await _next(context);
        }
        catch (Exception exception) when (!context.Response.HasStarted)
        {
            var (statusCode, message, errorCode, errors) = MapException(exception, localizer);

            if (statusCode >= StatusCodes.Status500InternalServerError)
            {
                _logger.LogError(exception, "Unhandled exception returned to client as localized payload.");
            }
            else
            {
                _logger.LogWarning(exception, "Handled exception returned to client as localized payload.");
            }

            context.Response.Clear();
            context.Response.StatusCode = statusCode;
            context.Response.ContentType = "application/json";

            var payload = new
            {
                success = false,
                message,
                errorCode,
                errors
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(payload));
        }
    }

    private static (int StatusCode, string Message, string? ErrorCode, IReadOnlyList<string> Errors) MapException(
        Exception exception,
        IBackendTextLocalizer localizer)
    {
        return exception switch
        {
            ValidationException validationException => (
                StatusCodes.Status400BadRequest,
                localizer.Translate("common.invalidData"),
                "VALIDATION_ERROR",
                validationException.Errors.Any()
                    ? localizer.TranslateMany(validationException.Errors)
                    : new[] { localizer.Translate("common.invalidData") }),

            NotFoundException notFoundException => (
                StatusCodes.Status404NotFound,
                LocalizeNotFoundMessage(localizer, notFoundException),
                "NOT_FOUND",
                new[] { LocalizeNotFoundMessage(localizer, notFoundException) }),

            ForbiddenException forbiddenException => (
                StatusCodes.Status403Forbidden,
                LocalizeForbiddenMessage(localizer, forbiddenException),
                "FORBIDDEN",
                new[] { LocalizeForbiddenMessage(localizer, forbiddenException) }),

            UnauthorizedException unauthorizedException => (
                StatusCodes.Status401Unauthorized,
                LocalizeUnauthorizedMessage(localizer, unauthorizedException),
                "UNAUTHORIZED",
                new[] { LocalizeUnauthorizedMessage(localizer, unauthorizedException) }),

            UnauthorizedAccessException unauthorizedAccessException => (
                StatusCodes.Status401Unauthorized,
                localizer.Translate(unauthorizedAccessException.Message),
                "UNAUTHORIZED",
                BuildSingleError(localizer, unauthorizedAccessException.Message)),

            BusinessRuleException businessRuleException => (
                StatusCodes.Status409Conflict,
                localizer.Translate(businessRuleException.Message),
                businessRuleException.RuleCode ?? businessRuleException.RuleName,
                BuildSingleError(localizer, businessRuleException.Message)),

            KeyNotFoundException keyNotFoundException => (
                StatusCodes.Status404NotFound,
                localizer.Translate(keyNotFoundException.Message),
                "NOT_FOUND",
                BuildSingleError(localizer, keyNotFoundException.Message)),

            OperationCanceledException operationCanceledException => (
                StatusCodes.Status408RequestTimeout,
                localizer.Translate(string.IsNullOrWhiteSpace(operationCanceledException.Message)
                    ? "common.requestCancelled"
                    : operationCanceledException.Message),
                "REQUEST_CANCELLED",
                BuildSingleError(localizer, string.IsNullOrWhiteSpace(operationCanceledException.Message)
                    ? "common.requestCancelled"
                    : operationCanceledException.Message)),

            _ => (
                StatusCodes.Status500InternalServerError,
                localizer.Translate("common.unexpectedError"),
                "UNEXPECTED_ERROR",
                BuildSingleError(localizer, "common.unexpectedError"))
        };
    }

    private static IReadOnlyList<string> BuildSingleError(IBackendTextLocalizer localizer, string? input)
    {
        var translated = localizer.Translate(input);
        return string.IsNullOrWhiteSpace(translated)
            ? Array.Empty<string>()
            : new[] { translated };
    }

    private static string LocalizeNotFoundMessage(IBackendTextLocalizer localizer, NotFoundException exception)
    {
        if (!string.IsNullOrWhiteSpace(exception.ObjectType))
        {
            return localizer.Translate($"{exception.ObjectType} not found");
        }

        return localizer.Translate(exception.Message);
    }

    private static string LocalizeForbiddenMessage(IBackendTextLocalizer localizer, ForbiddenException exception)
    {
        if (!string.IsNullOrWhiteSpace(exception.OperationType) || !string.IsNullOrWhiteSpace(exception.Resource))
        {
            return localizer.Translate("common.permissionDenied");
        }

        return localizer.Translate(exception.Message);
    }

    private static string LocalizeUnauthorizedMessage(IBackendTextLocalizer localizer, UnauthorizedException exception)
    {
        if (!string.IsNullOrWhiteSpace(exception.OperationType) || !string.IsNullOrWhiteSpace(exception.Resource))
        {
            return localizer.Translate("common.unauthorized");
        }

        return localizer.Translate(exception.Message);
    }
}

/// <summary>
/// Extension methods for registering the localized exception middleware.
/// امتدادات لتسجيل middleware الاستثناءات المترجمة.
/// </summary>
public static class LocalizedExceptionMiddlewareExtensions
{
    public static IApplicationBuilder UseLocalizedExceptions(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<LocalizedExceptionMiddleware>();
    }
}
