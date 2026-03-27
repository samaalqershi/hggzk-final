using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Bookings.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingById
{
    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
    public class GetBookingByIdQueryHandler : IRequestHandler<GetBookingByIdQuery, ResultDto<BookingDetailsDto>>
    {
        private readonly IBookingRepository _bookingRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetBookingByIdQueryHandler> _logger;
        private readonly IUnitRepository _unitRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IDailyUnitScheduleRepository _dailyUnitScheduleRepository;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
        public GetBookingByIdQueryHandler(
            IBookingRepository bookingRepository,
            ICurrentUserService currentUserService,
            IMapper mapper,
            ILogger<GetBookingByIdQueryHandler> logger,
            IUnitRepository unitRepository,
            IPropertyRepository propertyRepository,
            IDailyUnitScheduleRepository dailyUnitScheduleRepository)
        {
            _bookingRepository = bookingRepository;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _logger = logger;
            _unitRepository = unitRepository;
            _propertyRepository = propertyRepository;
            _dailyUnitScheduleRepository = dailyUnitScheduleRepository;
        }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
        public async Task<ResultDto<BookingDetailsDto>> Handle(GetBookingByIdQuery request, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("جاري معالجة استعلام تفاصيل الحجز: {BookingId}", request.BookingId);

                // التحقق من صحة المعرف
                if (request.BookingId == Guid.Empty)
                {
                    return ResultDto<BookingDetailsDto>.Failure("معرف الحجز غير صالح");
                }

                // جلب الحجز مع المدفوعات
                var booking = await _bookingRepository.GetBookingWithPaymentsAsync(request.BookingId, cancellationToken);
                if (booking == null)
                {
                    return ResultDto<BookingDetailsDto>.Failure($"الحجز بالمعرف {request.BookingId} غير موجود");
                }

                // جلب الخدمات المرتبطة
                var bookingWithServices = await _bookingRepository.GetBookingWithServicesAsync(request.BookingId, cancellationToken);
                if (bookingWithServices != null)
                {
                    booking.BookingServices = bookingWithServices.BookingServices;
                }

                // التحقق من الصلاحيات: Admin كامل، وإتاحة للمالك/الموظف ضمن نفس العقار
                var user = await _currentUserService.GetCurrentUserAsync(cancellationToken);
                if (user == null)
                {
                    return ResultDto<BookingDetailsDto>.Failure("يجب تسجيل الدخول لعرض تفاصيل الحجز");
                }
                var roles = _currentUserService.UserRoles;
                var isAdmin = roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));
                var currentUserId = _currentUserService.UserId;
                
                if (!isAdmin)
                {
                    var unitForAuth = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
                    if (unitForAuth == null)
                    {
                        return ResultDto<BookingDetailsDto>.Failure("الوحدة المرتبطة بالحجز غير موجودة");
                    }

                    var propertyForAuth = await _propertyRepository.GetByIdAsync(unitForAuth.PropertyId, cancellationToken);
                    if (propertyForAuth == null)
                    {
                        return ResultDto<BookingDetailsDto>.Failure("العقار المرتبط بالحجز غير موجود");
                    }

                    var scopedPropertyId = _currentUserService.PropertyId;
                    var hasPropertyScope = scopedPropertyId.HasValue &&
                                           scopedPropertyId.Value != Guid.Empty &&
                                           scopedPropertyId.Value == propertyForAuth.Id;

                    if (propertyForAuth.OwnerId != currentUserId && !hasPropertyScope)
                    {
                        return ResultDto<BookingDetailsDto>.Failure("ليس لديك صلاحية لعرض هذا الحجز");
                    }
                }

                // التحويل إلى DTO مع حقول المبالغ والعملة
                var detailsDto = _mapper.Map<BookingDetailsDto>(booking);
                
                var servicesTotal = booking.BookingServices?.Sum(bs => bs.TotalPrice.Amount) ?? 0m;
                var baseAmount = await CalculateAccommodationAmountAsync(booking, cancellationToken);
                if (baseAmount <= 0m)
                {
                    baseAmount = booking.TotalPrice.Amount - servicesTotal;
                }
                if (baseAmount < 0m)
                {
                    baseAmount = 0m;
                }

                var totalWithServices = booking.TotalPrice.Amount;
                var recomputedTotal = baseAmount + servicesTotal;
                if (recomputedTotal > 0m &&
                    (totalWithServices <= 0m ||
                     totalWithServices < baseAmount ||
                     (servicesTotal > 0m && totalWithServices <= servicesTotal)))
                {
                    totalWithServices = recomputedTotal;
                }
                
                // Ensure totals/currency are populated even if mapper config changes
                detailsDto.TotalAmount = baseAmount;
                detailsDto.Currency = booking.TotalPrice.Currency;
                // Add TotalPrice as object for Flutter app compatibility (including services)
                detailsDto.TotalPrice = new MoneyDto
                {
                    Amount = totalWithServices,
                    Currency = booking.TotalPrice.Currency,
                    ExchangeRate = 1
                };
                detailsDto.BookingDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.BookedAt);
                // Include policy snapshot captured at booking time
                detailsDto.PolicySnapshot = booking.PolicySnapshot;
                detailsDto.PolicySnapshotAt = booking.PolicySnapshotAt;
                detailsDto.CheckInDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn);
                detailsDto.CheckOutDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckOut);

                // enrich with unit and property information for admin details page
                var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
                if (unit != null)
                {
                    detailsDto.UnitId = unit.Id;
                    detailsDto.UnitName = unit.Name ?? string.Empty;
                    detailsDto.UnitImages = unit.Images?.Select(i => i.Url).ToList() ?? new System.Collections.Generic.List<string>();

                    var property = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
                    if (property != null)
                    {
                        detailsDto.PropertyId = property.Id;
                        detailsDto.PropertyName = property.Name ?? string.Empty;
                        detailsDto.PropertyAddress = property.Address ?? string.Empty;
                    }
                }

                // Normalize other date-like fields on details DTO if present
                detailsDto.BookedAt = detailsDto.BookingDate;
                detailsDto.CheckIn = detailsDto.CheckInDate;
                detailsDto.CheckOut = detailsDto.CheckOutDate;
                if (detailsDto.ActualCheckInDate.HasValue)
                    detailsDto.ActualCheckInDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(detailsDto.ActualCheckInDate.Value);
                if (detailsDto.ActualCheckOutDate.HasValue)
                    detailsDto.ActualCheckOutDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(detailsDto.ActualCheckOutDate.Value);

                _logger.LogInformation("تم جلب تفاصيل الحجز بنجاح: {BookingId}", request.BookingId);
                return ResultDto<BookingDetailsDto>.Ok(detailsDto, "تم جلب تفاصيل الحجز بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة استعلام تفاصيل الحجز: {BookingId}", request.BookingId);
                return ResultDto<BookingDetailsDto>.Failure("حدث خطأ أثناء جلب تفاصيل الحجز");
            }
        }

        private async Task<decimal> CalculateAccommodationAmountAsync(Core.Entities.Booking booking, CancellationToken cancellationToken)
        {
            try
            {
                var checkInLocal = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn);
                var checkOutLocal = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckOut);
                var startDate = checkInLocal.Date;
                var endDate = checkOutLocal.Date > checkInLocal.Date
                    ? checkOutLocal.Date.AddDays(-1)
                    : checkInLocal.Date;

                var expectedDays = (endDate - startDate).Days + 1;
                if (expectedDays <= 0)
                {
                    expectedDays = 1;
                }

                var schedules = (await _dailyUnitScheduleRepository.GetByUnitAndDateRangeAsync(
                    booking.UnitId,
                    startDate,
                    endDate)).ToList();

                var pricedDays = schedules.Count(s => s.PriceAmount.HasValue);
                if (pricedDays < expectedDays)
                {
                    return 0m;
                }

                var total = schedules.Sum(s => s.PriceAmount ?? 0m);
                return total > 0m ? decimal.Round(total, 2) : 0m;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر إعادة حساب تكلفة الإقامة من الجداول للحجز {BookingId}", booking.Id);
                return 0m;
            }
        }
    }
}
