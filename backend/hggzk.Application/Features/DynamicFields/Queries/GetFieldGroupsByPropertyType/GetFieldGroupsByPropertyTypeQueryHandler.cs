using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Application.Features.DynamicFields.Queries.GetFieldGroupsByUnitType;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.DynamicFields.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.DynamicFields.Queries.GetFieldGroupsByPropertyType
{
    /// <summary>
    /// معالج استعلام جلب مجموعات الحقول لنوع وحدة معين
    /// Query handler for GetFieldGroupsByUnitTypeQuery
    /// </summary>
    public class GetFieldGroupsByUnitTypeQueryHandler : IRequestHandler<GetFieldGroupsByUnitTypeQuery, List<FieldGroupDto>>
    {
        private readonly IFieldGroupRepository _groupRepository;
        private readonly ILogger<GetFieldGroupsByUnitTypeQueryHandler> _logger;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public GetFieldGroupsByUnitTypeQueryHandler(
            IFieldGroupRepository groupRepository,
            ILogger<GetFieldGroupsByUnitTypeQueryHandler> logger)
        {
            _groupRepository = groupRepository;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the field groups by property type query and returns the result.
    /// </summary>
        public async Task<List<FieldGroupDto>> Handle(GetFieldGroupsByUnitTypeQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري معالجة استعلام جلب مجموعات الحقول لنوع وحدة: {UnitTypeId}", request.UnitTypeId);

            if (!Guid.TryParse(request.UnitTypeId, out var typeId))
                throw new ValidationException(nameof(request.UnitTypeId), "معرف نوع الوحدة غير صالح");

            var groups = await _groupRepository.GetGroupsByUnitTypeIdAsync(typeId, cancellationToken);
            var dtos = groups
                .OrderBy(g => g.SortOrder)
                .Select(g => new FieldGroupDto
                {
                    GroupId = g.Id.ToString(),
                    UnitTypeId = g.UnitTypeId.ToString(),
                    GroupName = g.GroupName,
                    GroupNameEn = g.GroupNameEn,
                    DisplayName = g.DisplayName,
                    DisplayNameEn = g.DisplayNameEn,
                    Description = g.Description,
                    DescriptionEn = g.DescriptionEn,
                    SortOrder = g.SortOrder,
                    IsCollapsible = g.IsCollapsible,
                    IsExpandedByDefault = g.IsExpandedByDefault
                })
                .ToList();

            return dtos;
        }
    }
} 
