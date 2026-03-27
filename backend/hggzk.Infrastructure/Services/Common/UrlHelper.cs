using System;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Infrastructure.Services.Common
{
    /// <summary>
    /// Provides URL normalization helpers for the application.
    /// يوفّر أدوات مساعدة لتطبيع عناوين URL في التطبيق.
    /// </summary>
    public class UrlHelper : IUrlHelper
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IConfiguration _configuration;

        /// <summary>
        /// Initializes a new instance of UrlHelper with the required dependencies.
        /// يهيئ مثيلاً جديدًا من UrlHelper باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public UrlHelper(IHttpContextAccessor httpContextAccessor, IConfiguration configuration)
        {
            _httpContextAccessor = httpContextAccessor;
            _configuration = configuration;
        }

        /// <summary>
        /// Resolves the base application URL from the request or configuration.
        /// يحدد عنوان التطبيق الأساسي من الطلب أو الإعدادات.
        /// </summary>
        public string GetBaseUrl()
        {
            // Try to get from HttpContext first (most accurate)
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext != null)
            {
                var request = httpContext.Request;
                return $"{request.Scheme}://{request.Host}";
            }

            // Fallback to configuration
            var baseUrl = _configuration["BaseUrl"];
            if (!string.IsNullOrEmpty(baseUrl))
            {
                return baseUrl;
            }

            // Fallback to default
            return "http://localhost:5000";
        }

        /// <summary>
        /// Converts a relative path to an absolute URL.
        /// يحوّل المسار النسبي إلى عنوان URL مطلق.
        /// </summary>
        public string ToAbsoluteUrl(string? relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
            {
                return string.Empty;
            }

            // Already absolute URL
            if (relativePath.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                relativePath.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                return relativePath;
            }

            // Ensure path starts with /
            if (!relativePath.StartsWith("/"))
            {
                relativePath = "/" + relativePath;
            }

            var baseUrl = GetBaseUrl();
            return $"{baseUrl}{relativePath}";
        }

        /// <summary>
        /// Converts an absolute URL to a relative path.
        /// يحوّل عنوان URL المطلق إلى مسار نسبي.
        /// </summary>
        public string ToRelativePath(string? absoluteUrl)
        {
            if (string.IsNullOrWhiteSpace(absoluteUrl))
            {
                return string.Empty;
            }

            // Already relative path
            if (!absoluteUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
                !absoluteUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                return absoluteUrl;
            }

            try
            {
                var uri = new Uri(absoluteUrl);
                return uri.PathAndQuery;
            }
            catch
            {
                return absoluteUrl;
            }
        }
    }
}
