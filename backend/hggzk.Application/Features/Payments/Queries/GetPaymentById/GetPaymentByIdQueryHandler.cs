using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Helpers;
using YemenBooking.Application.Features.Payments.DTOs;

namespace YemenBooking.Application.Features.Payments.Queries.GetPaymentById
{
    /// <summary>
    /// يعالج مكوّن المدفوعات ويعيد النتيجة المطلوبة.
    /// Handles a payment-related component and returns the requested result.
    /// </summary>
    public class GetPaymentByIdQueryHandler : IRequestHandler<GetPaymentByIdQuery, PaymentDetailsDto>
    {
        private readonly IPaymentRepository _paymentRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetPaymentByIdQueryHandler> _logger;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
        public GetPaymentByIdQueryHandler(
            IPaymentRepository paymentRepository,
            ICurrentUserService currentUserService,
            IMapper _mapper,
            ILogger<GetPaymentByIdQueryHandler> logger)
        {
            _paymentRepository = paymentRepository;
            _currentUserService = currentUserService;
            this._mapper = _mapper;
            _logger = logger;
        }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ المدفوعات ويعيد النتيجة المطلوبة.
/// Handles the corresponding payment-related command or query and returns the requested result.
/// </summary>
        public async Task<PaymentDetailsDto> Handle(GetPaymentByIdQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing GetPaymentByIdQuery for PaymentId: {PaymentId}", request.PaymentId);

            var roles = _currentUserService.UserRoles;
            var isAdmin = roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));
            var currentUserId = _currentUserService.UserId;
            
            if (!isAdmin && !roles.Any())
                throw new UnauthorizedAccessException("ليس لديك صلاحية لعرض تفاصيل الدفعة");

            // Get payment with related data
            var payment = await _paymentRepository.GetQueryable()
                .AsNoTracking()
                .Include(p => p.Booking)
                    .ThenInclude(b => b.Unit)
                        .ThenInclude(u => u.Property)
                .Include(p => p.Booking)
                    .ThenInclude(b => b.User)
                .FirstOrDefaultAsync(p => p.Id == request.PaymentId, cancellationToken);

            if (payment == null)
            {
                _logger.LogWarning("Payment not found: {PaymentId}", request.PaymentId);
                throw new KeyNotFoundException($"الدفعة غير موجودة / Payment not found");
            }

            if (!isAdmin)
            {
                var paymentOwnerId = payment.Booking?.Unit?.Property?.OwnerId;
                if (!paymentOwnerId.HasValue || paymentOwnerId.Value != currentUserId)
                    throw new UnauthorizedAccessException("ليست لديك صلاحية لعرض هذه الدفعة");
            }

            // Map to DTO
            var paymentDto = _mapper.Map<PaymentDto>(payment);

