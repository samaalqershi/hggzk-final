using System;
using System.Text;
using System.Text.Json;

namespace YemenBooking.Api.Json
{
    /// <summary>
    /// يطبّق تحويل أسماء الخصائص إلى snake_case.
    /// Converts property names to snake_case.
    /// </summary>
    public class SnakeCaseNamingPolicy : JsonNamingPolicy
    {
        /// <summary>
        /// يحول الاسم المعطى إلى snake_case.
        /// Converts the given name to snake_case.
        /// </summary>
        public override string ConvertName(string name)
        {
            if (string.IsNullOrEmpty(name))
                return name;
            var builder = new StringBuilder();
            builder.Append(char.ToLowerInvariant(name[0]));
            for (int i = 1; i < name.Length; i++)
            {
                var c = name[i];
                if (char.IsUpper(c))
                {
                    builder.Append('_');
                    builder.Append(char.ToLowerInvariant(c));
                }
                else
                {
                    builder.Append(c);
                }
            }
            return builder.ToString();
        }
    }
} 
