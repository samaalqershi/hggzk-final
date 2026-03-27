using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features;
using YemenBooking.Application.Features.Bookings.DTOs;
using System.Text.Json;

namespace YemenBooking.Application.Features.Bookings.Queries.GetUserBookings;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class GetUserBookingsQueryHandler : IRequestHandler<GetUserBookingsQuery, ResultDto<PaginatedResult<BookingDto>>>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<GetUserBookingsQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public GetUserBookingsQueryHandler(
        IBookingRepository bookingRepository,
        IReviewRepository reviewRepository,
        IPropertyRepository propertyRepository,
        IUnitRepository unitRepository,
        IUserRepository userRepository,
        ILogger<GetUserBookingsQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _bookingRepository = bookingRepository;
        _reviewRepository = reviewRepository;
        _propertyRepository = propertyRepository;
        _unitRepository = unitRepository;
        _userRepository = userRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<PaginatedResult<BookingDto>>> Handle(GetUserBookingsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام حجوزات المستخدم. معرف المستخدم: {UserId}, الحالة: {Status}, الصفحة: {PageNumber}", 
                request.UserId, request.Status?.ToString() ?? "جميع الحالات", request.PageNumber);

            // التحقق من صحة البيانات المدخلة / Validate input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return ResultDto<PaginatedResult<BookingDto>>.Failed(validationResult.Message ?? "", validationResult.ErrorCode);
            }

            // التحقق من وجود المستخدم / Validate that the user exists.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<PaginatedResult<BookingDto>>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // بناء الاستعلام على مستوى قاعدة البيانات لتجنب التوازي على نفس DbContext / Build the query at the database level to avoid parallel access to the same DbContext.
            var pageNumber = request.PageNumber < 1 ? 1 : request.PageNumber;
            var pageSize = request.PageSize < 1 ? 10 : request.PageSize;

            var query = _bookingRepository.GetQueryable()
                .AsNoTracking()
                .AsSplitQuery()
                .Include(b => b.Payments)
                .Where(b => b.UserId == request.UserId);

            // Aggregate counts by status for this user, independent from the current status filter.
            var statusCountsList = await _bookingRepository.GetQueryable()
                .AsNoTracking()
                .Where(b => b.UserId == request.UserId)
                .GroupBy(b => b.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync(cancellationToken);

            var statusCounts = statusCountsList
                .GroupBy(x => x.Status)
                .ToDictionary(
                    g => g.Key.ToString().ToLowerInvariant(),
                    g => g.First().Count
                );
            
            if (request.Status.HasValue)
            {
                query = query.Where(b => b.Status == request.Status.Value);
            }
            
            var totalCount = await query.CountAsync(cancellationToken);

            var pageItems = await query
                .Include(b => b.Unit)
                    .ThenInclude(u => u.Property)
                        .ThenInclude(p => p.Images)
                .Include(b => b.Unit)
                    .ThenInclude(u => u.Property)
                        .ThenInclude(p => p.Policies)
                .OrderByDescending(b => b.BookedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            if (pageItems.Count == 0)
            {
                _logger.LogInformation("لم يتم العثور على حجوزات للمستخدم: {UserId}", request.UserId);
                return ResultDto<PaginatedResult<BookingDto>>.Ok(
                    new PaginatedResult<BookingDto>
                    {
                        Items = new List<BookingDto>(),
                        TotalCount = 0,
                        PageNumber = pageNumber,
                        PageSize = pageSize,
                        Metadata = new Dictionary<string, object?>
                        {
                            ["statusCounts"] = statusCounts
                        }
                    }, 
                    "لا توجد حجوزات متاحة"
                );
            }

            // Determine which bookings already have a review to hide the review button.
            // This avoids loading all reviews and avoids parallel DbContext usage.
            var pageBookingIds = pageItems.Select(b => b.Id).ToList();
            var reviewedBookingIds = new HashSet<Guid>();
            if (pageBookingIds.Count > 0)
            {
                var existingReviews = await _reviewRepository
                    .GetQueryable()
                    .AsNoTracking()
                    .Where(r => pageBookingIds.Contains(r.BookingId))
                    .Select(r => r.BookingId)
                    .ToListAsync(cancellationToken);

                reviewedBookingIds = existingReviews.ToHashSet();
            }

            // تحويل إلى DTO بدون تشغيل عمليات قاعدة بيانات متوازية / Map to DTOs without running parallel database operations.
            var bookingDtos = pageItems.Select(booking =>
            {
                var unit = booking.Unit;
                var property = unit?.Property;
                var propertyImageUrl = property?.Images?.FirstOrDefault()?.Url ?? string.Empty;

                var hasReview = reviewedBookingIds.Contains(booking.Id);

                var totalPaid = booking.Payments?
                    .Where(p => p.Status == PaymentStatus.Successful)
                    .Sum(p => p.Amount.Amount) ?? 0m;
                var isPaid = totalPaid >= booking.TotalPrice.Amount;

                return new BookingDto
                {
                    Id = booking.Id,
                    UserId = booking.UserId,
                    PropertyId = property?.Id ?? Guid.Empty,
                    UnitId = booking.UnitId,
                    BookingNumber = $"BK-{booking.Id.ToString().Substring(0, 8)}",
                    UserName = user.Name ?? string.Empty,
                    PropertyName = property?.Name ?? "غير متاح",
                    UnitName = unit?.Name ?? "غير متاح",
                    CheckIn = booking.CheckIn,
                    CheckOut = booking.CheckOut,
                    GuestsCount = booking.GuestsCount,
                    TotalPrice = booking.TotalPrice,
                    Currency = booking.TotalPrice.Currency ?? "YER",
                    Status = booking.Status,
                    BookedAt = booking.BookedAt,
                    PropertyImageUrl = propertyImageUrl,
                    CanCancel = false,
                    CanReview = CanReviewBooking(booking) && !hasReview,
                    CanModify = CanModifyBooking(booking, property),
                    IsPaid = isPaid
                };
            })
                .ToList();

            // Convert all datetime fields from UTC to the user's local time.
            for (int i = 0; i < bookingDtos.Count; i++)
            {
                bookingDtos[i].BookedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDtos[i].BookedAt);
                bookingDtos[i].CheckIn = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDtos[i].CheckIn);
                bookingDtos[i].CheckOut = await _currentUserService.ConvertFromUtcToUserLocalAsync(bookingDtos[i].CheckOut);

                // Compute CanCancel using the booking snapshot captured at booking time.
                bookingDtos[i].CanCancel = await CanCancelBookingAsync(pageItems[i], cancellationToken);
            }

            // حساب إجمالي عدد الصفحات / Compute the total number of pages.
            var totalPages = (int)Math.Ceiling((double)totalCount / request.PageSize);

            var response = new PaginatedResult<BookingDto>
            {
                Items = bookingDtos,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize,
                Metadata = new Dictionary<string, object?>
                {
                    ["statusCounts"] = statusCounts
                }
            };

            _logger.LogInformation("تم الحصول على {Count} حجز للمستخدم {UserId} بنجاح", bookingDtos.Count, request.UserId);

            return ResultDto<PaginatedResult<BookingDto>>.Ok(
                response,
                $"تم الحصول على {bookingDtos.Count} حجز من أصل {totalCount}"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على حجوزات المستخدم. معرف المستخدم: {UserId}", request.UserId);
            return ResultDto<PaginatedResult<BookingDto>>.Failed(
                $"حدث خطأ أثناء الحصول على الحجوزات: {ex.Message}", 
                "GET_USER_BOOKINGS_ERROR"
            );
        }
    }

    private ResultDto<PaginatedResult<BookingDto>> ValidateRequest(GetUserBookingsQuery request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم مطلوب");
            return ResultDto<PaginatedResult<BookingDto>>.Failed("معرف المستخدم مطلوب", "USER_ID_REQUIRED");
        }

        if (request.PageNumber < 1)
        {
            _logger.LogWarning("رقم الصفحة يجب أن يكون أكبر من صفر");
            return ResultDto<PaginatedResult<BookingDto>>.Failed("رقم الصفحة يجب أن يكون أكبر من صفر", "INVALID_PAGE_NUMBER");
        }

        if (request.PageSize < 1 || request.PageSize > 100)
        {
            _logger.LogWarning("حجم الصفحة يجب أن يكون بين 1 و 100");
            return ResultDto<PaginatedResult<BookingDto>>.Failed("حجم الصفحة يجب أن يكون بين 1 و 100", "INVALID_PAGE_SIZE");
        }

        return ResultDto<PaginatedResult<BookingDto>>.Ok(null, "البيانات صحيحة");
    }

    private async Task<bool> CanCancelBookingAsync(Core.Entities.Booking booking, CancellationToken cancellationToken)
    {
        // لا يمكن إلغاء الحجوزات النهائية / Final bookings cannot be cancelled.
        if (booking.Status == BookingStatus.Cancelled ||
            booking.Status == BookingStatus.Completed ||
            booking.Status == BookingStatus.CheckedIn)
        {
            return false;
        }

        if (booking.Status == BookingStatus.Pending)
        {
            return true;
        }

        // سياسة نافذة الإلغاء تنطبق على الحجوزات المؤكدة / The cancellation window policy applies to confirmed bookings.
        if (booking.Status != BookingStatus.Confirmed)
        {
            return true;
        }

        var unit = booking.Unit;
        if (unit == null)
        {
            return false;
        }

        var hasPolicySnapshot = !string.IsNullOrWhiteSpace(booking.PolicySnapshot);
        var snapshotInfo = GetCancellationSnapshotInfo(booking.PolicySnapshot);

        var allowsCancellation = hasPolicySnapshot
            ? (snapshotInfo.AllowsCancellation ?? true)
            : (snapshotInfo.AllowsCancellation ?? unit.AllowsCancellation);
        if (!allowsCancellation)
        {
            return false;
        }

        int? windowDays = hasPolicySnapshot
            ? snapshotInfo.CancellationWindowDays
            : (snapshotInfo.CancellationWindowDays ?? unit.CancellationWindowDays);

        if (!hasPolicySnapshot && !windowDays.HasValue)
        {
            var property = unit.Property;
            var cancellationPolicy = property?.Policies?.FirstOrDefault(p => p.Type == PolicyType.Cancellation);
            windowDays = cancellationPolicy?.CancellationWindowDays;
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
        var checkInLocalDate = checkInLocal.Date;
        var daysBeforeCheckIn = (checkInLocalDate - userToday).TotalDays;

        if (daysBeforeCheckIn < 0)
        {
            return false;
        }

        if (snapshotInfo.CancellationHoursBeforeCheckIn.HasValue)
        {
            var hoursBeforeCheckIn = (checkInLocal - userNow).TotalHours;
            if (hoursBeforeCheckIn < snapshotInfo.CancellationHoursBeforeCheckIn.Value)
            {
                return false;
            }
        }

        if (windowDays.HasValue && daysBeforeCheckIn < windowDays.Value)
        {
            return false;
        }

        return true;
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

    private bool CanReviewBooking(Core.Entities.Booking booking)
    {
        // إظهار زر التقييم لكل حجز مكتمل. / Show the review button for every completed booking.
        // منع التكرار يتم عبر hasReview في الاستعلام الرئيسي. / Duplicate reviews are prevented by hasReview in the main query.
        return booking.Status == BookingStatus.Completed;
    }

    private bool CanModifyBooking(Core.Entities.Booking booking, Core.Entities.Property? property)
    {
        // يمكن تعديل الحجز فقط إذا كان في حالة انتظار أو تأكيد ولم يبدأ بعد / A booking can only be modified while pending or confirmed and before it starts.
        if (booking.Status != BookingStatus.Pending && booking.Status != BookingStatus.Confirmed)
        {
            return false;
        }

        if (booking.CheckIn <= DateTime.UtcNow)
        {
            return false;
        }

        // في حال وجود سياسة تعديل للعقار، احترم الحد الأدنى للساعات قبل الوصول / If a property modification policy exists, respect the minimum hours before arrival.
        var modificationPolicy = property?.Policies?.FirstOrDefault(p => p.Type == PolicyType.Modification);
        if (modificationPolicy != null)
        {
            var timeToCheckIn = booking.CheckIn - DateTime.UtcNow;
            if (timeToCheckIn.TotalHours < modificationPolicy.MinHoursBeforeCheckIn)
            {
                return false;
            }
        }

        return true;
    }
}
