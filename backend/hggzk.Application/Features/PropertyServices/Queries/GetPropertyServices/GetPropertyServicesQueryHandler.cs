using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.PropertyServices.Queries.GetPropertyServices
{
    /// <summary>
    /// يسترجع خدمات عقار محدد مع التحقق من الوصول.
    /// Retrieves a property's services while enforcing access rules.
    /// </summary>
    public class GetPropertyServicesQueryHandler : IRequestHandler<GetPropertyServicesQuery, ResultDto<IEnumerable<ServiceDto>>>
    {
        private readonly IPropertyServiceRepository _serviceRepository;
        private readonly ILogger<GetPropertyServicesQueryHandler> _logger;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يهيئ معالج جلب خدمات العقار.
        /// Initializes the property services query handler.
        /// </summary>
        public GetPropertyServicesQueryHandler(
            IPropertyServiceRepository serviceRepository,
            ILogger<GetPropertyServicesQueryHandler> logger,
            ICurrentUserService currentUserService)
        {
            _serviceRepository = serviceRepository;
            _logger = logger;
            _currentUserService = currentUserService;
        }

        /// <summary>
        /// يعالج Get Property Services الوارد.
        /// Processes the incoming get property services query.
        /// </summary>
        public async Task<ResultDto<IEnumerable<ServiceDto>>> Handle(GetPropertyServicesQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري معالجة استعلام خدمات الكيان: {PropertyId}", request.PropertyId);

            // Enforce access: Admin can access all; Owner must only access their property
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);

            if (!isAdmin)
            {
                var prop = await _serviceRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);
                if (prop == null)
                    return ResultDto<IEnumerable<ServiceDto>>.Failed("الكيان غير موجود");

                var isOwnerAuthorized = prop.OwnerId == _currentUserService.UserId;
                var isStaffAuthorized = _currentUserService.IsStaffInProperty(request.PropertyId);
                if (!(isOwnerAuthorized || isStaffAuthorized))
                    return ResultDto<IEnumerable<ServiceDto>>.Failed("غير مصرح لك بعرض خدمات هذا الكيان");
            }

            var services = await _serviceRepository.GetPropertyServicesAsync(request.PropertyId, cancellationToken);

            var dtos = services.Select(s => new ServiceDto
            {
                Id = s.Id,
                PropertyId = s.PropertyId,
                PropertyName = s.Property?.Name ?? string.Empty,
                PropertyNameEn = s.Property?.NameEn,
                Name = s.Name,
                NameEn = s.NameEn,
                Description = s.Description,
                DescriptionEn = s.DescriptionEn,
                Price = new MoneyDto
                {
                    Amount = s.Price.Amount,
                    Currency = s.Price.Currency
                },
                PricingModel = s.PricingModel
            }).ToList();

            return ResultDto<IEnumerable<ServiceDto>>.Ok(dtos, "تم جلب خدمات الكيان بنجاح");
        }
    }
} 