            // Localize output dates
            paymentDto.PaymentDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDto.PaymentDate);
            if (paymentDto.ProcessedAt.HasValue)
                paymentDto.ProcessedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDto.ProcessedAt.Value);
            if (paymentDto.RefundDeadline.HasValue)
                paymentDto.RefundDeadline = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDto.RefundDeadline.Value);
            if (paymentDto.RefundedAt.HasValue)
                paymentDto.RefundedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDto.RefundedAt.Value);
            if (paymentDto.VoidedAt.HasValue)
                paymentDto.VoidedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(paymentDto.VoidedAt.Value);

            // Build Refunds list
            var refunds = new List<RefundDto>();
            // Check if payment has refund status
            if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Refunded || 
                payment.Status == YemenBooking.Core.Enums.PaymentStatus.PartiallyRefunded)
            {
                // For now, return empty list - refunds will be tracked separately in future
                // TODO: Implement separate Refunds table
            }

            // Build Activities list
            var activities = new List<PaymentActivityDto>();
            
            // Created activity
            activities.Add(new PaymentActivityDto
            {
                Id = Guid.NewGuid().ToString(),
                Action = LocalizedText.Choose("تم الإنشاء", "Created", _currentUserService.Language),
                Description = LocalizedText.Choose("تم إنشاء الدفعة", "Payment created", _currentUserService.Language),
                Timestamp = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.PaymentDate),
                UserId = payment.Booking?.UserId.ToString(),
                UserName = payment.Booking?.User?.Name ?? LocalizedText.Choose("ضيف", "Guest", _currentUserService.Language)
            });

            // Processed activity
            if (payment.ProcessedAt.HasValue)
            {
                activities.Add(new PaymentActivityDto
                {
                    Id = Guid.NewGuid().ToString(),
                    Action = LocalizedText.Choose("تمت المعالجة", "Processed", _currentUserService.Language),
                    Description = LocalizedText.Choose("تمت معالجة الدفعة", "Payment processed", _currentUserService.Language),
                    Timestamp = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.ProcessedAt.Value),
                    UserId = payment.ProcessedBy.ToString(),
                    UserName = LocalizedText.Choose("النظام", "System", _currentUserService.Language)
                });
            }

            // Status-based activities
            if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Refunded || 
                payment.Status == YemenBooking.Core.Enums.PaymentStatus.PartiallyRefunded)
            {
                activities.Add(new PaymentActivityDto
                {
                    Id = Guid.NewGuid().ToString(),
                    Action = LocalizedText.Choose("تم الاسترداد", "Refunded", _currentUserService.Language),
                    Description = LocalizedText.Choose(
                        $"تم استرداد المبلغ - {payment.Status}",
                        $"Refund processed - {payment.Status}",
                        _currentUserService.Language),
                    Timestamp = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.UpdatedAt),
                    UserName = LocalizedText.Choose("النظام", "System", _currentUserService.Language)
                });
            }

            if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Voided)
            {
                activities.Add(new PaymentActivityDto
                {
                    Id = Guid.NewGuid().ToString(),
                    Action = LocalizedText.Choose("تم الإبطال", "Voided", _currentUserService.Language),
                    Description = LocalizedText.Choose("تم إلغاء الدفعة", "Payment voided", _currentUserService.Language),
                    Timestamp = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.UpdatedAt),
                    UserName = LocalizedText.Choose("النظام", "System", _currentUserService.Language)
                });
            }

            // Build BookingInfo
            BookingInfoDto? bookingInfo = null;
            if (payment.Booking != null)
            {
                bookingInfo = new BookingInfoDto
                {
                    BookingId = payment.Booking.Id.ToString(),
                    BookingReference = $"BK-{payment.Booking.Id.ToString().Substring(0, 8).ToUpper()}",
                    CheckIn = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.Booking.CheckIn),
                    CheckOut = await _currentUserService.ConvertFromUtcToUserLocalAsync(payment.Booking.CheckOut),
                    UnitName = payment.Booking.Unit?.Name ?? LocalizedText.Choose("غير متوفر", "N/A", _currentUserService.Language),
                    PropertyName = payment.Booking.Unit?.Property?.Name ?? LocalizedText.Choose("غير متوفر", "N/A", _currentUserService.Language),
                    GuestsCount = payment.Booking.GuestsCount
                };
            }

            // Build GatewayInfo
            PaymentGatewayInfoDto? gatewayInfo = null;
            if (!string.IsNullOrEmpty(payment.GatewayTransactionId))
            {
                gatewayInfo = new PaymentGatewayInfoDto
                {
                    GatewayName = payment.PaymentMethod.ToString(),
                    GatewayTransactionId = payment.GatewayTransactionId,
                    AuthorizationCode = payment.GatewayTransactionId,
                    ResponseCode = payment.Status.ToString(),
                    ResponseMessage = LocalizedText.Choose(
                        $"حالة الدفع: {payment.Status}",
                        $"Payment {payment.Status}",
                        _currentUserService.Language)
                };
            }

            return new PaymentDetailsDto
            {
                Payment = paymentDto,
                Refunds = refunds,
                Activities = activities.OrderByDescending(a => a.Timestamp).ToList(),
                BookingInfo = bookingInfo,
                GatewayInfo = gatewayInfo
            };
        }
    }
}
