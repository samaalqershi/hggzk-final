using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
// using YemenBooking.Application.Features.Search; // غير موجود
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.SearchSuggestions
{
    /// <summary>
    /// يعالج جلب البحث suggestions ويعيد النتيجة المطلوبة.
    /// Processes the Get Search Suggestions request and returns the requested result.
    /// </summary>
    public class GetSearchSuggestionsQueryHandler : IRequestHandler<GetSearchSuggestionsQuery, ResultDto<List<string>>>
    {
        private readonly ISearchLogRepository _searchLogRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly ILogger<GetSearchSuggestionsQueryHandler> _logger;

        /// <summary>
        /// ينشئ مثيلاً جديداً من GetSearchSuggestionsQueryHandler.
        /// Initializes a new instance of GetSearchSuggestionsQueryHandler.
        /// </summary>
        /// <param name="searchLogRepository">مستودع البحث عن log / Search Log repository.</param>
        /// <param name="propertyRepository">مستودع البيانات العقارية / Real-estate repository.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        public GetSearchSuggestionsQueryHandler(
            ISearchLogRepository searchLogRepository,
            IPropertyRepository propertyRepository,
            ILogger<GetSearchSuggestionsQueryHandler> logger)
        {
            _searchLogRepository = searchLogRepository;
            _propertyRepository = propertyRepository;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<List<string>>> Handle(GetSearchSuggestionsQuery request, CancellationToken cancellationToken)
        {
            var normalizedQuery = (request.Query ?? string.Empty).Trim();
            var effectiveLimit = Math.Clamp(request.Limit, 1, 20);

            if (normalizedQuery.Length < 2)
            {
                return ResultDto<List<string>>.Ok(
                    new List<string>(),
                    "Search suggestions fetched successfully");
            }

            _logger.LogInformation(
                "Fetching search suggestions for query: {Query}, limit: {Limit}",
                normalizedQuery,
                effectiveLimit);

            // Primary source: indexed properties search (PostgreSQL FTS + Trigram).
            var propertySuggestions = await _propertyRepository.GetSearchSuggestionsAsync(
                normalizedQuery,
                effectiveLimit,
                cancellationToken);

            // Secondary source: recent successful search terms from search logs.
            var logs = await _searchLogRepository.GetQueryable()
                .Where(x =>
                    x.SearchType == "Property" &&
                    x.ResultCount > 0 &&
                    !string.IsNullOrEmpty(x.CriteriaJson))
                .OrderByDescending(x => x.CreatedAt)
                .Take(effectiveLimit * 20)
                .ToListAsync(cancellationToken);

            var logSuggestions = logs
                .Select(x => TryExtractSearchTerm(x.CriteriaJson))
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => s!.Trim())
                .Where(s => s.Contains(normalizedQuery, System.StringComparison.OrdinalIgnoreCase))
                .Distinct(System.StringComparer.OrdinalIgnoreCase)
                .Take(effectiveLimit)
                .ToList();

            var merged = MergeSuggestions(
                propertySuggestions,
                logSuggestions,
                effectiveLimit);

            return ResultDto<List<string>>.Ok(
                merged,
                "Search suggestions fetched successfully");
        }

        private static List<string> MergeSuggestions(
            IEnumerable<string> primary,
            IEnumerable<string> secondary,
            int limit)
        {
            var results = new List<string>(limit);
            var seen = new HashSet<string>(System.StringComparer.OrdinalIgnoreCase);

            foreach (var suggestion in primary.Concat(secondary))
            {
                if (string.IsNullOrWhiteSpace(suggestion))
                {
                    continue;
                }

                var trimmed = suggestion.Trim();
                if (!seen.Add(trimmed))
                {
                    continue;
                }

                results.Add(trimmed);
                if (results.Count >= limit)
                {
                    break;
                }
            }

            return results;
        }

        private static string? TryExtractSearchTerm(string criteriaJson)
        {
            if (string.IsNullOrWhiteSpace(criteriaJson))
            {
                return null;
            }

            try
            {
                using var doc = JsonDocument.Parse(criteriaJson);
                var root = doc.RootElement;

                if (TryGetCaseInsensitiveProperty(root, "SearchTerm", out var searchTermElement))
                {
                    return searchTermElement.ValueKind == JsonValueKind.String
                        ? searchTermElement.GetString()
                        : searchTermElement.ToString();
                }

                if (TryGetCaseInsensitiveProperty(root, "query", out var queryElement))
                {
                    return queryElement.ValueKind == JsonValueKind.String
                        ? queryElement.GetString()
                        : queryElement.ToString();
                }
            }
            catch (JsonException)
            {
                // Ignore malformed log payloads.
            }

            return null;
        }

        private static bool TryGetCaseInsensitiveProperty(
            JsonElement element,
            string propertyName,
            out JsonElement value)
        {
            if (element.ValueKind == JsonValueKind.Object)
            {
                foreach (var prop in element.EnumerateObject())
                {
                    if (string.Equals(
                        prop.Name,
                        propertyName,
                        System.StringComparison.OrdinalIgnoreCase))
                    {
                        value = prop.Value;
                        return true;
                    }
                }
            }

            value = default;
            return false;
        }
    }
}
