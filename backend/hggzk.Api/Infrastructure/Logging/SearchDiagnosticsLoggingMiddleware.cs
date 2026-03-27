using System.Diagnostics;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Serilog.Context;

namespace YemenBooking.Api.Infrastructure.Logging;

/// <summary>
/// Writes detailed diagnostics for search and filter requests into the structured log pipeline.
/// يسجل تشخيصات مفصلة لطلبات البحث والفلترة داخل خط اللوج المنظم.
/// </summary>
public sealed class SearchDiagnosticsLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<SearchDiagnosticsLoggingMiddleware> _logger;
    private readonly IConfiguration _configuration;

    public SearchDiagnosticsLoggingMiddleware(
        RequestDelegate next,
        ILogger<SearchDiagnosticsLoggingMiddleware> logger,
        IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (!IsEnabled() || !IsSearchPath(context.Request.Path))
        {
            await _next(context);
            return;
        }

        var stopwatch = Stopwatch.StartNew();
        var requestBody = await ReadRequestBodyAsync(context.Request).ConfigureAwait(false);
        var requestQuery = context.Request.QueryString.HasValue
            ? context.Request.QueryString.Value
            : string.Empty;
        var remoteIp = context.Connection.RemoteIpAddress?.ToString();

        using (LogContext.PushProperty("SearchDiagnostics", true))
        using (LogContext.PushProperty("TraceIdentifier", context.TraceIdentifier))
        using (LogContext.PushProperty("RequestPath", context.Request.Path.Value ?? string.Empty))
        using (LogContext.PushProperty("RequestMethod", context.Request.Method))
        {
            _logger.LogInformation(
                "Search HTTP request started. TraceId={TraceId}, Method={Method}, Path={Path}, Query={Query}, Body={Body}, RemoteIp={RemoteIp}",
                context.TraceIdentifier,
                context.Request.Method,
                context.Request.Path.Value,
                requestQuery,
                requestBody,
                remoteIp);

            try
            {
                await _next(context);

                stopwatch.Stop();
                _logger.LogInformation(
                    "Search HTTP request completed. TraceId={TraceId}, Method={Method}, Path={Path}, StatusCode={StatusCode}, ElapsedMs={ElapsedMs}",
                    context.TraceIdentifier,
                    context.Request.Method,
                    context.Request.Path.Value,
                    context.Response.StatusCode,
                    stopwatch.ElapsedMilliseconds);
            }
            catch (Exception ex)
            {
                stopwatch.Stop();
                _logger.LogError(
                    ex,
                    "Search HTTP request failed. TraceId={TraceId}, Method={Method}, Path={Path}, ElapsedMs={ElapsedMs}",
                    context.TraceIdentifier,
                    context.Request.Method,
                    context.Request.Path.Value,
                    stopwatch.ElapsedMilliseconds);
                throw;
            }
        }
    }

    private bool IsEnabled()
        => _configuration.GetValue("SearchDiagnosticsLogging:Enabled", true);

    private static bool IsSearchPath(PathString path)
    {
        if (!path.HasValue)
        {
            return false;
        }

        return path.StartsWithSegments("/api/client/properties/search", StringComparison.OrdinalIgnoreCase) ||
               path.StartsWithSegments("/api/client/search-filters/filters", StringComparison.OrdinalIgnoreCase);
    }

    private async Task<string> ReadRequestBodyAsync(HttpRequest request)
    {
        if (request.ContentLength is null or 0 || request.Body is null)
        {
            return string.Empty;
        }

        var maxLength = Math.Max(256, _configuration.GetValue("SearchDiagnosticsLogging:MaxRequestBodyLength", 8000));
        request.EnableBuffering();
        request.Body.Position = 0;

        using var reader = new StreamReader(
            request.Body,
            Encoding.UTF8,
            detectEncodingFromByteOrderMarks: false,
            leaveOpen: true);

        var body = await reader.ReadToEndAsync().ConfigureAwait(false);
        request.Body.Position = 0;

        if (body.Length <= maxLength)
        {
            return body;
        }

        return $"{body[..maxLength]}... [truncated]";
    }
}
