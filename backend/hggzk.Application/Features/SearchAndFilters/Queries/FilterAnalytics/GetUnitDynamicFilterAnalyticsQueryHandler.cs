using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Features.Units.Queries.SearchUnits;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.FilterAnalytics
{
    /// <summary>
    /// يعالج جلب الوحدة الديناميكي تصفية التحليلات ويعيد النتيجة المطلوبة.
    /// Processes the Get Unit Dynamic Filter Analytics request and returns the requested result.
    /// </summary>
    public class GetUnitDynamicFilterAnalyticsQueryHandler : IRequestHandler<GetUnitDynamicFilterAnalyticsQuery, ResultDto<List<FieldFilterAnalyticsDto>>>
    {
        private readonly ISearchLogRepository _searchLogRepository;
        private readonly ILogger<GetUnitDynamicFilterAnalyticsQueryHandler> _logger;

        /// <summary>
        /// ينشئ مثيلاً جديداً من GetUnitDynamicFilterAnalyticsQueryHandler.
        /// Initializes a new instance of GetUnitDynamicFilterAnalyticsQueryHandler.
        /// </summary>
        /// <param name="searchLogRepository">مستودع البحث عن log / Search Log repository.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        public GetUnitDynamicFilterAnalyticsQueryHandler(
            ISearchLogRepository searchLogRepository,
            ILogger<GetUnitDynamicFilterAnalyticsQueryHandler> logger)
        {
            _searchLogRepository = searchLogRepository;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<List<FieldFilterAnalyticsDto>>> Handle(
            GetUnitDynamicFilterAnalyticsQuery request,
            CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري حساب احصائيات الفلاتر الديناميكية للوحدات من {From} إلى {To}", request.From, request.To);

            var query = _searchLogRepository.GetQueryable()
                .Where(x => x.SearchType == "Unit");

            if (request.From.HasValue)
                query = query.Where(x => x.CreatedAt >= request.From.Value);

            if (request.To.HasValue)
                query = query.Where(x => x.CreatedAt <= request.To.Value);

            var logs = await query.ToListAsync(cancellationToken);

            var entries = new List<(Guid fieldId, string fieldValue)>();

            foreach (var log in logs)
            {
                try
                {
                    var search = JsonSerializer.Deserialize<SearchUnitsQuery>(log.CriteriaJson);
                    if (search?.DynamicFieldFilters != null)
                    {
                        entries.AddRange(search.DynamicFieldFilters
                            .Select(f => (f.FieldId, f.FieldValue)));
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "فشل تحليل معايير الفلتر الديناميكي في السجل {LogId}", log.Id);
                }
            }

            var analytics = entries
                .GroupBy(e => e.fieldId)
                .Select(g => new FieldFilterAnalyticsDto
                {
                    FieldId = g.Key,
                    ValueCounts = g.GroupBy(e => e.fieldValue)
                                   .Select(vg => new FilterValueCountDto
                                   {
                                       FilterValue = vg.Key,
                                       Count = vg.Count()
                                   }).ToList()
                }).ToList();

            return ResultDto<List<FieldFilterAnalyticsDto>>.Succeeded(analytics);
        }
    }
} 