using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace YemenBooking.Api.Swagger
{
    /// <summary>
    /// Configures Swagger to describe <see cref="IFormFile"/> uploads in multipart/form-data requests.
    /// يهيئ Swagger لوصف رفع ملفات <see cref="IFormFile"/> ضمن طلبات multipart/form-data.
    /// </summary>
    public class SwaggerFileOperationFilter : IOperationFilter
    {
        /// <summary>
        /// Applies multipart/form-data schema generation for actions that consume uploaded files from form data.
        /// يطبق إنشاء مخطط multipart/form-data للإجراءات التي تستقبل ملفات مرفوعة من بيانات النموذج.
        /// </summary>
        /// <param name="operation">The generated OpenAPI operation. العملية المولدة في OpenAPI.</param>
        /// <param name="context">The Swagger generation context. سياق توليد Swagger.</param>
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            var hasConsumesAttribute = context.MethodInfo.GetCustomAttributes(true)
                .OfType<ConsumesAttribute>()
                .Any(attr => attr.ContentTypes.Contains("multipart/form-data"));

            if (!hasConsumesAttribute)
                return;

            var properties = new Dictionary<string, OpenApiSchema>();
            var requiredParams = new HashSet<string>();

            foreach (var param in context.MethodInfo.GetParameters())
            {
                var hasFromFormAttribute = param.GetCustomAttributes(true)
                    .Any(attr => attr is FromFormAttribute);

                if (!hasFromFormAttribute)
                    continue;

                var paramType = param.ParameterType;
                var paramName = param.Name ?? "unknown";

                if (paramType == typeof(IFormFile) || typeof(IEnumerable<IFormFile>).IsAssignableFrom(paramType))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "string",
                        Format = "binary",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(string) || Nullable.GetUnderlyingType(paramType) == typeof(string))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "string",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(bool) || paramType == typeof(bool?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "boolean",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(int) || paramType == typeof(int?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "integer",
                        Format = "int32",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(long) || paramType == typeof(long?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "integer",
                        Format = "int64",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(decimal) || paramType == typeof(decimal?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "number",
                        Format = "decimal",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(float) || paramType == typeof(float?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "number",
                        Format = "float",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType == typeof(double) || paramType == typeof(double?))
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "number",
                        Format = "double",
                        Nullable = IsNullable(paramType)
                    };
                }
                else if (paramType.IsEnum || Nullable.GetUnderlyingType(paramType)?.IsEnum == true)
                {
                    properties[paramName] = new OpenApiSchema
                    {
                        Type = "string",
                        Nullable = IsNullable(paramType)
                    };
                }
                else
                {
                    foreach (var prop in paramType.GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance))
                    {
                        if (prop.PropertyType == typeof(IFormFile) ||
                            typeof(IEnumerable<IFormFile>).IsAssignableFrom(prop.PropertyType))
                        {
                            properties[prop.Name] = new OpenApiSchema
                            {
                                Type = "string",
                                Format = "binary",
                                Nullable = IsNullable(prop.PropertyType)
                            };
                        }
                    }
                }

                if (!IsNullable(paramType))
                {
                    requiredParams.Add(paramName);
                }
            }

            if (!properties.Any())
                return;

            operation.RequestBody = new OpenApiRequestBody
            {
                Content =
                {
                    ["multipart/form-data"] = new OpenApiMediaType
                    {
                        Schema = new OpenApiSchema
                        {
                            Type = "object",
                            Properties = properties,
                            Required = requiredParams
                        }
                    }
                }
            };

            operation.Parameters?.Clear();
        }

        /// <summary>
        /// دالة IsNullable.
        /// IsNullable method.
        /// </summary>
        private static bool IsNullable(System.Type type)
        {
            if (!type.IsValueType)
                return true;

            return Nullable.GetUnderlyingType(type) != null;
        }
    }
} 
