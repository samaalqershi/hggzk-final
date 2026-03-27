using MediatR;
using System;
using System.Threading;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Analytics.Commands.Reviews
{
    /// <summary>
    /// معالج أمر الموافقة على مراجعة / Review approval command handler.
    /// Includes:
    /// - التحقق من الوجود / Existence validation
    /// - التحقق من صلاحيات المسؤول / Admin authorization validation
    /// - التحقق من حالة الموافقة / Approval state validation
    /// - تحديث حالة المراجعة / Review state update
    /// - تسجيل التدقيق / Audit logging
    /// - نشر الحدث / Event publishing
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

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
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

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the review approval command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(ApproveReviewCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء الموافقة على المراجعة {ReviewId}", request.ReviewId);

            // التحقق من وجود المراجعة / Validate that the review exists.
            var review = await _reviewRepository.GetReviewByIdAsync(request.ReviewId, cancellationToken);
            if (review == null || review.IsDeleted)
                throw new NotFoundException("Review", request.ReviewId.ToString());

            // التحقق من صلاحية المسؤول / Validate admin or owner permission.
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            var isOwner = string.Equals(_currentUserService.Role, "Owner", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Owner", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Owner", StringComparison.OrdinalIgnoreCase)) ?? false);

            if (_currentUserService.UserId != request.AdminId)
                throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

            if (!isAdmin && !isOwner)
                throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

            if (!isAdmin && isOwner)
            {
                if (review.PropertyId == Guid.Empty)
                    throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");

                var property = await _propertyRepository.GetPropertyByIdAsync(review.PropertyId, cancellationToken);
                if (property == null || property.OwnerId != _currentUserService.UserId)
                    throw new ForbiddenException("غير مصرح لك بالموافقة على المراجعة");
            }

            // التحقق من وضعية الموافقة / Validate that the review is still pending approval.
            if (!review.IsPendingApproval)
                throw new BusinessRuleException("AlreadyApproved", "المراجعة تمت الموافقة عليها مسبقاً");

            // تنفيذ العملية ضمن معاملة / Apply the state change inside a transaction.
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                review.IsPendingApproval = false;
                review.UpdatedBy = _currentUserService.UserId;
                review.UpdatedAt = DateTime.UtcNow;
                await _reviewRepository.UpdateReviewAsync(review, cancellationToken);
                await _reviewRepository.SaveChangesAsync(cancellationToken);

                // تسجيل التدقيق اليدوي مع ذكر اسم المستخدم والمعرف في الملاحظات / Record a manual audit note with the username and identifier.
                var notes = $"تمت الموافقة على المراجعة {review.Id} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
                await _auditService.LogAuditAsync(
                    entityType: "Review",
                    entityId: review.Id,
                    action: AuditAction.APPROVE,
                    oldValues: null,
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { Approved = true }),
                    performedBy: _currentUserService.UserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                _logger.LogInformation("تمت الموافقة على المراجعة بنجاح: {ReviewId}", review.Id);
            });

            // نشر الحدث بعد اكتمال المعاملة حتى لا تؤثر أعطال البنية التحتية على نتيجة الموافقة / Publish the event after the transaction completes so infrastructure failures do not roll back the approval.
            var eventPublished = await _eventPublisher.PublishEventAsync(new ReviewApprovedEvent
            {
                ReviewId = review.Id,
                ApprovedBy = _currentUserService.UserId,
                ApprovedAt = DateTime.UtcNow
            }, cancellationToken);

            if (!eventPublished)
            {
                _logger.LogWarning("تعذر نشر حدث الموافقة على المراجعة {ReviewId}", review.Id);
            }

            return ResultDto<bool>.Ok(true, "تمت الموافقة على المراجعة بنجاح", "Review approved successfully");
        }
    }

    /// <summary>
    /// حدث الموافقة على مراجعة / Review approved event.
    /// </summary>
    public class ReviewApprovedEvent
    {
        /// <summary>
        /// معرّف التقييم الذي سيتم اعتماده.
        /// Identifier of the review being approved.
        /// </summary>
        public Guid ReviewId { get; set; }
        /// <summary>
        /// معرّف المستخدم الذي اعتمد التقييم.
        /// Identifier of the user who approved the review.
        /// </summary>
        public Guid ApprovedBy { get; set; }
        /// <summary>
        /// وقت اعتماد التقييم.
        /// Timestamp when the review was approved.
        /// </summary>
        public DateTime ApprovedAt { get; set; }
    }
} 
