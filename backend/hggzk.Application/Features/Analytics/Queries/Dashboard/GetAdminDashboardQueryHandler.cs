using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.Dashboard
{
/// <summary>
/// يعالج استعلام لوحة معلومات المسؤول ويعيد النتيجة.
/// Processes the admin dashboard query and returns the result.
/// </summary>
    public class GetAdminDashboardQueryHandler : IRequestHandler<GetAdminDashboardQuery, AdminDashboardDto>
    {
        private readonly IUserRepository _userRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IBookingRepository _bookingRepository;
        private readonly IReportingService _reportingService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<GetAdminDashboardQueryHandler> _logger;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public GetAdminDashboardQueryHandler(
            IUserRepository userRepository,
            IPropertyRepository propertyRepository,
            IBookingRepository bookingRepository,
            IReportingService reportingService,
            ICurrentUserService currentUserService,
            ILogger<GetAdminDashboardQueryHandler> logger)
        {
            _userRepository = userRepository;
            _propertyRepository = propertyRepository;
            _bookingRepository = bookingRepository;
            _reportingService = reportingService;
            _currentUserService = currentUserService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the admin dashboard query and returns the result.
    /// </summary>
        public async Task<AdminDashboardDto> Handle(GetAdminDashboardQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing Admin Dashboard Query for range {Start} - {End}", request.Range.StartDate, request.Range.EndDate);

            // Authorization: Admin only
            var currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
            if (currentUser == null || !_currentUserService.UserRoles.Contains("Admin"))
            {
                _logger.LogWarning("Unauthorized access to admin dashboard");
                throw new UnauthorizedAccessException("يجب أن تكون مسؤولًا للوصول إلى لوحة التحكم");
            }

            // Fetch data
            var totalUsers = await _userRepository.CountAsync(cancellationToken);
            var totalProperties = await _propertyRepository.CountAsync(cancellationToken);
            // Convert incoming range from user local to UTC
            var startUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.Range.StartDate);
            var endUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.Range.EndDate);
            var totalBookings = await _bookingRepository.GetTotalBookingsCountAsync(null, startUtc, endUtc);
            var totalRevenue = await _reportingService.CalculateRevenueAsync(startUtc, endUtc, null, cancellationToken);

            return new AdminDashboardDto
            {
                TotalUsers = totalUsers,
                TotalProperties = totalProperties,
                TotalBookings = totalBookings,
                TotalRevenue = totalRevenue
            };
        }
    }
} 
