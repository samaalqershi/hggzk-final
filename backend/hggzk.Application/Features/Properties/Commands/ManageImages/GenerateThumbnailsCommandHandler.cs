using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// يعالج أمر توليد Thumbnails.
    /// Handles the generate thumbnails command.
    /// </summary>
    public class GenerateThumbnailsCommandHandler : IRequestHandler<GenerateThumbnailsCommand, ResultDto<ImageDto>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        /// <summary>
        /// يهيّئ مثيلاً جديداً من [GenerateThumbnailsCommandHandler].
        /// Initializes a new instance of [GenerateThumbnailsCommandHandler].
        /// </summary>
        public GenerateThumbnailsCommandHandler(IPropertyImageRepository imageRepository)
        {
            _imageRepository = imageRepository;
        }
        /// <summary>
        /// يعالج أمر توليد الصور المصغرة.
        /// Handles generating image thumbnails.
        /// </summary>
        public async Task<ResultDto<ImageDto>> Handle(GenerateThumbnailsCommand request, CancellationToken cancellationToken)
        {
            // تم إلغاء توليد المصغرات من الخادم. احتفظنا بمعالج الأمر فقط للتماشي مع الواجهة القديمة.
            // أعد بيانات الصورة دون تعديل.
            var image = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (image == null)
                return ResultDto<ImageDto>.Failure("الصورة غير موجودة");

            var dto = new ImageDto
            {
                Id = image.Id,
                Url = image.Url,
                Filename = image.Name,
                Size = image.SizeBytes,
                MimeType = image.Type,
                UploadedAt = image.UploadedAt,
                UploadedBy = image.CreatedBy ?? Guid.Empty,
                Order = image.DisplayOrder,
                IsPrimary = image.IsMain || image.IsMainImage,
                Is360 = image.Is360,
                PropertyId = image.PropertyId,
                UnitId = image.UnitId,
                Category = image.Category,
                Alt = image.AltText,
                ProcessingStatus = image.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = image.Sizes,
                    Medium = image.Sizes,
                    Large = image.Sizes,
                    Hd = image.Sizes
                },
                MediaType = string.IsNullOrWhiteSpace(image.MediaType)
                    ? ((image.Type?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) ?? false) ? "video" : "image")
                    : image.MediaType,
                Duration = image.DurationSeconds,
                VideoThumbnail = string.IsNullOrWhiteSpace(image.VideoThumbnailUrl) ? null : image.VideoThumbnailUrl
            };

            return ResultDto<ImageDto>.Succeeded(dto, "تم تجاوز توليد المصغرات في الخادم؛ المصغرات تُولّد في العميل");
        }
    }
} 
