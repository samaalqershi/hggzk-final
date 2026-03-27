using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// يعالج أمر نسخ الصورة.
    /// Handles the copy image command.
    /// </summary>
    public class CopyImageCommandHandler : IRequestHandler<CopyImageCommand, ResultDto<ImageDto>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IUnitRepository _unitRepository;
        private readonly IFileStorageService _fileStorageService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<CopyImageCommandHandler> _logger;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [CopyImageCommandHandler].
        /// Initializes a new instance of [CopyImageCommandHandler].
        /// </summary>
        public CopyImageCommandHandler(
            IPropertyImageRepository imageRepository,
            IPropertyRepository propertyRepository,
            IUnitRepository unitRepository,
            IFileStorageService fileStorageService,
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            ILogger<CopyImageCommandHandler> logger)
        {
            _imageRepository = imageRepository;
            _propertyRepository = propertyRepository;
            _unitRepository = unitRepository;
            _fileStorageService = fileStorageService;
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _logger = logger;
        }
        /// <summary>
        /// يعالج أمر نسخ الصورة إلى المسار المستهدف.
        /// Handles copying an image to the target path.
        /// </summary>
        public async Task<ResultDto<ImageDto>> Handle(CopyImageCommand request, CancellationToken cancellationToken)
        {
            if ((request.TargetPropertyId.HasValue && request.TargetUnitId.HasValue) ||
                (!request.TargetPropertyId.HasValue && !request.TargetUnitId.HasValue))
            {
                return ResultDto<ImageDto>.Failure(
                    "يجب تحديد كيان أو وحدة هدف واحدة فقط",
                    "Specify exactly one target property or unit",
                    "INVALID_TARGET");
            }

            var sourceImage = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (sourceImage == null)
                return ResultDto<ImageDto>.Failure("الصورة الأصلية غير موجودة", "Source image not found", "IMAGE_NOT_FOUND");

            Guid targetPropertyId;
            Guid? targetUnitId = null;

            if (request.TargetPropertyId.HasValue)
            {
                var property = await _propertyRepository.GetPropertyByIdAsync(request.TargetPropertyId.Value, cancellationToken);
                if (property == null)
                    return ResultDto<ImageDto>.Failure("الكيان الهدف غير موجود", "Target property not found", "PROPERTY_NOT_FOUND");

                targetPropertyId = property.Id;
            }
            else
            {
                var unit = await _unitRepository.GetUnitByIdAsync(request.TargetUnitId!.Value, cancellationToken);
                if (unit == null)
                    return ResultDto<ImageDto>.Failure("الوحدة الهدف غير موجودة", "Target unit not found", "UNIT_NOT_FOUND");

                var property = await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
                if (property == null)
                    return ResultDto<ImageDto>.Failure("الكيان المرتبط بالوحدة غير موجود", "The target unit's property was not found", "PROPERTY_NOT_FOUND");

                targetPropertyId = property.Id;
                targetUnitId = unit.Id;
            }

            var sourceRelativePath = ResolveStorageRelativePath(sourceImage.Url);
            if (string.IsNullOrWhiteSpace(sourceRelativePath))
                return ResultDto<ImageDto>.Failure("تعذر تحديد مسار الصورة الأصلية", "Unable to resolve the source image path", "SOURCE_PATH_INVALID");

            var sourceFileName = Path.GetFileName(sourceRelativePath);
            if (string.IsNullOrWhiteSpace(sourceFileName))
                return ResultDto<ImageDto>.Failure("اسم ملف الصورة الأصلية غير صالح", "Invalid source image file name", "SOURCE_FILE_INVALID");

            var baseFileName = Path.GetFileNameWithoutExtension(sourceFileName);
            var extension = Path.GetExtension(sourceFileName);
            var copyToken = Guid.NewGuid().ToString("N").Substring(0, 8);
            var destinationFileName = $"{baseFileName}_copy_{copyToken}{extension}";
            var destinationFolder = targetUnitId.HasValue
                ? $"Management/{targetPropertyId}/{targetUnitId.Value}"
                : $"Management/{targetPropertyId}";
            var destinationRelativePath = $"{destinationFolder}/{destinationFileName}";

            if (!await _fileStorageService.CopyFileAsync(sourceRelativePath, destinationRelativePath, cancellationToken))
                return ResultDto<ImageDto>.Failure("فشل نسخ ملف الصورة", "Failed to copy the image file", "FILE_COPY_FAILED");

            var copiedVideoThumbnailUrl = sourceImage.VideoThumbnailUrl;
            var sourceThumbnailRelativePath = ResolveStorageRelativePath(sourceImage.VideoThumbnailUrl);
            var copiedThumbnailRelativePath = string.Empty;

            if (!string.IsNullOrWhiteSpace(sourceThumbnailRelativePath))
            {
                var thumbExtension = Path.GetExtension(sourceThumbnailRelativePath);
                if (string.IsNullOrWhiteSpace(thumbExtension))
                    thumbExtension = ".jpg";

                copiedThumbnailRelativePath = $"{destinationFolder}/{baseFileName}_copy_{copyToken}_poster{thumbExtension}";
                if (await _fileStorageService.CopyFileAsync(sourceThumbnailRelativePath, copiedThumbnailRelativePath, cancellationToken))
                {
                    copiedVideoThumbnailUrl = await _fileStorageService.GetFileUrlAsync(copiedThumbnailRelativePath, null, cancellationToken);
                }
                else
                {
                    _logger.LogWarning(
                        "تعذر نسخ صورة الفيديو المصغرة للصورة {ImageId}; سيتم الاحتفاظ بالرابط الأصلي",
                        sourceImage.Id);
                    copiedThumbnailRelativePath = string.Empty;
                }
            }

            var nowUtc = DateTime.UtcNow;
            var copiedFileUrl = await _fileStorageService.GetFileUrlAsync(destinationRelativePath, null, cancellationToken);
            var copiedImage = new PropertyImage
            {
                Id = Guid.NewGuid(),
                PropertyId = targetPropertyId,
                UnitId = targetUnitId,
                SectionId = null,
                PropertyInSectionId = null,
                UnitInSectionId = null,
                CityName = null,
                TempKey = null,
                Name = destinationFileName,
                Url = copiedFileUrl,
                SizeBytes = sourceImage.SizeBytes,
                Type = sourceImage.Type,
                Category = sourceImage.Category,
                Caption = sourceImage.Caption,
                AltText = sourceImage.AltText,
                Tags = sourceImage.Tags,
                Sizes = copiedFileUrl,
                IsMain = false,
                IsMainImage = false,
                DisplayOrder = sourceImage.DisplayOrder,
                UploadedAt = nowUtc,
                CreatedAt = nowUtc,
                CreatedBy = _currentUserService.UserId == Guid.Empty ? sourceImage.CreatedBy : _currentUserService.UserId,
                UpdatedAt = nowUtc,
                MediaType = string.IsNullOrWhiteSpace(sourceImage.MediaType)
                    ? (sourceImage.Type?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) == true ? "video" : "image")
                    : sourceImage.MediaType,
                DurationSeconds = sourceImage.DurationSeconds,
                VideoThumbnailUrl = copiedVideoThumbnailUrl,
                Is360 = sourceImage.Is360,
                Status = sourceImage.Status
            };

            try
            {
                await _unitOfWork.ExecuteInTransactionAsync(async () =>
                {
                    await _imageRepository.CreatePropertyImageAsync(copiedImage, cancellationToken);
                    await _imageRepository.SaveChangesAsync(cancellationToken);
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "فشل حفظ نسخة الصورة الجديدة {SourceImageId}", sourceImage.Id);
                await _fileStorageService.DeleteFileAsync(destinationRelativePath, cancellationToken);
                if (!string.IsNullOrWhiteSpace(copiedThumbnailRelativePath))
                {
                    await _fileStorageService.DeleteFileAsync(copiedThumbnailRelativePath, cancellationToken);
                }

                return ResultDto<ImageDto>.Failure("فشل حفظ نسخة الصورة", "Failed to persist the copied image", "IMAGE_COPY_SAVE_FAILED");
            }

            var dto = await ToDtoAsync(copiedImage);
            _logger.LogInformation(
                "تم نسخ الصورة بنجاح: SourceImageId={SourceImageId}, CopiedImageId={CopiedImageId}",
                sourceImage.Id,
                copiedImage.Id);

            return ResultDto<ImageDto>.Ok(dto, "تم نسخ الصورة بنجاح", "Image copied successfully");
        }

        private static string? ResolveStorageRelativePath(string? pathOrUrl)
        {
            if (string.IsNullOrWhiteSpace(pathOrUrl))
                return null;

            string relativePath;
            if (Uri.TryCreate(pathOrUrl, UriKind.Absolute, out var absoluteUri))
            {
                relativePath = Uri.UnescapeDataString(absoluteUri.AbsolutePath).TrimStart('/');
            }
            else
            {
                relativePath = Uri.UnescapeDataString(pathOrUrl.TrimStart('/'));
            }

            const string uploadsPrefix = "uploads/";
            return relativePath.StartsWith(uploadsPrefix, StringComparison.OrdinalIgnoreCase)
                ? relativePath.Substring(uploadsPrefix.Length)
                : relativePath;
        }

        private async Task<ImageDto> ToDtoAsync(PropertyImage image)
        {
            var uploadedLocal = await _currentUserService.ConvertFromUtcToUserLocalAsync(image.UploadedAt);

            return new ImageDto
            {
                Id = image.Id,
                Url = image.Url,
                Filename = image.Name,
                Size = image.SizeBytes,
                MimeType = image.Type,
                Width = 0,
                Height = 0,
                Alt = image.AltText,
                UploadedAt = uploadedLocal,
                UploadedBy = image.CreatedBy ?? Guid.Empty,
                Order = image.DisplayOrder,
                IsPrimary = image.IsMain || image.IsMainImage,
                Is360 = image.Is360,
                PropertyId = image.PropertyId,
                UnitId = image.UnitId,
                Category = image.Category,
                Tags = string.IsNullOrWhiteSpace(image.Tags)
                    ? new System.Collections.Generic.List<string>()
                    : System.Text.Json.JsonSerializer.Deserialize<System.Collections.Generic.List<string>>(image.Tags) ?? new System.Collections.Generic.List<string>(),
                ProcessingStatus = image.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = image.Sizes ?? string.Empty,
                    Medium = image.Sizes ?? string.Empty,
                    Large = image.Sizes ?? string.Empty,
                    Hd = image.Sizes ?? string.Empty
                },
                MediaType = string.IsNullOrWhiteSpace(image.MediaType)
                    ? (image.Type?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) == true ? "video" : "image")
                    : image.MediaType,
                Duration = image.DurationSeconds,
                VideoThumbnail = string.IsNullOrWhiteSpace(image.VideoThumbnailUrl) ? null : image.VideoThumbnailUrl
            };
        }
    }
}
