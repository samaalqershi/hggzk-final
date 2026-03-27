using Microsoft.AspNetCore.Routing;
using System.Text.RegularExpressions;

namespace YemenBooking.Api.Transformers
{
    /// <summary>
    /// فئة KebabCaseParameterTransformer.
    /// KebabCaseParameterTransformer class.
    /// </summary>
    public class KebabCaseParameterTransformer : IOutboundParameterTransformer
    {
        /// <summary>
        /// دالة TransformOutbound.
        /// TransformOutbound method.
        /// </summary>
        public string? TransformOutbound(object? value)
        {
            if (value == null) return null;
            var str = value.ToString();
            if (string.IsNullOrEmpty(str)) return null;
            // Insert hyphens between lowercase and uppercase letters, then lowercase entire string
            return Regex.Replace(str, "([a-z])([A-Z])", "$1-$2").ToLower();
        }
    }
}