using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.Dashboard
{
/// <summary>
/// يعالج استعلام إحصاءات لوحة المعلومات ويعيد النتيجة.
/// Processes the dashboard stats query and returns the result.
/// </summary>
    public class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardStatsDto>
    {
        private readonly IUserRepository _userRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IBookingRepository _bookingRepository;
        private readonly INotificationRepository _notificationRepository;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public GetDashboardStatsQueryHandler(
            IUserRepository userRepository,
            IPropertyRepository propertyRepository,
            IBookingRepository bookingRepository,
            INotificationRepository notificationRepository,
            ICurrentUserService currentUserService)
        {
            _userRepository = userRepository;
            _propertyRepository = propertyRepository;
            _bookingRepository = bookingRepository;
            _notificationRepository = notificationRepository;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the dashboard stats query and returns the result.
    /// </summary>
        public async Task<DashboardStatsDto> Handle(GetDashboardStatsQuery request, CancellationToken cancellationToken)
        {
            // عدد المستخدمين غير المؤكدين (استعلام عد مباشرة من قاعدة البيانات)
            var unverifiedCount = await _userRepository.CountAsync(u => !u.EmailConfirmed, cancellationToken);

            // عدد الكيانات غير المعتمدة
            var unapprovedCount = await _propertyRepository.CountAsync(p => !p.IsApproved, cancellationToken);

            // عدد الحجوزات غير المؤكدة (Pending)
            var unconfirmedBookingsCount = await _bookingRepository.CountAsync(b => b.Status == BookingStatus.Pending, cancellationToken);

            // عدد الاشعارات غير المقروءة للمستخدم الحالي
            var userId = _currentUserService.UserId;
            var unreadNotifications = await _notificationRepository.GetUnreadNotificationsCountAsync(userId, cancellationToken);

            return new DashboardStatsDto
            {
                UnverifiedUsers = unverifiedCount,
                UnapprovedProperties = unapprovedCount,
                UnconfirmedBookings = unconfirmedBookingsCount,
                UnreadNotifications = unreadNotifications
            };
        }
    }
} 
