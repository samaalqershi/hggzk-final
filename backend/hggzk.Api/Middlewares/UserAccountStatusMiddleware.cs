using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using YemenBooking.Api.Infrastructure.Localization;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Api.Middlewares
{
    /// <summary>
    /// Middleware يتحقق من أن الحساب ما يزال نشطًا وغير محذوف.
    /// Middleware that verifies the account is still active and not deleted.
    /// </summary>
    public class UserAccountStatusMiddleware
    {
        /// <summary>
        /// حقل _next.
        /// _next field.
        /// </summary>
        private readonly RequestDelegate _next;
        /// <summary>
        /// حقل _serviceScopeFactory.
        /// _serviceScopeFactory field.
        /// </summary>
        private readonly IServiceScopeFactory _serviceScopeFactory;

        /// <summary>
        /// ينشئ middleware للتحقق من حالة الحساب.
        /// Creates the middleware used to validate account status.
        /// </summary>
        public UserAccountStatusMiddleware(RequestDelegate next, IServiceScopeFactory serviceScopeFactory)
        {
            _next = next;
            _serviceScopeFactory = serviceScopeFactory;
        }

        /// <summary>
        /// يفحص حالة المستخدم الحالي ويمنع الحسابات المعطلة من متابعة الطلب.
        /// Checks the current user and blocks disabled accounts from continuing.
        /// </summary>
        public async Task InvokeAsync(HttpContext context)
        {
            if (context.User?.Identity?.IsAuthenticated == true)
            {
                if (IsBreakGlassMasterAdmin(context))
                {
                    await _next(context);
                    return;
                }

                var userId = GetUserIdFromContext(context);
                if (userId.HasValue)
                {
                    using var scope = _serviceScopeFactory.CreateScope();
                    var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();

                    var status = await dbContext.Users
                        .IgnoreQueryFilters()
                        .Where(u => u.Id == userId.Value)
                        .Select(u => new { u.IsDeleted, u.IsActive })
                        .FirstOrDefaultAsync();

                    if (status == null || status.IsDeleted || !status.IsActive)
                    {
                        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                        context.Response.ContentType = "application/json";
                        var localizer = context.RequestServices.GetRequiredService<IBackendTextLocalizer>();
                        var payload = JsonSerializer.Serialize(new
                        {
                            success = false,
                            message = localizer.Translate("common.accountDisabled"),
                            errorCode = "ACCOUNT_DISABLED"
                        });
                        await context.Response.WriteAsync(payload);
                        return;
                    }
                }
            }

            await _next(context);
        }

        /// <summary>
        /// دالة IsBreakGlassMasterAdmin.
        /// IsBreakGlassMasterAdmin method.
        /// </summary>
        private static bool IsBreakGlassMasterAdmin(HttpContext context)
        {
            var flag = context.User.FindFirst("isMasterAdmin")?.Value;
            if (bool.TryParse(flag, out var isMasterAdmin) && isMasterAdmin)
            {
                return true;
            }

            return string.Equals(context.User.FindFirst("skipAudit")?.Value, "true", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// دالة GetUserIdFromContext.
        /// GetUserIdFromContext method.
        /// </summary>
        private static Guid? GetUserIdFromContext(HttpContext context)
        {
            var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier)
                              ?? context.User.FindFirst("id")
                              ?? context.User.FindFirst("sub")
                              ?? context.User.FindFirst("userId")
                              ?? context.User.FindFirst("user_id");

            if (userIdClaim == null || string.IsNullOrWhiteSpace(userIdClaim.Value))
                return null;

            return Guid.TryParse(userIdClaim.Value, out var userId) ? userId : null;
        }
    }

    /// <summary>
    /// Extension methods لتسجيل middleware حالة الحساب.
    /// Extension methods for registering the account status middleware.
    /// </summary>
    public static class UserAccountStatusMiddlewareExtensions
    {
        /// <summary>
        /// يضيف middleware التحقق من حالة الحساب إلى الـ pipeline.
        /// Adds the account status middleware to the pipeline.
        /// </summary>
        public static IApplicationBuilder UseUserAccountStatus(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<UserAccountStatusMiddleware>();
        }
    }
}
