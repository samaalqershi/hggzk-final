using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Contracts.Services.Storage;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Interfaces;
namespace YemenBooking.Application.Features.Reviews.Commands.SubmitReview;

/// <summary>
/// Handles submission of a new review.
/// يعالج إرسال مراجعة جديدة.
/// </summary>
public class SubmitReviewCommandHandler : IRequestHandler<SubmitReviewCommand, ResultDto<SubmitReviewResponse>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly IReviewImageRepository _reviewImageRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IFileUploadService _fileUploadService;
    private readonly IFileStorageService _fileStorageService;
    private readonly INotificationService _notificationService;
    private readonly ILogger<SubmitReviewCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitOfWork _unitOfWork;

    /// <summary>
    /// Initializes a new instance of the submit review command handler.
    /// يهيئ نسخة جديدة من معالج أمر إرسال المراجعة.
    /// </summary>
    /// <param name="reviewRepository">Reviews repository. مستودع المراجعات.</param>
    /// <param name="reviewImageRepository">Review images repository. مستودع صور المراجعات.</param>
    /// <param name="bookingRepository">Bookings repository. مستودع الحجوزات.</param>
    /// <param name="propertyRepository">Properties repository. مستودع العقارات.</param>
    /// <param name="fileUploadService">File upload service. خدمة رفع الملفات.</param>
    /// <param name="notificationService">Notification service. خدمة التنبيهات.</param>
    /// <param name="logger">Logger. مسجل الأحداث.</param>
    /// <param name="auditService">Audit service. خدمة التدقيق.</param>
    /// <param name="currentUserService">Current user context service. خدمة سياق المستخدم الحالي.</param>
    public SubmitReviewCommandHandler(
        IReviewRepository reviewRepository,
        IReviewImageRepository reviewImageRepository,
        IBookingRepository bookingRepository,
        IPropertyRepository propertyRepository,
        IFileUploadService fileUploadService,
        IFileStorageService fileStorageService,
        INotificationService notificationService,
        ILogger<SubmitReviewCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService,
        IUnitOfWork unitOfWork)
    {
        _reviewRepository = reviewRepository;
        _reviewImageRepository = reviewImageRepository;
        _bookingRepository = bookingRepository;
        _propertyRepository = propertyRepository;
        _fileUploadService = fileUploadService;
        _fileStorageService = fileStorageService;
        _notificationService = notificationService;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the submit review command and returns the result.
    /// </summary>
    public async Task<ResultDto<SubmitReviewResponse>> Handle(SubmitReviewCommand request, CancellationToken cancellationToken)
    {
        var uploadedImages = new List<UploadedReviewImage>();
        try
        {
            _logger.LogInformation("بدء عملية إرسال مراجعة للحجز: {BookingId} والعقار: {PropertyId}", 
                request.BookingId, request.PropertyId);

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // البحث عن الحجز والتحقق من صحته
            var booking = await _bookingRepository.GetBookingWithUnitAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                _logger.LogWarning("لم يتم العثور على الحجز: {BookingId}", request.BookingId);
                return ResultDto<SubmitReviewResponse>.Failed("الحجز غير موجود", "BOOKING_NOT_FOUND");
            }

            // التحقق من أن الحجز مكتمل
            if (booking.Status != BookingStatus.Completed)
            {
                _logger.LogWarning("محاولة مراجعة حجز غير مكتمل: {BookingId}, Status: {Status}", 
                    request.BookingId, booking.Status);
                return ResultDto<SubmitReviewResponse>.Failed("يمكن مراجعة الحجوزات المكتملة فقط", "BOOKING_NOT_COMPLETED");
            }

            // التحقق من أن صاحب التقييم هو مالك الحجز
            if (_currentUserService.UserId == Guid.Empty || booking.UserId != _currentUserService.UserId)
            {
                _logger.LogWarning("محاولة غير مصرح بها لإرسال مراجعة. المستخدم الحالي: {UserId} لا يملك الحجز: {BookingId}",
                    _currentUserService.UserId, request.BookingId);
                return ResultDto<SubmitReviewResponse>.Failed("غير مصرح لك بإرسال مراجعة لهذا الحجز", "UNAUTHORIZED_REVIEWER");
            }

            // التحقق من تطابق العقار مع الحجز (من خلال الوحدة)
            if (booking.Unit?.PropertyId != request.PropertyId)
            {
                _logger.LogWarning("عدم تطابق العقار مع الحجز. BookingPropertyId: {BookingPropertyId}, RequestPropertyId: {RequestPropertyId}", 
                    booking.Unit?.PropertyId, request.PropertyId);
                return ResultDto<SubmitReviewResponse>.Failed("العقار غير متطابق مع الحجز", "PROPERTY_MISMATCH");
            }

            // التحقق من عدم وجود مراجعة مسبقة للحجز
            var existingReview = await _reviewRepository.GetReviewByBookingAsync(request.BookingId, cancellationToken);
            if (existingReview != null)
            {
                _logger.LogWarning("يوجد مراجعة مسبقة للحجز: {BookingId}", request.BookingId);
                return ResultDto<SubmitReviewResponse>.Failed("تم إرسال مراجعة لهذا الحجز مسبقاً", "REVIEW_ALREADY_EXISTS");
            }

            // التحقق من وجود العقار
            var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار: {PropertyId}", request.PropertyId);
                return ResultDto<SubmitReviewResponse>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // رفع الصور المرفقة
            uploadedImages = await UploadReviewImages(request.ImagesBase64 ?? new List<string>(), request.BookingId, cancellationToken);
            var uploadedVideo = await UploadReviewVideoAsync(
                request.VideoBase64,
                request.VideoThumbnailBase64,
                request.BookingId,
                cancellationToken);
            if (uploadedVideo != null)
            {
                uploadedImages.Add(uploadedVideo);
            }

            // حساب التقييم الإجمالي
            var overallRating = (request.Cleanliness + request.Service + request.Location + request.Value) / 4.0m;

            // إنشاء المراجعة
            var review = new YemenBooking.Core.Entities.Review
            {
                Id = Guid.NewGuid(),
                BookingId = request.BookingId,
                PropertyId = request.PropertyId,
                Cleanliness = request.Cleanliness,
                Service = request.Service,
                Location = request.Location,
                Value = request.Value,
                AverageRating = overallRating,
                Comment = request.Comment.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsPendingApproval = true // تحتاج موافقة الإدارة
            };

            YemenBooking.Core.Entities.Review? createResult = null;
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // حفظ المراجعة
                createResult = await _reviewRepository.CreateReviewAsync(review, cancellationToken);
                if (createResult == null)
                {
                    throw new InvalidOperationException("SAVE_REVIEW_FAILED");
                }

                // حفظ مراجع الصور المرتبطة بالتقييم في قاعدة البيانات
                if (uploadedImages.Count > 0)
                {
                    await SaveReviewImagesAsync(review.Id, uploadedImages, cancellationToken);
                }

                await _reviewRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            _logger.LogInformation("تم إنشاء المراجعة بنجاح للعقار: {PropertyId}", request.PropertyId);

            _logger.LogInformation("تم إنشاء المراجعة بنجاح: {ReviewId}", review.Id);

            // ملاحظة: يمكن إضافة إرسال تنبيه للإدارة لاحقاً
            // Note: Admin notification can be added later
            _logger.LogInformation("تمت المراجعة وهي في انتظار الموافقة: {ReviewId}", review.Id);

            _logger.LogInformation("تم إرسال المراجعة بنجاح: {ReviewId} للحجز: {BookingId}", 
                review.Id, request.BookingId);

            // تدقيق يدوي: إرسال مراجعة
            var performerName = _currentUserService.Username;
            var performerId = _currentUserService.UserId;
            var notes = $"تم إرسال مراجعة للعقار {request.PropertyId} (حجز {request.BookingId}) بواسطة {performerName} (ID={performerId})";
            await _auditService.LogAuditAsync(
                entityType: "Review",
                entityId: review.Id,
                action: AuditAction.CREATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { review.Id, request.PropertyId, request.BookingId, overallRating }),
                performedBy: performerId,
                notes: notes,
                cancellationToken: cancellationToken);

            // تحديث متوسط تقييم العقار بعد إضافة المراجعة
            try
            {
                var (avgRating, totalReviews) = await _reviewRepository.GetPropertyRatingStatsAsync(request.PropertyId, cancellationToken);
                var propertyToUpdate = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
                if (propertyToUpdate != null)
                {
                    propertyToUpdate.AverageRating = (decimal)avgRating;
                    await _propertyRepository.UpdatePropertyAsync(propertyToUpdate, cancellationToken);
                    await _propertyRepository.SaveChangesAsync(cancellationToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر تحديث متوسط تقييم العقار بعد إضافة المراجعة {PropertyId}", request.PropertyId);
            }

            var response = new SubmitReviewResponse
            {
                ReviewId = review.Id,
                Success = true,
                Message = "تم إرسال المراجعة بنجاح. سيتم نشرها بعد مراجعتها من قبل فريق الإدارة"
            };

            return ResultDto<SubmitReviewResponse>.Ok(response, "تم إرسال المراجعة بنجاح");
        }
        catch (Exception ex)
        {
            if (uploadedImages.Count > 0)
            {
                await DeleteUploadedImages(uploadedImages.Select(i => i.Url).ToList(), cancellationToken);
            }
            _logger.LogError(ex, "خطأ أثناء إرسال المراجعة للحجز: {BookingId}", request.BookingId);
            return ResultDto<SubmitReviewResponse>.Failed($"حدث خطأ أثناء إرسال المراجعة: {ex.Message}", "SUBMIT_REVIEW_ERROR");
        }
    }

    private ResultDto<SubmitReviewResponse> ValidateRequest(SubmitReviewCommand request)
    {
        if (request.BookingId == Guid.Empty)
        {
            return ResultDto<SubmitReviewResponse>.Failed("معرف الحجز غير صالح", "INVALID_BOOKING_ID");
        }

        if (request.PropertyId == Guid.Empty)
        {
            return ResultDto<SubmitReviewResponse>.Failed("معرف العقار غير صالح", "INVALID_PROPERTY_ID");
        }

        // التحقق من التقييمات (يجب أن تكون بين 1 و 5)
        var ratings = new[] { request.Cleanliness, request.Service, request.Location, request.Value };
        if (ratings.Any(r => r < 1 || r > 5))
        {
            return ResultDto<SubmitReviewResponse>.Failed("التقييمات يجب أن تكون بين 1 و 5", "INVALID_RATINGS");
        }

        // التحقق من التعليق
        if (string.IsNullOrWhiteSpace(request.Comment))
        {
            return ResultDto<SubmitReviewResponse>.Failed("تعليق المراجعة مطلوب", "COMMENT_REQUIRED");
        }

        if (request.Comment.Length < 10 || request.Comment.Length > 1000)
        {
            return ResultDto<SubmitReviewResponse>.Failed("تعليق المراجعة يجب أن يكون بين 10 و 1000 حرف", "INVALID_COMMENT_LENGTH");
        }

        var imagesBase64 = request.ImagesBase64 ?? new List<string>();

        // التحقق من عدد الصور (حد أقصى 5 صور)
        if (imagesBase64.Count > 5)
        {
            return ResultDto<SubmitReviewResponse>.Failed("يمكن رفع 5 صور كحد أقصى", "TOO_MANY_IMAGES");
        }

        // التحقق من صحة تنسيق الصور
        foreach (var imageBase64 in imagesBase64)
        {
            if (string.IsNullOrWhiteSpace(imageBase64))
            {
                return ResultDto<SubmitReviewResponse>.Failed("تنسيق الصورة غير صالح", "INVALID_IMAGE_FORMAT");
            }

            try
            {
                var imageBytes = Convert.FromBase64String(ExtractBase64Payload(imageBase64));
                if (imageBytes.Length > 5 * 1024 * 1024) // 5 ميجابايت
                {
                    return ResultDto<SubmitReviewResponse>.Failed("حجم الصورة يجب أن يكون أقل من 5 ميجابايت", "IMAGE_TOO_LARGE");
                }
            }
            catch (FormatException)
            {
                return ResultDto<SubmitReviewResponse>.Failed("تنسيق الصورة غير صحيح", "INVALID_IMAGE_FORMAT");
            }
        }

        if (!string.IsNullOrWhiteSpace(request.VideoBase64))
        {
            try
            {
                var videoBytes = Convert.FromBase64String(ExtractBase64Payload(request.VideoBase64));
                if (videoBytes.Length > 25 * 1024 * 1024)
                {
                    return ResultDto<SubmitReviewResponse>.Failed("حجم فيديو التقييم يجب أن يكون أقل من 25 ميجابايت", "VIDEO_TOO_LARGE");
                }
            }
            catch (FormatException)
            {
                return ResultDto<SubmitReviewResponse>.Failed("تنسيق فيديو التقييم غير صحيح", "INVALID_VIDEO_FORMAT");
            }
        }

        if (!string.IsNullOrWhiteSpace(request.VideoThumbnailBase64))
        {
            try
            {
                _ = Convert.FromBase64String(ExtractBase64Payload(request.VideoThumbnailBase64));
            }
            catch (FormatException)
            {
                return ResultDto<SubmitReviewResponse>.Failed("تنسيق الصورة المصغرة للفيديو غير صحيح", "INVALID_VIDEO_THUMBNAIL_FORMAT");
            }
        }

        return ResultDto<SubmitReviewResponse>.Ok(null, "البيانات صحيحة");
    }

    private async Task<List<UploadedReviewImage>> UploadReviewImages(List<string> imagesBase64, Guid bookingId, CancellationToken cancellationToken)
    {
        var uploaded = new List<UploadedReviewImage>();

        for (int i = 0; i < imagesBase64.Count; i++)
        {
            try
            {
                var source = imagesBase64[i];
                var payload = ExtractBase64Payload(source);
                var contentType = ExtractContentType(source);
                var extension = GetFileExtension(contentType);
                var imageBytes = Convert.FromBase64String(payload);
                var fileName = $"review_{bookingId}_{i + 1}_{DateTime.UtcNow:yyyyMMddHHmmss}.{extension}";
                
                using var imageStream = new MemoryStream(imageBytes);
                var uploadResult = await _fileUploadService.UploadImageAsync(imageStream, fileName, folder: "reviews");
                var isSuccess = !string.IsNullOrEmpty(uploadResult);
                var fileUrl = uploadResult;
                
                if (isSuccess)
                {
                    uploaded.Add(new UploadedReviewImage(
                        Url: fileUrl,
                        Name: fileName,
                        SizeBytes: imageBytes.LongLength,
                        ContentType: contentType,
                        DisplayOrder: i));
                    _logger.LogInformation("تم رفع صورة المراجعة: {FileName}", fileName);
                }
                else
                {
                    _logger.LogWarning("فشل في رفع صورة المراجعة: {FileName}", fileName);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في رفع صورة المراجعة رقم: {ImageIndex}", i + 1);
            }
        }

        return uploaded;
    }

    private async Task<UploadedReviewImage?> UploadReviewVideoAsync(
        string? videoBase64,
        string? videoThumbnailBase64,
        Guid bookingId,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(videoBase64))
        {
            return null;
        }

        try
        {
            var contentType = ExtractContentType(videoBase64);
            var extension = GetMediaFileExtension(contentType);
            var videoBytes = Convert.FromBase64String(ExtractBase64Payload(videoBase64));
            var fileName = $"review_video_{bookingId}_{DateTime.UtcNow:yyyyMMddHHmmss}.{extension}";

            var uploadResult = await _fileStorageService.UploadFileAsync(
                videoBytes,
                fileName,
                contentType,
                "reviews",
                cancellationToken);

            if (!uploadResult.IsSuccess || string.IsNullOrWhiteSpace(uploadResult.FileUrl))
            {
                return null;
            }

            string? thumbnailUrl = null;
            if (!string.IsNullOrWhiteSpace(videoThumbnailBase64))
            {
                try
                {
                    var thumbnailContentType = ExtractContentType(videoThumbnailBase64);
                    var thumbnailExtension = GetMediaFileExtension(thumbnailContentType);
                    var thumbnailBytes = Convert.FromBase64String(
                        ExtractBase64Payload(videoThumbnailBase64));
                    var thumbnailFileName =
                        $"review_video_{bookingId}_{DateTime.UtcNow:yyyyMMddHHmmss}_poster.{thumbnailExtension}";

                    var thumbnailUpload = await _fileStorageService.UploadFileAsync(
                        thumbnailBytes,
                        thumbnailFileName,
                        thumbnailContentType,
                        "reviews",
                        cancellationToken);

                    if (thumbnailUpload.IsSuccess &&
                        !string.IsNullOrWhiteSpace(thumbnailUpload.FileUrl))
                    {
                        thumbnailUrl = thumbnailUpload.FileUrl;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "تعذر رفع الصورة المصغرة لفيديو المراجعة");
                }
            }

            return new UploadedReviewImage(
                Url: uploadResult.FileUrl!,
                Name: fileName,
                SizeBytes: videoBytes.LongLength,
                ContentType: contentType,
                DisplayOrder: 999,
                ThumbnailUrl: thumbnailUrl);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء رفع فيديو التقييم للحجز {BookingId}", bookingId);
            return null;
        }
    }

    private async Task DeleteUploadedImages(List<string> imageUrls, CancellationToken cancellationToken)
    {
        foreach (var imageUrl in imageUrls)
        {
            try
            {
                await _fileUploadService.DeleteFileAsync(imageUrl);
                _logger.LogInformation("تم حذف صورة المراجعة: {ImageUrl}", imageUrl);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "فشل في حذف صورة المراجعة: {ImageUrl}", imageUrl);
            }
        }
    }

    private async Task SaveReviewImagesAsync(
        Guid reviewId,
        List<UploadedReviewImage> uploadedImages,
        CancellationToken cancellationToken)
    {
        foreach (var image in uploadedImages)
        {
            try
            {
                var reviewImage = new ReviewImage
                {
                    Id = Guid.NewGuid(),
                    ReviewId = reviewId,
                    Name = image.Name,
                    Url = image.Url,
                    SizeBytes = image.SizeBytes,
                    Type = image.ContentType,
                    Category = ImageCategory.Gallery,
                    Caption = string.Empty,
                    AltText = string.Empty,
                    Tags = ReviewImageMetadataHelper.BuildTags(image.ThumbnailUrl),
                    IsMain = image.DisplayOrder == 0,
                    DisplayOrder = image.DisplayOrder,
                    UploadedAt = DateTime.UtcNow,
                    Status = ImageStatus.Pending
                };

                await _reviewImageRepository.CreateReviewImageAsync(reviewImage, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر حفظ مرجع صورة التقييم {ImageUrl} في قاعدة البيانات", image.Url);
            }
        }
    }

    private static string ExtractBase64Payload(string source)
    {
        if (string.IsNullOrWhiteSpace(source))
        {
            return string.Empty;
        }

        var commaIndex = source.IndexOf(',');
        if (commaIndex >= 0 && commaIndex < source.Length - 1)
        {
            return source[(commaIndex + 1)..];
        }

        return source;
    }

    private static string ExtractContentType(string source)
    {
        if (!string.IsNullOrWhiteSpace(source) &&
            source.StartsWith("data:", StringComparison.OrdinalIgnoreCase))
        {
            var semicolonIndex = source.IndexOf(';');
            if (semicolonIndex > 5)
            {
                return source[5..semicolonIndex];
            }
        }

        return "image/jpeg";
    }

    private static string GetFileExtension(string contentType)
    {
        return contentType.ToLowerInvariant() switch
        {
            "image/png" => "png",
            "image/webp" => "webp",
            "image/gif" => "gif",
            "image/bmp" => "bmp",
            _ => "jpg"
        };
    }

    private static string GetMediaFileExtension(string contentType)
    {
        return contentType.ToLowerInvariant() switch
        {
            "image/png" => "png",
            "image/webp" => "webp",
            "image/gif" => "gif",
            "video/mp4" => "mp4",
            "video/quicktime" => "mov",
            "video/webm" => "webm",
            "video/x-matroska" => "mkv",
            _ => GetFileExtension(contentType)
        };
    }

    private sealed record UploadedReviewImage(
        string Url,
        string Name,
        long SizeBytes,
        string ContentType,
        int DisplayOrder,
        string? ThumbnailUrl);
}
