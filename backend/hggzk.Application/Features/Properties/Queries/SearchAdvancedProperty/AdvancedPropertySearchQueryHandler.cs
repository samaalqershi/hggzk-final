using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Contracts.Persistence.Repositories.Search;
using System.Linq;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.SearchAdvancedProperty
{
/// <summary>
/// يعالج البحث المتقدم عن العقارات عبر المستودع المخصص.
/// Handles advanced property search through the dedicated repository.
/// </summary>
public class AdvancedPropertySearchQueryHandler : IRequestHandler<Properties.Queries.SearchAdvancedProperty.AdvancedPropertySearchQuery, PaginatedResult<AdvancedPropertyDto>>
{
        private readonly IAdvancedPropertySearchRepository _repository;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [AdvancedPropertySearchQueryHandler].
        /// Initializes a new instance of [AdvancedPropertySearchQueryHandler].
        /// </summary>
        public AdvancedPropertySearchQueryHandler(IAdvancedPropertySearchRepository repository)
        {
            _repository = repository;
        }
        /// <summary>
        /// يعالج البحث المتقدم عن العقارات عبر المرشحات المركبة.
        /// Handles advanced property search through combined filters.
        /// </summary>
        public async Task<PaginatedResult<AdvancedPropertyDto>> Handle(AdvancedPropertySearchQuery request, CancellationToken cancellationToken)
        {
            var allResults = await _repository.SearchAsync(request, cancellationToken);
            var totalCount = allResults.Count();
            var items = allResults
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize);
            return PaginatedResult<AdvancedPropertyDto>.Create(items, request.PageNumber, request.PageSize, totalCount);
        }
    }
} 
