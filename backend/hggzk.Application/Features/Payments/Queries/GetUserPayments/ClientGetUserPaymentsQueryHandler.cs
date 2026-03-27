using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Payments;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Payments.Queries.GetUserPayments;

    /// <summary>
    /// يعالج مكوّن المدفوعات ويعيد النتيجة المطلوبة.
    /// Handles a payment-related component and returns the requested result.
    /// </summary>
public class ClientGetUserPaymentsQueryHandler : IRequestHandler<ClientGetUserPaymentsQuery, ResultDto<PaginatedResult<ClientPaymentDto>>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<ClientGetUserPaymentsQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public ClientGetUserPaymentsQueryHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IUserRepository userRepository,
        ILogger<ClientGetUserPaymentsQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _userRepository = userRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ المدفوعات ويعيد النتيجة المطلوبة.
/// Handles the corresponding payment-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<PaginatedResult<ClientPaymentDto>>> Handle(ClientGetUserPaymentsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام مدفوعات المستخدم للعميل. معرف المستخدم: {UserId}, الصفحة: {PageNumber}, الحجم: {PageSize}", 
                request.UserId, request.PageNumber, request.PageSize);

            // التحقق من صحة البيانات / Validate input.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // التحقق من وجود المستخدم / Verify the user exists.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // جلب المدفوعات من المستودع مباشرة / Load payments directly from the repository.
            var userPayments = (await _paymentRepository.GetPaymentsByUserAsync(request.UserId, cancellationToken: cancellationToken))
                ?.ToList();
            
            if (userPayments == null || !userPayments.Any())
            {
                _logger.LogInformation("لا توجد مدفوعات للمستخدم: {UserId}", request.UserId);
                
                var emptyResult = new PaginatedResult<ClientPaymentDto>
                {
                    Items = new List<ClientPaymentDto>(),
                    TotalCount = 0,
                    PageNumber = request.PageNumber,
                    PageSize = request.PageSize
                };

                return ResultDto<PaginatedResult<ClientPaymentDto>>.Ok(
                    emptyResult, 
                    "لا توجد مدفوعات لهذا المستخدم"
                );
            }

            // تطبيع تواريخ الفلاتر إلى UTC / Normalize filter dates to UTC.
            if (request.FromDate.HasValue)
                request.FromDate = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.FromDate.Value);
            if (request.ToDate.HasValue)
                request.ToDate = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.ToDate.Value);

            // تطبيق الفلاتر / Apply filters.
            var filteredPayments = ApplyFilters(userPayments, request);

            // ترتيب المدفوعات من الأحدث / Sort newest first.
            var sortedPayments = filteredPayments.OrderByDescending(p => p.CreatedAt).ToList();

            // تحويل إلى DTOs مع جلب البيانات المرتبطة / Map to DTOs with related data.
            var paymentDtos = new List<ClientPaymentDto>();

            foreach (var payment in sortedPayments)
            {
                // جلب الحجز مع الوحدة/العقار عند الحاجة / Load booking with unit/property when needed.
                var booking = payment.Booking;
                if (booking == null || booking.Unit == null)
                {
                    booking = await _bookingRepository.GetBookingWithUnitAsync(payment.BookingId, cancellationToken);
                }
                
                var paymentDto = new ClientPaymentDto
                {
                    Id = payment.Id,
                    BookingId = payment.BookingId,
                    BookingNumber = booking?.Id.ToString().Substring(0, 8) ?? payment.BookingId.ToString().Substring(0, 8),
                    PropertyName = booking?.Unit?.Property?.Name ?? "غير متاح",
                    UnitName = booking?.Unit?.Name ?? "غير متاح",
                    Amount = payment.Amount?.Amount ?? 0m,
                    Currency = payment.Amount?.Currency ?? "YER",
                    PaymentMethod = payment.PaymentMethod.ToString(),
                    Status = payment.Status.ToString(),
                    CreatedAt = payment.CreatedAt,
                    ProcessedAt = payment.ProcessedAt,
                    // ExternalReference = payment.ExternalReference, // غير متوفر / Not available.
                    // InvoiceNumber = payment.InvoiceNumber, // غير متوفر / Not available.
                    // Notes = payment.Notes, // غير متوفر / Not available.
                    // FailureReason = payment.FailureReason, // غير متوفر / Not available.
                    Fees = 0,
                    Taxes = 0,
                    NetAmount = payment.Amount?.Amount ?? 0m,
                    CanRefund = CanPaymentBeRefunded(payment),
                    RefundExpiryDate = CalculateRefundExpiryDate(payment)
                };

                paymentDtos.Add(paymentDto);
            }

            // تطبيق التصفح / Apply pagination.
            var totalCount = paymentDtos.Count;
            var totalPages = (int)Math.Ceiling((double)totalCount / request.PageSize);
            
            // تحويل الحقول الزمنية لتوقيت المستخدم / Localize date-time fields.
            for (int i = 0; i < paymentDtos.Count; i++)
            {
                paymentDtos[i].CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDtos[i].CreatedAt);
                if (paymentDtos[i].ProcessedAt.HasValue)
                    paymentDtos[i].ProcessedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDtos[i].ProcessedAt.Value);
                if (paymentDtos[i].RefundExpiryDate.HasValue)
                    paymentDtos[i].RefundExpiryDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDtos[i].RefundExpiryDate.Value);
            }

            var pagedPayments = paymentDtos
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToList();

            var paginatedResult = new PaginatedResult<ClientPaymentDto>
            {
                Items = pagedPayments,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
                // TotalPages محسوبة تلقائياً في PaginatedResult / TotalPages is computed by PaginatedResult.
            };

            _logger.LogInformation("تم العثور على {TotalCount} مدفوعة للمستخدم {UserId}, عرض الصفحة {PageNumber} من {TotalPages}", 
                totalCount, request.UserId, request.PageNumber, totalPages);

            return ResultDto<PaginatedResult<ClientPaymentDto>>.Ok(
                paginatedResult, 
                $"تم العثور على {totalCount} مدفوعة"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على مدفوعات المستخدم للعميل. معرف المستخدم: {UserId}", request.UserId);
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed(
                $"حدث خطأ أثناء الحصول على المدفوعات: {ex.Message}", 
                "GET_USER_PAYMENTS_ERROR"
            );
        }
    }

    private ResultDto<PaginatedResult<ClientPaymentDto>> ValidateRequest(ClientGetUserPaymentsQuery request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم مطلوب");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("معرف المستخدم مطلوب", "USER_ID_REQUIRED");
        }

        if (request.PageNumber < 1)
        {
            _logger.LogWarning("رقم الصفحة يجب أن يكون أكبر من صفر");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("رقم الصفحة يجب أن يكون أكبر من صفر", "INVALID_PAGE_NUMBER");
        }

        if (request.PageSize < 1 || request.PageSize > 100)
        {
            _logger.LogWarning("حجم الصفحة يجب أن يكون بين 1 و 100");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("حجم الصفحة يجب أن يكون بين 1 و 100", "INVALID_PAGE_SIZE");
        }

        if (request.FromDate.HasValue && request.ToDate.HasValue && request.FromDate > request.ToDate)
        {
            _logger.LogWarning("تاريخ البداية يجب أن يكون قبل تاريخ النهاية");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("تاريخ البداية يجب أن يكون قبل تاريخ النهاية", "INVALID_DATE_RANGE");
        }

        if (request.MinAmount.HasValue && request.MinAmount.Value < 0)
        {
            _logger.LogWarning("الحد الأدنى للمبلغ لا يمكن أن يكون سالباً");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("الحد الأدنى للمبلغ لا يمكن أن يكون سالباً", "INVALID_MIN_AMOUNT");
        }

        if (request.MaxAmount.HasValue && request.MaxAmount.Value < 0)
        {
            _logger.LogWarning("الحد الأقصى للمبلغ لا يمكن أن يكون سالباً");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("الحد الأقصى للمبلغ لا يمكن أن يكون سالباً", "INVALID_MAX_AMOUNT");
        }

        if (request.MinAmount.HasValue && request.MaxAmount.HasValue && request.MinAmount > request.MaxAmount)
        {
            _logger.LogWarning("الحد الأدنى للمبلغ يجب أن يكون أقل من الحد الأقصى");
            return ResultDto<PaginatedResult<ClientPaymentDto>>.Failed("الحد الأدنى للمبلغ يجب أن يكون أقل من الحد الأقصى", "INVALID_AMOUNT_RANGE");
        }

        return ResultDto<PaginatedResult<ClientPaymentDto>>.Ok(null, "البيانات صحيحة");
    }

    private IEnumerable<Core.Entities.Payment> ApplyFilters(IEnumerable<Core.Entities.Payment> payments, ClientGetUserPaymentsQuery request)
    {
        var filteredPayments = payments.AsEnumerable();

        // فلتر حسب الحالة / Filter by status.
        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            filteredPayments = filteredPayments.Where(p => 
                string.Equals(p.Status.ToString(), request.Status, StringComparison.OrdinalIgnoreCase));
        }

        // فلتر حسب طريقة الدفع / Filter by payment method.
        if (!string.IsNullOrWhiteSpace(request.PaymentMethod))
        {
            filteredPayments = filteredPayments.Where(p => 
                string.Equals(p.PaymentMethod.ToString(), request.PaymentMethod, StringComparison.OrdinalIgnoreCase));
        }

        // فلتر حسب التاريخ / Filter by date.
        if (request.FromDate.HasValue)
        {
            filteredPayments = filteredPayments.Where(p => p.CreatedAt.Date >= request.FromDate.Value.Date);
        }

        if (request.ToDate.HasValue)
        {
            filteredPayments = filteredPayments.Where(p => p.CreatedAt.Date <= request.ToDate.Value.Date);
        }

        // فلتر حسب المبلغ / Filter by amount.
        if (request.MinAmount.HasValue)
        {
            filteredPayments = filteredPayments.Where(p => (p.Amount?.Amount ?? 0m) >= request.MinAmount.Value);
        }

        if (request.MaxAmount.HasValue)
        {
            filteredPayments = filteredPayments.Where(p => (p.Amount?.Amount ?? 0m) <= request.MaxAmount.Value);
        }

        return filteredPayments;
    }

    private string GetPaymentMethodDisplayName(string? paymentMethod)
    {
        return paymentMethod?.ToLowerInvariant() switch
        {
            "credit_card" => "بطاقة ائتمانية",
            "debit_card" => "بطاقة خصم",
            "bank_transfer" => "تحويل بنكي",
            "cash_on_delivery" => "الدفع عند الاستلام",
            "mobile_wallet" => "محفظة موبايل",
            "digital_wallet" => "محفظة رقمية",
            "paypal" => "باي بال",
            _ => paymentMethod ?? "غير محدد"
        };
    }

    private string GetPaymentStatusDisplayName(string? status)
    {
        return status?.ToLowerInvariant() switch
        {
            "pending" => "قيد الانتظار",
            "processing" => "قيد المعالجة",
            "completed" => "مكتمل",
            "failed" => "فاشل",
            "cancelled" => "ملغي",
            "refunded" => "مسترد",
            "partially_refunded" => "مسترد جزئياً",
            _ => status ?? "غير محدد"
        };
    }

    private bool CanPaymentBeRefunded(Core.Entities.Payment payment)
    {
        // المدفوعات الفاشلة أو الملغاة أو المستردة غير قابلة للاسترداد / Failed, cancelled, or refunded payments are not refundable.
        if (payment.Status.ToString().ToLowerInvariant() is "failed" or "cancelled" or "refunded")
        {
            return false;
        }

        // يجب أن تكون الحالة مكتملة / Status must be completed.
        if (payment.Status.ToString().ToLowerInvariant() != "completed")
        {
            return false;
        }

        // التحقق من انتهاء فترة الاسترداد (30 يوم) / Check the 30-day refund window.
        var refundExpiryDate = payment.ProcessedAt?.AddDays(30) ?? payment.CreatedAt.AddDays(30);
        if (DateTime.UtcNow > refundExpiryDate)
        {
            return false;
        }

        return true;
    }

    private DateTime? CalculateRefundExpiryDate(Core.Entities.Payment payment)
    {
        if (!CanPaymentBeRefunded(payment))
        {
            return null;
        }

        // 30 يوم من تاريخ المعالجة أو الإنشاء / 30 days from processing or creation.
        return payment.ProcessedAt?.AddDays(30) ?? payment.CreatedAt.AddDays(30);
    }
}
