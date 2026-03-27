using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace YemenBooking.Api.Infrastructure.ModelBinders
{
    /// <summary>
    /// Custom model binder for binding query parameters in the format key[subkey]=value to <see cref="Dictionary{TKey, TValue}"/>.
    /// رابط نماذج مخصص لربط معاملات الاستعلام بصيغة key[subkey]=value إلى <see cref="Dictionary{TKey, TValue}"/>.
    /// </summary>
    public class DictionaryModelBinder : IModelBinder
    {
        /// <summary>
        /// حقل _logger.
        /// _logger field.
        /// </summary>
        private readonly ILogger<DictionaryModelBinder> _logger;

        /// <summary>
        /// Creates the binder used to map query values into a dictionary.
        /// ينشئ الرابط المسؤول عن تحويل قيم الاستعلام إلى قاموس.
        /// </summary>
        public DictionaryModelBinder(ILogger<DictionaryModelBinder> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Binds query string values to a <see cref="Dictionary{TKey, TValue}"/>.
        /// يربط القيم القادمة من query string إلى <see cref="Dictionary{TKey, TValue}"/>.
        /// </summary>
        public Task BindModelAsync(ModelBindingContext bindingContext)
        {
            if (bindingContext == null)
                throw new ArgumentNullException(nameof(bindingContext));

            var modelName = bindingContext.ModelName;
            
            _logger.LogInformation("🔧 [DictionaryModelBinder] Starting binding for model: {ModelName}", modelName);
            
            // Ensure the target type is Dictionary<string, string>.
            // التحقق من أن النوع المستهدف هو Dictionary<string, string>.
            if (bindingContext.ModelType != typeof(Dictionary<string, string>))
            {
                _logger.LogWarning("⚠️ [DictionaryModelBinder] Target type is not Dictionary<string, string>");
                return Task.CompletedTask;
            }

            var dictionary = new Dictionary<string, string>();
            
            // Read all keys from HttpContext.Request.Query.
            // الحصول على جميع المفاتيح من HttpContext.Request.Query.
            var request = bindingContext.HttpContext.Request;
            
            if (request.Query == null || !request.Query.Any())
            {
                _logger.LogInformation("🔧 [DictionaryModelBinder] No query parameters were provided");
                bindingContext.Result = ModelBindingResult.Success(dictionary);
                return Task.CompletedTask;
            }

            _logger.LogInformation("🔧 [DictionaryModelBinder] Total query parameters: {Count}", request.Query.Count);
            
            // Find keys that start with modelName[.
            // البحث عن المفاتيح التي تبدأ بـ modelName[.
            var prefix = $"{modelName}[";
            var matchingKeys = request.Query.Keys
                .Where(k => k.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                .ToList();

            _logger.LogInformation("🔧 [DictionaryModelBinder] Matching keys for '{Prefix}': {Count}", prefix, matchingKeys.Count);

            if (!matchingKeys.Any())
            {
                _logger.LogInformation("🔧 [DictionaryModelBinder] No matching values found; returning an empty dictionary");
                bindingContext.Result = ModelBindingResult.Success(dictionary);
                return Task.CompletedTask;
            }

            // Process each key and its value.
            // معالجة كل مفتاح وقيمته.
            foreach (var fullKey in matchingKeys)
            {
                var values = request.Query[fullKey];
                
                if (values.Count > 0)
                {
                    var value = values[0];
                    
                    if (!string.IsNullOrWhiteSpace(value))
                    {
                        // Extract the actual key from dynamicFieldFilters[key].
                        // استخراج المفتاح الفعلي من dynamicFieldFilters[key].
                        var startIndex = prefix.Length;
                        var endIndex = fullKey.IndexOf(']', startIndex);
                        
                        if (endIndex > startIndex)
                        {
                            var actualKey = fullKey.Substring(startIndex, endIndex - startIndex);
                            dictionary[actualKey] = value;
                            
                            _logger.LogInformation("🔧 [DictionaryModelBinder] Added entry: {Key} = {Value}", actualKey, value);
                        }
                    }
                }
            }

            _logger.LogInformation("🔧 [DictionaryModelBinder] Final dictionary contains {Count} entries", dictionary.Count);
            
            bindingContext.Result = ModelBindingResult.Success(dictionary);
            return Task.CompletedTask;
        }
    }

    /// <summary>
    /// Provider for <see cref="DictionaryModelBinder"/>.
    /// المزوّد الخاص بـ <see cref="DictionaryModelBinder"/>.
    /// </summary>
    public class DictionaryModelBinderProvider : IModelBinderProvider
    {
        /// <summary>
        /// Returns a binder for <see cref="Dictionary{TKey, TValue}"/> fields.
        /// يعيد رابطًا مناسبًا للحقول من نوع <see cref="Dictionary{TKey, TValue}"/>.
        /// </summary>
        public IModelBinder? GetBinder(ModelBinderProviderContext context)
        {
            if (context == null)
                throw new ArgumentNullException(nameof(context));

            // Apply only to Dictionary<string, string>.
            // يطبّق فقط على Dictionary<string, string>.
            if (context.Metadata.ModelType == typeof(Dictionary<string, string>))
            {
                var loggerFactory = context.Services.GetService(typeof(ILoggerFactory)) as ILoggerFactory;
                var logger = loggerFactory?.CreateLogger<DictionaryModelBinder>();
                
                return new DictionaryModelBinder(logger ?? throw new InvalidOperationException("Logger is required"));
            }

            return null;
        }
    }
}
