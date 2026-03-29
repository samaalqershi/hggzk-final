using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Localization;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using Microsoft.Extensions.FileProviders;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.StaticFiles;
using YemenBooking.Api.Middlewares;

namespace YemenBooking.Api.Extensions
{
    /// <summary>
    /// امتدادات لتكوين middleware الخاصة بتطبيق YemenBooking.
    /// Extensions for configuring YemenBooking middleware.
    /// </summary>
    public static class ApplicationBuilderExtensions
    {
        /// <summary>
        /// يهيئ جميع middleware: إعادة التوجيه لـ HTTPS، المصادقة، التفويض، OpenAPI وربط المتحكمات.
        /// Configures middleware: HTTPS redirection, authentication, authorization, OpenAPI, and controllers.
        /// </summary>
        public static WebApplication UseYemenBookingMiddlewares(this WebApplication app)
        {
            // Request logging middleware for debugging
            app.Use(async (context, next) =>
            {
                // Log multipart/form-data requests
                if (context.Request.ContentType?.Contains("multipart/form-data") == true)
                {
                    Console.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Multipart request: {context.Request.Method} {context.Request.Path}");
                    Console.WriteLine($"  Content-Type: {context.Request.ContentType}");
                    Console.WriteLine($"  Content-Length: {context.Request.ContentLength}");
                }
                await next();
            });
            
            // منع الوصول المباشر إلى مرفقات الشات.
            // Prevent direct access to chat attachments.
            app.Use(async (context, next) =>
                {
                    if (context.Request.Path.StartsWithSegments("/uploads/ChatAttachments"))
                    {
                        context.Response.StatusCode = StatusCodes.Status403Forbidden;
                        return;
                    }
                    await next();
                });

            // خدمة ملفات الستاتيك: مسار wwwroot الافتراضي.
            // Serve static files from the default wwwroot path.
            app.UseStaticFiles();
            // خدمة رفع الصور/الفيديو من مجلد Uploads.
            // Serve uploaded images and videos from the Uploads folder.
            var uploadsRoot = Path.Combine(Directory.GetCurrentDirectory(), "Uploads");
            if (!Directory.Exists(uploadsRoot)) Directory.CreateDirectory(uploadsRoot);

            var provider = new FileExtensionContentTypeProvider();
            // Ensure mp4 served with video/mp4
            provider.Mappings[".mp4"] = "video/mp4";
            provider.Mappings[".webm"] = "video/webm";
            provider.Mappings[".mov"] = "video/quicktime";
            provider.Mappings[".mkv"] = "video/x-matroska";

            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new PhysicalFileProvider(uploadsRoot),
                RequestPath = "/uploads",
                ContentTypeProvider = provider
            });

            // إعادة التوجيه إلى HTTPS (تجاوز في بيئة التطوير).
            // Redirect to HTTPS (skipped in development).
            if (!app.Environment.IsDevelopment())
            {
                app.UseHttpsRedirection();
            }

            // تفعيل نظام التوجيه.
            // Enable routing.
            app.UseRouting();
            app.UseRequestLocalization();
            app.UseLocalizedExceptions();
            // Log resolved endpoint for each request (helps detect routing issues)
            app.Use(async (context, next) =>
            {
                var endpoint = context.GetEndpoint();
                Console.WriteLine($"[Routing] Endpoint: {endpoint?.DisplayName ?? "null"} Path: {context.Request.Path}");
                await next();
            });
            // تطبيق سياسة CORS قبل المصادقة.
            // Apply the CORS policy before authentication.
            app.UseCors("AllowFrontend");
            // المصادقة باستخدام JWT.
            // Authenticate using JWT.
            app.UseAuthentication();
            // Reject deleted/disabled accounts even if they still have a valid JWT
            app.UseUserAccountStatus();
            // تتبع نشاط المستخدم (يجب أن يأتي بعد المصادقة ليتمكن من الوصول لمعرف المستخدم).
            // Track user activity; this must run after authentication to access the user ID.
            app.UseUserActivityTracking();
            // التفويض.
            // Authorize the request.
            app.UseAuthorization();

            // WebSockets disabled: chat now uses Firebase Cloud Messaging

            // تفعيل Swagger UI في بيئة التطوير.
            // Enable Swagger UI in development.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI(c =>
                {
                    c.SwaggerEndpoint("/swagger/v1/swagger.json", "YemenBooking API V1");
                    c.RoutePrefix = "swagger"; // اجعل Swagger على /swagger بدلاً من الجذر. // Place Swagger at /swagger instead of the root.
                });
                // اجعل الجذر يعيد التوجيه إلى واجهة Swagger بدلاً من واجهة العميل.
                // Redirect the root path to Swagger instead of the client UI.
                app.MapGet("/", ctx => { ctx.Response.Redirect("/swagger"); return Task.CompletedTask; });
            }

            // ربط المتحكمات بنظام التوجيه.
            // Map controllers into the routing system.
            app.MapControllers();

            // لم يعد هناك أي SPA/React fallback؛ الواجهة الوحيدة هي Swagger وواجهات الـ API.
            // There is no SPA/React fallback; the only entry points are Swagger and the API.
            return app;
        }
    }
}
