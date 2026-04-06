using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Bookings.DTOs;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features;
using System.Text.Json;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingDetails;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class GetBookingDetailsQueryHandler : IRequestHandler<GetBookingDetailsQuery, ResultDto<BookingDetailsDto>>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingServiceRepository _bookingServiceRepository;
    private readonly IDailyUnitScheduleRepository _dailyUnitScheduleRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<GetBookingDetailsQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public GetBookingDetailsQueryHandler(
        IBookingRepository bookingRepository,
        IReviewRepository reviewRepository,
        IPropertyRepository propertyRepository,
        IUnitRepository unitRepository,
        IPaymentRepository paymentRepository,
        IBookingServiceRepository bookingServiceRepository,
        IDailyUnitScheduleRepository dailyUnitScheduleRepository,
        IUserRepository userRepository,
        ILogger<GetBookingDetailsQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _bookingRepository = bookingRepository;
        _reviewRepository = reviewRepository;
        _propertyRepository = propertyRepository;
        _unitRepository = unitRepository;
        _paymentRepository = paymentRepository;
        _bookingServiceRepository = bookingServiceRepository;
        _dailyUnitScheduleRepository = dailyUnitScheduleRepository;
        _userRepository = userRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<BookingDetailsDto>> Handle(GetBookingDetailsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام تفاصيل الحجز. معرف الحجز: {BookingId}, معرف المستخدم: {UserId}", 
                request.BookingId, request.UserId);

            // التحقق من صحة البيانات المدخلة / Validate input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // الحصول على الحجز / Load the booking.
            var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                _logger.LogWarning("لم يتم العثور على الحجز: {BookingId}", request.BookingId);
                return ResultDto<BookingDetailsDto>.Failed("الحجز غير موجود", "BOOKING_NOT_FOUND");
            }

            var existingReview = await _reviewRepository.GetReviewByBookingAsync(booking.Id, cancellationToken);

            // جلب بيانات الوحدة والخدمات والمدفوعات بشكل تسلسلي لتجنب مشاركة DbContext بالتوازي / Load unit, services, and payments sequentially to avoid sharing the same DbContext in parallel.
            var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
            if (unit == null)
            {
                _logger.LogWarning("لم يتم العثور على الوحدة: {UnitId}", booking.UnitId);
                return ResultDto<BookingDetailsDto>.Failed("بيانات الوحدة غير متاحة", "UNIT_NOT_FOUND");
            }

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار: {PropertyId}", unit.PropertyId);
                return ResultDto<BookingDetailsDto>.Failed("بيانات العقار غير متاحة", "PROPERTY_NOT_FOUND");
            }

            var roles = _currentUserService.UserRoles;
            var isAdmin = roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));
            var requesterId = _currentUserService.UserId != Guid.Empty
                ? _currentUserService.UserId
                : request.UserId;
            var scopedPropertyId = _currentUserService.PropertyId;
            var hasPropertyScope = scopedPropertyId.HasValue &&
                                   scopedPropertyId.Value != Guid.Empty &&
                                   scopedPropertyId.Value == property.Id;

            var hasAccess = isAdmin ||
                            booking.UserId == requesterId ||
                            property.OwnerId == requesterId ||
                            hasPropertyScope;
            if (!hasAccess)
            {
                _logger.LogWarning("المستخدم {UserId} لا يملك صلاحية الوصول للحجز {BookingId}",
                    requesterId, request.BookingId);
                return ResultDto<BookingDetailsDto>.Failed("ليس لديك صلاحية للوصول لهذا الحجز", "ACCESS_DENIED");
            }

            var bookingServices = await _bookingServiceRepository.GetBookingServicesAsync(booking.Id, cancellationToken);
            var serviceDtos = bookingServices.Select(bs => new BookingServiceDto
            {
                Id = bs.ServiceId,
                Name = bs.Service?.Name ?? string.Empty,
                Quantity = bs.Quantity,
                TotalPrice = bs.TotalPrice.Amount,
                Currency = bs.TotalPrice.Currency ?? "YER"
            }).ToList();

            var payments = await _paymentRepository.GetPaymentsByBookingAsync(booking.Id, cancellationToken);
            var paymentDtos = payments.Select(p => new PaymentDto
            {
                Id = p.Id,
                BookingId = p.BookingId,
                Amount = p.Amount.Amount,
                Currency = p.Amount.Currency ?? "YER",
                Method = p.PaymentMethod,
                Status = p.Status,
                PaymentDate = p.PaymentDate,
                TransactionId = p.TransactionId ?? string.Empty
            }).ToList();

            var totalPaid = payments
                .Where(p => p.Status == PaymentStatus.Successful)
                .Sum(p => p.Amount.Amount);
            var isPaid = totalPaid >= booking.TotalPrice.Amount;

            bool canCancel = false;
            string? cancelNotAllowedCode = null;
            string? cancelNotAllowedReason = null;

            var hasPolicySnapshot = !string.IsNullOrWhiteSpace(booking.PolicySnapshot);
            var snapshotInfo = GetCancellationSnapshotInfo(booking.PolicySnapshot);

            if (booking.Status == BookingStatus.Pending)
            {
                canCancel = true;
            }
            else if (booking.Status != BookingStatus.Cancelled &&
                     booking.Status != BookingStatus.Completed &&
                     booking.Status != BookingStatus.CheckedIn)
            {
                if (booking.Status == BookingStatus.Confirmed)
                {
                    var allowsCancellation = hasPolicySnapshot
                        ? (snapshotInfo.AllowsCancellation ?? true)
                        : (snapshotInfo.AllowsCancellation ?? unit.AllowsCancellation);
                    if (!allowsCancellation)
                    {
                        canCancel = false;
                        cancelNotAllowedCode = "CANCELLATION_NOT_ALLOWED";
                        cancelNotAllowedReason = "سياسة الإلغاء الخاصة بهذا الحجز لا تسمح بإلغاء الحجز بعد التأكيد";
                    }
                    else
                    {
                        int? windowDays = hasPolicySnapshot
                            ? snapshotInfo.CancellationWindowDays
                            : (snapshotInfo.CancellationWindowDays ?? unit.CancellationWindowDays);

                        if (!hasPolicySnapshot && !windowDays.HasValue)
                        {
                            var propertyPolicy = await _propertyRepository.GetCancellationPolicyAsync(property.Id, cancellationToken);
                            windowDays = propertyPolicy?.CancellationWindowDays;
                        }

                        if (snapshotInfo.CancellationDaysBeforeCheckIn.HasValue)
                        {
                            windowDays = windowDays.HasValue
                                ? Math.Max(windowDays.Value, snapshotInfo.CancellationDaysBeforeCheckIn.Value)
                                : snapshotInfo.CancellationDaysBeforeCheckIn.Value;
                        }

                        var userNow = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow);
                        var checkInLocal = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn);
                        var userToday = userNow.Date;
                        var checkInLocalPolicyDate = checkInLocal.Date;
                        var daysBeforeCheckIn = (checkInLocalPolicyDate - userToday).TotalDays;

                        if (daysBeforeCheckIn < 0)
                        {
                            canCancel = false;
                            cancelNotAllowedCode = "CANCELLATION_AFTER_CHECKIN";
                            cancelNotAllowedReason = "لا يمكن إلغاء الحجز بعد وقت تسجيل الوصول";
                        }
                        else if (snapshotInfo.CancellationHoursBeforeCheckIn.HasValue)
                        {
                            var hoursBeforeCheckIn = (checkInLocal - userNow).TotalHours;
                            if (hoursBeforeCheckIn < snapshotInfo.CancellationHoursBeforeCheckIn.Value)
                            {
                                canCancel = false;
                                cancelNotAllowedCode = "CANCELLATION_WINDOW_EXCEEDED";
                                cancelNotAllowedReason = "لا يمكن إلغاء الحجز خلال نافذة الإلغاء المحددة";
                            }
                            else
                            {
                                canCancel = !windowDays.HasValue || daysBeforeCheckIn >= windowDays.Value;
                                if (!canCancel && windowDays.HasValue)
                                {
                                    cancelNotAllowedCode = "CANCELLATION_WINDOW_EXCEEDED";
                                    cancelNotAllowedReason = $"لا يمكن إلغاء الحجز خلال {windowDays.Value} يوم/أيام قبل تاريخ الوصول حسب سياسة الإلغاء";
                                }
                            }
                        }
                        else if (windowDays.HasValue && daysBeforeCheckIn < windowDays.Value)
                        {
                            canCancel = false;
                            cancelNotAllowedCode = "CANCELLATION_WINDOW_EXCEEDED";
                            cancelNotAllowedReason = $"لا يمكن إلغاء الحجز خلال {windowDays.Value} يوم/أيام قبل تاريخ الوصول حسب سياسة الإلغاء";
                        }
                        else
                        {
                            canCancel = true;
                        }
                    }
                }
                else
                {
                    // For non-final, non-confirmed states, allow cancellation. Final validation happens in the CancelBooking handler.
                    canCancel = true;
                }
            }

            // إنشاء DTO للاستجابة / Build the response DTO.
            var bookingDetailsDto = new BookingDetailsDto
            {
                Id = booking.Id,
                BookingNumber = booking.Id.ToString().Substring(0, 8),
                UserId = booking.UserId,
                UserName = _currentUserService.Username ?? string.Empty,
                UnitId = booking.UnitId,
                UnitName = unit.Name ?? string.Empty,
                PropertyId = property.Id,
                PropertyName = property.Name ?? string.Empty,
                PropertyAddress = property.Address ?? string.Empty,
                CheckIn = booking.CheckIn,
                CheckOut = booking.CheckOut,
                GuestsCount = booking.GuestsCount,
                Currency = booking.TotalPrice.Currency ?? "YER",
                Status = booking.Status,
                BookedAt = booking.BookedAt,
                BookingSource = booking.BookingSource,
                CancellationReason = booking.CancellationReason,
                IsWalkIn = booking.IsWalkIn,
                PlatformCommissionAmount = booking.PlatformCommissionAmount,
                ActualCheckInDate = booking.ActualCheckInDate,
                ActualCheckOutDate = booking.ActualCheckOutDate,
                TotalAmount = booking.TotalPrice.Amount,
                CustomerRating = (int?)booking.CustomerRating,
                CompletionNotes = booking.CompletionNotes,
                Services = serviceDtos,
                Payments = paymentDtos,
                UnitImages = unit.Images?.Select(img => img.Url).ToList() ?? new List<string>(),
                PolicySnapshot = booking.PolicySnapshot,
                PolicySnapshotAt = booking.PolicySnapshotAt,
                IsPaid = isPaid,
                CanCancel = canCancel,
                CancelNotAllowedCode = cancelNotAllowedCode,
                CancelNotAllowedReason = cancelNotAllowedReason,
                CanReview = booking.Status == BookingStatus.Completed && existingReview == null,
                UserReview = existingReview == null
                    ? null
                    : new BookingUserReviewDto
                    {
                        Id = existingReview.Id,
                        BookingId = existingReview.BookingId,
                        PropertyId = existingReview.PropertyId,
                        Cleanliness = existingReview.Cleanliness,
                        Service = existingReview.Service,
                        Location = existingReview.Location,
                        Value = existingReview.Value,
                        AverageRating = existingReview.AverageRating,
                        Comment = existingReview.Comment,
                        CreatedAt = existingReview.CreatedAt,
                        ResponseText = existingReview.ResponseText,
                        ResponseDate = existingReview.ResponseDate,
                        IsPendingApproval = existingReview.IsPendingApproval,
                        IsDisabled = existingReview.IsDisabled,
                        Images = existingReview.Images?
                            .OrderBy(img => img.DisplayOrder)
                            .Select(img => new ReviewImageDto
                            {
                                Id = img.Id,
                                ReviewId = img.ReviewId,
                                Name = img.Name,
                                Url = img.Url,
                                ThumbnailUrl = ReviewImageMetadataHelper.GetThumbnailUrl(img),
                                SizeBytes = img.SizeBytes,
                                Type = img.Type,
                                Category = img.Category,
                                Caption = img.Caption,
                                AltText = img.AltText,
                                UploadedAt = img.UploadedAt
                            })
                            .ToList() ?? new List<ReviewImageDto>()
                    }
            };

            _logger.LogInformation("تم الحصول على تفاصيل الحجز بنجاح. معرف الحجز: {BookingId}", request.BookingId);

            // Convert all DateTime fields to the user's local time.
            bookingDetailsDto.BookedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDetailsDto.BookedAt);
            bookingDetailsDto.CheckIn = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDetailsDto.CheckIn);
            bookingDetailsDto.CheckOut = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDetailsDto.CheckOut);
            if (bookingDetailsDto.ActualCheckInDate.HasValue)
                bookingDetailsDto.ActualCheckInDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDetailsDto.ActualCheckInDate.Value);
            if (bookingDetailsDto.ActualCheckOutDate.HasValue)
                bookingDetailsDto.ActualCheckOutDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDetailsDto.ActualCheckOutDate.Value);
            bookingDetailsDto.BookingDate = bookingDetailsDto.BookedAt;
            if (bookingDetailsDto.UserReview != null)
            {
                bookingDetailsDto.UserReview.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(
                    bookingDetailsDto.UserReview.CreatedAt);
                if (bookingDetailsDto.UserReview.ResponseDate.HasValue)
                {
                    bookingDetailsDto.UserReview.ResponseDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(
                        bookingDetailsDto.UserReview.ResponseDate.Value);
                }

                for (var i = 0; i < bookingDetailsDto.UserReview.Images.Count; i++)
                {
                    bookingDetailsDto.UserReview.Images[i].UploadedAt =
                        await _currentUserService.ConvertFromUtcToUserLocalAsync(
                            bookingDetailsDto.UserReview.Images[i].UploadedAt);
                }
            }

            // Populate compatibility fields and calculated values expected by the mobile app.
            bookingDetailsDto.CheckInDate = bookingDetailsDto.CheckIn;
            bookingDetailsDto.CheckOutDate = bookingDetailsDto.CheckOut;
            var checkInLocalDate = bookingDetailsDto.CheckIn.Date;
            var checkOutLocalDate = bookingDetailsDto.CheckOut.Date;
            var nights = (checkOutLocalDate - checkInLocalDate).Days;
            bookingDetailsDto.NumberOfNights = nights > 0 ? nights : 1;
            bookingDetailsDto.AdultGuests = booking.GuestsCount;
            bookingDetailsDto.ChildGuests = 0;

            var servicesTotal = serviceDtos.Sum(s => s.TotalPrice);
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

            bookingDetailsDto.TotalPrice = new MoneyDto
            {
                Amount = totalWithServices,
                Currency = booking.TotalPrice.Currency ?? "YER"
            };
            bookingDetailsDto.TotalAmount = baseAmount;

            var user = await _userRepository.GetByIdAsync(booking.UserId, cancellationToken);
            if (user != null)
            {
                bookingDetailsDto.UserName = string.IsNullOrWhiteSpace(user.Name) ? bookingDetailsDto.UserName : user.Name;
                bookingDetailsDto.ContactInfo = new ContactInfoDto
                {
                    PhoneNumber = user.Phone ?? string.Empty,
                    Email = user.Email ?? string.Empty
                };
            }

            return ResultDto<BookingDetailsDto>.Ok(
                bookingDetailsDto,
                "تم الحصول على تفاصيل الحجز بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على تفاصيل الحجز. معرف الحجز: {BookingId}", request.BookingId);
            return ResultDto<BookingDetailsDto>.Failed(
                $"حدث خطأ أثناء الحصول على تفاصيل الحجز: {ex.Message}", 
                "GET_BOOKING_DETAILS_ERROR"
            );
        }
    }

    private ResultDto<BookingDetailsDto> ValidateRequest(GetBookingDetailsQuery request)
    {
        if (request.BookingId == Guid.Empty)
        {
            _logger.LogWarning("معرف الحجز مطلوب");
            return ResultDto<BookingDetailsDto>.Failed("معرف الحجز مطلوب", "BOOKING_ID_REQUIRED");
        }

        if (request.UserId == Guid.Empty && _currentUserService.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم مطلوب");
            return ResultDto<BookingDetailsDto>.Failed("معرف المستخدم مطلوب", "USER_ID_REQUIRED");
        }

        return ResultDto<BookingDetailsDto>.Ok(null, "البيانات صحيحة");
    }

    private sealed class CancellationSnapshotInfo
    {
        /// <summary>
        /// يحدد ما إذا كان Allows Cancellation
        /// Indicates whether allows cancellation.
        /// </summary>
        public bool? AllowsCancellation { get; set; }
        /// <summary>
        /// يحدد ما إذا كان يمكن cellation Window Days
        /// Indicates whether cancellation window days.
        /// </summary>
        public int? CancellationWindowDays { get; set; }
        /// <summary>
        /// يحدد ما إذا كان يمكن cellation Days Before تسجيل الوصول
        /// Indicates whether cancellation days before check in.
        /// </summary>
        public int? CancellationDaysBeforeCheckIn { get; set; }
        /// <summary>
        /// يحدد ما إذا كان يمكن cellation Hours Before تسجيل الوصول
        /// Indicates whether cancellation hours before check in.
        /// </summary>
        public int? CancellationHoursBeforeCheckIn { get; set; }
    }

    private static CancellationSnapshotInfo GetCancellationSnapshotInfo(string? policySnapshot)
    {
        var info = new CancellationSnapshotInfo();
        if (string.IsNullOrWhiteSpace(policySnapshot))
        {
            return info;
        }

        try
        {
            using var doc = JsonDocument.Parse(policySnapshot);
            var root = doc.RootElement;

            if (root.TryGetProperty("UnitOverrides", out var overridesEl) && overridesEl.ValueKind == JsonValueKind.Object)
            {
                if (overridesEl.TryGetProperty("AllowsCancellation", out var allowsEl) &&
                    (allowsEl.ValueKind == JsonValueKind.True || allowsEl.ValueKind == JsonValueKind.False))
                {
                    info.AllowsCancellation = allowsEl.GetBoolean();
                }
                if (overridesEl.TryGetProperty("CancellationWindowDays", out var wndEl) && wndEl.ValueKind == JsonValueKind.Number)
                {
                    info.CancellationWindowDays = wndEl.GetInt32();
                }
            }

            if (root.TryGetProperty("Policies", out var policiesEl) && policiesEl.ValueKind == JsonValueKind.Array)
            {
                foreach (var p in policiesEl.EnumerateArray())
                {
                    var typeStr = p.TryGetProperty("Type", out var tEl) ? tEl.GetString() : null;
                    if (string.IsNullOrWhiteSpace(typeStr) || !typeStr.Equals("Cancellation", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    if (p.TryGetProperty("CancellationWindowDays", out var policyWndEl) && policyWndEl.ValueKind == JsonValueKind.Number)
                    {
                        info.CancellationWindowDays ??= policyWndEl.GetInt32();
                    }

                    if (p.TryGetProperty("Rules", out var rulesEl) && rulesEl.ValueKind == JsonValueKind.String)
                    {
                        PopulateCancellationInfoFromRulesJson(info, rulesEl.GetString());
                    }

                    break;
                }
            }
        }
        catch
        {
            return info;
        }

        return info;
    }

    private static void PopulateCancellationInfoFromRulesJson(CancellationSnapshotInfo info, string? rulesJson)
    {
        if (string.IsNullOrWhiteSpace(rulesJson))
        {
            return;
        }

        try
        {
            using var rulesDoc = JsonDocument.Parse(rulesJson);
            var rules = rulesDoc.RootElement;
            if (rules.ValueKind != JsonValueKind.Object)
            {
                return;
            }

            if (rules.TryGetProperty("daysBeforeCheckIn", out var daysEl) && daysEl.ValueKind == JsonValueKind.Number)
            {
                info.CancellationDaysBeforeCheckIn = daysEl.GetInt32();
            }
            if (rules.TryGetProperty("hoursBeforeCheckIn", out var hoursEl) && hoursEl.ValueKind == JsonValueKind.Number)
            {
                info.CancellationHoursBeforeCheckIn = hoursEl.GetInt32();
            }
        }
        catch
        {
            return;
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
