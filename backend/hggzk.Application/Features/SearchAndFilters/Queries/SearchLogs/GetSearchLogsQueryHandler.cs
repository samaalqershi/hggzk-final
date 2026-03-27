using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.SearchLogs
{
    /// <summary>
    /// يعالج جلب البحث logs ويعيد النتيجة المطلوبة.
    /// Processes the Get Search Logs request and returns the requested result.
    /// </summary>
    public class GetSearchLogsQueryHandler : IRequestHandler<GetSearchLogsQuery, PaginatedResult<SearchLogDto>>
    {
        private readonly ISearchLogRepository _searchLogRepository;
        private readonly ILogger<GetSearchLogsQueryHandler> _logger;

        /// <summary>
        /// ينشئ مثيلاً جديداً من GetSearchLogsQueryHandler.
        /// Initializes a new instance of GetSearchLogsQueryHandler.
        /// </summary>
        /// <param name="searchLogRepository">مستودع البحث عن log / Search Log repository.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        public GetSearchLogsQueryHandler(ISearchLogRepository searchLogRepository, ILogger<GetSearchLogsQueryHandler> logger)
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
        public async Task<PaginatedResult<SearchLogDto>> Handle(GetSearchLogsQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري جلب سجلات البحث من {From} إلى {To}", request.From, request.To);

            var query = _searchLogRepository.GetQueryable();

            if (request.From.HasValue)
                query = query.Where(x => x.CreatedAt >= request.From.Value);

            if (request.To.HasValue)
                query = query.Where(x => x.CreatedAt <= request.To.Value);

            if (request.UserId.HasValue)
                query = query.Where(x => x.UserId == request.UserId.Value);

            if (!string.IsNullOrWhiteSpace(request.SearchType))
                query = query.Where(x => x.SearchType == request.SearchType);

            var totalCount = await query.CountAsync(cancellationToken);

            var items = await query
                .OrderByDescending(x => x.CreatedAt)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .Select(x => new SearchLogDto
                {
                    Id = x.Id,
                    UserId = x.UserId,
                    SearchType = x.SearchType,
                    CriteriaJson = x.CriteriaJson,
                    ResultCount = x.ResultCount,
                    PageNumber = x.PageNumber,
                    PageSize = x.PageSize,
                    CreatedAt = x.CreatedAt
                })
                .ToListAsync(cancellationToken);

            return new PaginatedResult<SearchLogDto>
            {
                Items = items,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                TotalCount = totalCount
            };
        }
    }
} 