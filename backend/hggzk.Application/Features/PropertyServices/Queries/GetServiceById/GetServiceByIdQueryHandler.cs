using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.PropertyServices.Queries.GetServiceById
{
    /// <summary>
    /// يمثل عنصرًا عامًا ضمن هذه الميزة.
    /// Represents a general element in this feature.
    /// </summary>
    public class GetServiceByIdQueryHandler : IRequestHandler<GetServiceByIdQuery, ResultDto<ServiceDetailsDto>>
    {
        private readonly IPropertyServiceRepository _serviceRepository;
        private readonly ILogger<GetServiceByIdQueryHandler> _logger;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [GetServiceByIdQueryHandler].
        /// Initializes a new instance of [GetServiceByIdQueryHandler].
        /// </summary>
        public GetServiceByIdQueryHandler(
            IPropertyServiceRepository serviceRepository,
            ILogger<GetServiceByIdQueryHandler> logger,
            ICurrentUserService currentUserService)
        {
            _serviceRepository = serviceRepository;
            _logger = logger;
            _currentUserService = currentUserService;
        }

        /// <summary>
        /// يعالج Get Service By Id الوارد.
        /// Processes the incoming get service by id query.
        /// </summary>
        public async Task<ResultDto<ServiceDetailsDto>> Handle(GetServiceByIdQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري معالجة استعلام تفاصيل الخدمة: {ServiceId}", request.ServiceId);

            var service = await _serviceRepository.GetQueryable()
                .AsNoTracking()
                .Include(s => s.Property)
                .FirstOrDefaultAsync(s => s.Id == request.ServiceId, cancellationToken);

            if (service == null)
            {
                return ResultDto<ServiceDetailsDto>.Failure("الخدمة غير موجودة");
            }

            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            if (!isAdmin)
            {
                var isOwnerAuthorized = service.Property?.OwnerId == _currentUserService.UserId;
                var isStaffAuthorized = _currentUserService.IsStaffInProperty(service.PropertyId);
                if (!(isOwnerAuthorized || isStaffAuthorized))
                    return ResultDto<ServiceDetailsDto>.Failure("غير مصرح لك بعرض هذه الخدمة");
            }

            var dto = new ServiceDetailsDto
            {
                Id = service.Id,
                PropertyId = service.PropertyId,
                PropertyName = service.Property?.Name ?? string.Empty,
                Name = service.Name,
                Icon = service.Icon,
                Description = service.Description,
                Price = new MoneyDto
                {
                    Amount = service.Price.Amount,
                    Currency = service.Price.Currency
                },
                PricingModel = service.PricingModel
            };

            return ResultDto<ServiceDetailsDto>.Ok(dto, "تم جلب بيانات الخدمة بنجاح");
        }
    }
} 
