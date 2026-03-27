using System;
using System.Linq;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.SearchImages
{
    /// <summary>
    /// يعالج أمر البحث عن الصور.
    /// Handles the search images command.
    /// </summary>
    public class SearchImagesQueryHandler : IRequestHandler<SearchImagesQuery, ResultDto<PaginatedResultDto<ImageDto>>>
    {
        private readonly IPropertyImageRepository _imageRepository;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [SearchImagesQueryHandler].
        /// Initializes a new instance of [SearchImagesQueryHandler].
        /// </summary>
        public SearchImagesQueryHandler(IPropertyImageRepository imageRepository)
        {
            _imageRepository = imageRepository;
        }
        /// <summary>
        /// يعالج استعلام البحث في الصور المرفقة بالعقارات.
        /// Handles searching property-related images.
        /// </summary>
        public async Task<ResultDto<PaginatedResultDto<ImageDto>>> Handle(SearchImagesQuery request, CancellationToken cancellationToken)
        {
            var page = request.Page.GetValueOrDefault(1);
            var limit = request.Limit.GetValueOrDefault(20);

            if (page <= 0)
            {
                page = 1;
            }

            if (limit <= 0)
            {
                limit = 20;
            }

            var images = (await _imageRepository.GetAllAsync(cancellationToken)).AsEnumerable();

            if (request.DateFrom.HasValue)
            {
                images = images.Where(image => image.UploadedAt >= request.DateFrom.Value);
            }

            if (request.DateTo.HasValue)
            {
                images = images.Where(image => image.UploadedAt <= request.DateTo.Value);
            }

            if (request.MinSize.HasValue)
            {
                images = images.Where(image => image.SizeBytes >= request.MinSize.Value);
            }

            if (request.MaxSize.HasValue)
            {
                images = images.Where(image => image.SizeBytes <= request.MaxSize.Value);
            }

            if (request.PrimaryOnly == true)
            {
                images = images.Where(image => image.IsMain || image.IsMainImage);
            }

            if (request.UploadedBy?.Count > 0)
            {
                var uploadedBy = request.UploadedBy.ToHashSet();
                images = images.Where(image => image.CreatedBy.HasValue && uploadedBy.Contains(image.CreatedBy.Value));
            }

            if (request.MimeTypes?.Count > 0)
            {
                var mimeTypes = request.MimeTypes
                    .Where(type => !string.IsNullOrWhiteSpace(type))
                    .Select(type => type.Trim())
                    .ToHashSet(StringComparer.OrdinalIgnoreCase);

                images = images.Where(image => !string.IsNullOrWhiteSpace(image.Type) && mimeTypes.Contains(image.Type));
            }

            if (request.Tags?.Count > 0)
            {
                var tags = request.Tags
                    .Where(tag => !string.IsNullOrWhiteSpace(tag))
                    .Select(tag => tag.Trim())
                    .ToList();

                images = images.Where(image =>
                    !string.IsNullOrWhiteSpace(image.Tags) &&
                    tags.Any(tag => image.Tags.Contains(tag, StringComparison.OrdinalIgnoreCase)));
            }

            var orderedImages = images
                .OrderByDescending(image => image.UploadedAt)
                .ThenByDescending(image => image.CreatedAt);

            var total = orderedImages.Count();
            var items = orderedImages
                .Skip((page - 1) * limit)
                .Take(limit)
                .Select(image => new ImageDto
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
                    Tags = string.IsNullOrWhiteSpace(image.Tags)
                        ? new List<string>()
                        : image.Tags.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList(),
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
                })
                .ToList();

            var result = new PaginatedResultDto<ImageDto>
            {
                Items = items,
                Total = total,
                Page = page,
                Limit = limit,
                TotalPages = total == 0 ? 0 : (int)Math.Ceiling(total / (double)limit)
            };

            return ResultDto<PaginatedResultDto<ImageDto>>.SuccessResult(result);
        }
    }
}
