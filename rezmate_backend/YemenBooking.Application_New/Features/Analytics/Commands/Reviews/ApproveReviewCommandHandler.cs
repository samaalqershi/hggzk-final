using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Analytics.Commands.Reviews
{
    /// <summary>
    /// معالج أمر الموافقة على مراجعة
    /// Approves a pending review and includes:
    /// - التحقق من الوجود
    /// - التحقق من صلاحيات المسؤول
    /// - التحقق من حالة الموافقة
    /// - تحديث حالة المراجعة
    /// - تسجيل التدقيق
    /// - نشر الحدث
    /// </summary>
    public class ApproveReviewCommandHandler : IRequestHandler<ApproveReviewCommand,ResultDto<bool>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly IEventPublisher _eventPublisher;
        private readonly ILogger<ApproveReviewCommandHandler> _logger;

        public ApproveReviewCommandHandler(
            IReviewRepository reviewRepository,
            IPropertyRepository propertyRepository,
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            IEventPublisher eventPublisher,
            ILogger<ApproveReviewCommandHandler> logger)
        {
            _reviewRepository = reviewRepository;
            _propertyRepository = propertyRepository;
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _eventPublisher = eventPublisher;
            _logger = logger;
        }

        public async Task<ResultDto<bool>> Handle(ApproveReviewCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء الموافقة على المراجعة {ReviewId}", request.ReviewId);

            // التحقق من وجود المراجعة
            var review = await _reviewRepository.GetReviewByIdAsync(request.ReviewId, cancellationToken);
            if (review == null || review.IsDeleted)
                throw new NotFoundException("Review", request.ReviewId.ToString());

            var currentUserId = _currentUserService.UserId;
            if (currentUserId == Guid.Empty)
                throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

            if (request.AdminId != Guid.Empty && request.AdminId != currentUserId)
            {
                _logger.LogWarning(
                    "تم تجاهل AdminId المرسل من العميل عند الموافقة على المراجعة {ReviewId}. RequestAdminId={RequestAdminId}, CurrentUserId={CurrentUserId}",
                    request.ReviewId,
                    request.AdminId,
                    currentUserId);
            }

            // التحقق من صلاحية المسؤول أو المالك
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            var isOwner = string.Equals(_currentUserService.Role, "Owner", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Owner", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Owner", StringComparison.OrdinalIgnoreCase)) ?? false);

            if (!isAdmin && !isOwner)
                throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

            var reviewPropertyId = review.PropertyId;
            if (reviewPropertyId == Guid.Empty)
            {
                reviewPropertyId = await _reviewRepository
                    .GetQueryable()
                    .AsNoTracking()
                    .Where(r => r.Id == request.ReviewId)
                    .Select(r => (Guid?)r.Booking!.Unit!.PropertyId)
                    .FirstOrDefaultAsync(cancellationToken) ?? Guid.Empty;
            }

            if (!isAdmin && isOwner)
            {
                if (reviewPropertyId == Guid.Empty)
                    throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

                var scopedPropertyId = _currentUserService.PropertyId;
                var hasScopedPropertyAccess = scopedPropertyId.HasValue &&
                    scopedPropertyId.Value != Guid.Empty &&
                    scopedPropertyId.Value == reviewPropertyId;

                if (!hasScopedPropertyAccess)
                {
                    var property = await _propertyRepository.GetPropertyByIdAsync(reviewPropertyId, cancellationToken);
                    if (property == null || property.OwnerId != currentUserId)
                        throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");
                }
            }

            if (!review.IsPendingApproval)
            {
                _logger.LogInformation("المراجعة {ReviewId} تمت الموافقة عليها مسبقاً", review.Id);
                return ResultDto<bool>.Ok(true, "المراجعة تمت الموافقة عليها مسبقاً");
            }

            // تنفيذ العملية ضمن معاملة
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                review.IsPendingApproval = false;
                review.UpdatedBy = currentUserId;
                review.UpdatedAt = DateTime.UtcNow;
                await _reviewRepository.UpdateReviewAsync(review, cancellationToken);

                // تسجيل التدقيق اليدوي مع ذكر اسم المستخدم والمعرف في الملاحظات
                var notes = $"تمت الموافقة على المراجعة {review.Id} بواسطة {_currentUserService.Username} (ID={currentUserId})";
                await _auditService.LogAuditAsync(
                    entityType: "Review",
                    entityId: review.Id,
                    action: AuditAction.APPROVE,
                    oldValues: null,
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { Approved = true }),
                    performedBy: currentUserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                // نشر الحدث
                // await _eventPublisher.PublishEventAsync(new ReviewApprovedEvent
                // {
                //     ReviewId = review.Id,
                //     ApprovedBy = currentUserId,
                //     ApprovedAt = DateTime.UtcNow
                // }, cancellationToken);

                _logger.LogInformation("تمت الموافقة على المراجعة بنجاح: {ReviewId}", review.Id);
            });

            return ResultDto<bool>.Ok(true,"");
        }
    }

    /// <summary>
    /// حدث الموافقة على مراجعة
    /// Review approved event
    /// </summary>
    public class ReviewApprovedEvent
    {
        public Guid ReviewId { get; set; }
        public Guid ApprovedBy { get; set; }
        public DateTime ApprovedAt { get; set; }
    }
} 
