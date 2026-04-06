using MediatR;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Reviews.Queries.GetPropertyReviews;

    /// <summary>
    /// يعالج مكوّن النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles a current feature area component and returns the requested result.
    /// </summary>
public class ClientGetPropertyReviewsQueryHandler : IRequestHandler<ClientGetPropertyReviewsQuery, ResultDto<PaginatedResult<ClientReviewDto>>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public ClientGetPropertyReviewsQueryHandler(IReviewRepository reviewRepository, ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the property reviews query and returns the result.
    /// </summary>
    public async Task<ResultDto<PaginatedResult<ClientReviewDto>>> Handle(ClientGetPropertyReviewsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            var query = _reviewRepository.GetQueryable()
                .AsNoTracking()
                .Include(r => r.Booking)
                    .ThenInclude(b => b.User)
                .Include(r => r.Images)
                .Include(r => r.Property)
                .Where(r => r.PropertyId == request.PropertyId);

            // Visibility rules:
            // - عامة العملاء: يرون فقط التقييمات المعتمدة وغير المعطَّلة
            // - العميل صاحب التقييم: يرى تقييمه حتى لو كان قيد المراجعة أو معطَّلاً
            if (request.UserId.HasValue)
            {
                var userId = request.UserId.Value;
                query = query.Where(r =>
                    (!r.IsPendingApproval && !r.IsDisabled) ||
                    (r.Booking != null && r.Booking.UserId == userId));
            }
            else
            {
                query = query.Where(r => !r.IsPendingApproval && !r.IsDisabled);
            }

            // تطبيق الفلاتر
            // Apply filters
            if (request.Rating.HasValue)
            {
                query = query.Where(r => r.AverageRating >= request.Rating.Value);
            }

            if (request.WithImagesOnly)
            {
                query = query.Where(r => r.Images != null && r.Images.Any());
            }

            // الترتيب
            // Ordering
            query = request.SortBy?.ToLowerInvariant() switch
            {
                "rating" => request.SortDirection?.ToLowerInvariant() == "asc"
                    ? query.OrderBy(r => r.AverageRating)
                    : query.OrderByDescending(r => r.AverageRating),
                "date" => request.SortDirection?.ToLowerInvariant() == "asc"
                    ? query.OrderBy(r => r.CreatedAt)
                    : query.OrderByDescending(r => r.CreatedAt),
                _ => query.OrderByDescending(r => r.CreatedAt)
            };

            // التحويل إلى DTO
            // Convert to DTO
            var reviewDtos = query.Select(r => new ClientReviewDto
            {
                Id = r.Id,
                UserId = r.Booking != null ? r.Booking.UserId : Guid.Empty,
                BookingId = r.BookingId,
                PropertyName = r.Property != null ? r.Property.Name : string.Empty,
                UserName = r.Booking != null && r.Booking.User != null
                    ? (r.Booking.User.Name ?? "مستخدم مجهول")
                    : "مستخدم مجهول",
                UserAvatar = r.Booking != null && r.Booking.User != null
                    ? r.Booking.User.ProfileImageUrl
                    : null,
                Rating = (int)Math.Round(r.AverageRating),
                Cleanliness = r.Cleanliness,
                Service = r.Service,
                Location = r.Location,
                Value = r.Value,
                AverageRating = r.AverageRating,
                Title = string.Empty,
                Comment = r.Comment,
                CreatedAt = r.CreatedAt,
                ResponseText = r.ResponseText,
                ResponseDate = r.ResponseDate,
                Images = r.Images != null
                    ? r.Images.Select(img => new ClientReviewImageDto
                    {
                        Id = img.Id,
                        ReviewId = img.ReviewId,
                        Name = img.Name,
                        Url = img.Url,
                        ThumbnailUrl = ReviewImageMetadataHelper.GetThumbnailUrl(img),
                        Caption = img.Caption,
                        DisplayOrder = img.DisplayOrder,
                        SizeBytes = img.SizeBytes,
                        Type = img.Type,
                        Category = img.Category.ToString(),
                        AltText = img.AltText,
                        UploadedAt = img.UploadedAt
                    }).OrderBy(i => i.DisplayOrder).ToList()
                    : new List<ClientReviewImageDto>(),
                IsUserReview = request.UserId.HasValue &&
                               r.Booking != null &&
                               r.Booking.UserId == request.UserId.Value,
                LikesCount = 0,
                IsLikedByUser = false,
                ManagementReply = !string.IsNullOrWhiteSpace(r.ResponseText)
                    ? new ClientReviewReplyDto
                    {
                        Id = Guid.NewGuid(),
                        Content = r.ResponseText,
                        CreatedAt = r.ResponseDate ?? DateTime.UtcNow,
                        ReplierName = "إدارة العقار",
                        ReplierPosition = "ممثل خدمة العملاء"
                    }
                    : null,
                BookingType = "Standard",
                IsRecommended = r.AverageRating >= 4,
                IsPendingApproval = r.IsPendingApproval,
                IsDisabled = r.IsDisabled
            }).ToList();

            // Localize date/time fields
            for (int i = 0; i < reviewDtos.Count; i++)
            {
                reviewDtos[i].CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(reviewDtos[i].CreatedAt);

                if (reviewDtos[i].ResponseDate.HasValue)
                {
                    reviewDtos[i].ResponseDate = await _currentUserService.ConvertFromUtcToUserLocalAsync(reviewDtos[i].ResponseDate.Value);
                }

                if (reviewDtos[i].ManagementReply != null)
                {
                    reviewDtos[i].ManagementReply.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(reviewDtos[i].ManagementReply.CreatedAt);
                }

                if (reviewDtos[i].Images.Count > 0)
                {
                    for (int j = 0; j < reviewDtos[i].Images.Count; j++)
                    {
                        reviewDtos[i].Images[j].UploadedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(reviewDtos[i].Images[j].UploadedAt);
                    }
                }
            }

            // التقسيم
            // Pagination
            var totalCount = reviewDtos.Count;
            var items = reviewDtos
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToList();

            return ResultDto<PaginatedResult<ClientReviewDto>>.SuccessResult(new PaginatedResult<ClientReviewDto>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }
        catch
        {
            return ResultDto<PaginatedResult<ClientReviewDto>>.Failure("حدث خطأ أثناء جلب التقييمات");
        }
    }
}
