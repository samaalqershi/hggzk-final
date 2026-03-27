using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.SearchSuggestions
{
    /// <summary>
    /// استعلام جلب البحث suggestions.
    /// Get Search Suggestions query.
    /// </summary>
    public class GetSearchSuggestionsQuery : IRequest<ResultDto<List<string>>>
    {
        /// <summary>
        /// القيمة الخاصة بـ الاستعلام.
        /// Query value.
        /// </summary>
        public string Query { get; set; } = string.Empty;

        /// <summary>
        /// القيمة الخاصة بـ limit.
        /// Limit value.
        /// </summary>
        public int Limit { get; set; } = 10;
    }
}