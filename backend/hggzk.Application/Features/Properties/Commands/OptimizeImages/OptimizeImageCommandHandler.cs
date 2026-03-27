using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.OptimizeImages
{
    /// <summary>
    /// يعالج أمر تحسين الصورة.
    /// Handles the optimize image command.
    /// </summary>
    public class OptimizeImageCommandHandler : IRequestHandler<OptimizeImageCommand, ResultDto<ImageDto>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        /// <summary>
        /// يهيّئ مثيلاً جديداً من [OptimizeImageCommandHandler].
        /// Initializes a new instance of [OptimizeImageCommandHandler].
        /// </summary>
        public OptimizeImageCommandHandler(IPropertyImageRepository imageRepository)
        {
            _imageRepository = imageRepository;
        }
        /// <summary>
        /// يعالج أمر تحسين الصورة ويعيد النسخة المتاحة بأمان.
        /// Handles image optimization and returns the safely available version.
        /// </summary>
        public async Task<ResultDto<ImageDto>> Handle(OptimizeImageCommand request, CancellationToken cancellationToken)
        {
            // جلب بيانات الصورة من المستودع
            var image = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (image == null)
                return ResultDto<ImageDto>.Failure("الصورة غير موجودة");

            // تم إيقاف تحسين الصور من الخادم مؤقتاً لتجنب إعادة كتابة الملفات دون مسار قراءة موحد من التخزين.
            // نعيد بيانات الصورة الحالية بشكل آمن بدلاً من رمي استثناء وقت التشغيل.
            var dto = new ImageDto
            {
                Id = image.Id,
                Url = image.Url ?? string.Empty,
                Filename = image.Name ?? string.Empty,
                Size = image.SizeBytes,
                MimeType = image.Type ?? string.Empty,
                Width = 0,
                Height = 0,
                Alt = image.AltText,
                UploadedAt = image.UploadedAt,
                UploadedBy = image.CreatedBy ?? Guid.Empty,
                Order = image.DisplayOrder != 0 ? image.DisplayOrder : image.SortOrder,
                IsPrimary = image.IsMain || image.IsMainImage,
                PropertyId = image.PropertyId,
                UnitId = image.UnitId,
                SectionId = image.SectionId,
                PropertyInSectionId = image.PropertyInSectionId,
                UnitInSectionId = image.UnitInSectionId,
                Category = image.Category,
                ProcessingStatus = image.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = image.Sizes ?? string.Empty,
                    Medium = image.Sizes ?? string.Empty,
                    Large = image.Sizes ?? string.Empty,
                    Hd = image.Sizes ?? string.Empty
                },
                MediaType = string.IsNullOrWhiteSpace(image.MediaType) ? "image" : image.MediaType,
                Is360 = image.Is360,
                Duration = image.DurationSeconds,
                VideoThumbnail = image.VideoThumbnailUrl
            };

            return ResultDto<ImageDto>.Succeeded(
                dto,
                "تم تجاوز تحسين الصورة على الخادم حالياً؛ أُعيدت بيانات الصورة الحالية بدون تنفيذ عملية تحسين.");
        }
    }
}
