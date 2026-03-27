using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reviews.Queries.GetPropertyReviews;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class ClientGetPropertyReviewsQuery : IRequest<ResultDto<PaginatedResult<ClientReviewDto>>>
{
    /// <summary>
    /// معرّف العقار المطلوب جلب مراجعاته.
    /// Identifier of the property whose reviews are requested.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// رقم الصفحة المراد إرجاعها.
    /// Page number to return.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// حجم الصفحة المراد إرجاعها.
    /// Page size to return.
    /// </summary>
    public int PageSize { get; set; } = 10;

    /// <summary>
    /// التقييم العام من 1 إلى 5.
    /// Overall rating from 1 to 5.
    /// </summary>
    public int? Rating { get; set; }

    /// <summary>
    /// الحقل المستخدم في الترتيب.
    /// Field used for sorting.
    /// </summary>
    public string SortBy { get; set; } = "CreatedAt";

    /// <summary>
    /// اتجاه الترتيب المطلوب.
    /// Requested sort direction.
    /// </summary>
    public string SortDirection { get; set; } = "Desc";

    /// <summary>
    /// إرجاع المراجعات التي تحتوي على صور فقط.
    /// Return only reviews that include images.
    /// </summary>
    public bool WithImagesOnly { get; set; } = false;

    /// <summary>
    /// معرّف المستخدم.
    /// Identifier of the user.
    /// </summary>
    public Guid? UserId { get; set; }
}

/// <summary>
/// بيانات المراجعة للعميل.
/// Client review data.
/// </summary>
public class ClientReviewDto
{
    /// <summary>
    /// معرّف الرد.
    /// Reply identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// معرّف المستخدم.
    /// Identifier of the user.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// معرّف الحجز المرتبط بالمراجعة.
    /// Identifier of the booking linked to the review.
    /// </summary>
    public Guid BookingId { get; set; }

    /// <summary>
    /// اسم العقار.
    /// Property name.
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;

    /// <summary>
    /// اسم المستخدم.
    /// User name.
    /// </summary>
    public string UserName { get; set; } = string.Empty;

    /// <summary>
    /// صورة المستخدم.
    /// User avatar.
    /// </summary>
    public string? UserAvatar { get; set; }

    /// <summary>
    /// التقييم العام من 1 إلى 5.
    /// Overall rating from 1 to 5.
    /// </summary>
    public int Rating { get; set; }

    /// <summary>
    /// تقييم النظافة.
    /// Cleanliness rating.
    /// </summary>
    public int Cleanliness { get; set; }

    /// <summary>
    /// تقييم الخدمة.
    /// Service rating.
    /// </summary>
    public int Service { get; set; }

    /// <summary>
    /// تقييم الموقع.
    /// Location rating.
    /// </summary>
    public int Location { get; set; }

    /// <summary>
    /// تقييم القيمة.
    /// Value rating.
    /// </summary>
    public int Value { get; set; }

    /// <summary>
    /// متوسط التقييم.
    /// Average rating.
    /// </summary>
    public decimal AverageRating { get; set; }

    /// <summary>
    /// عنوان المراجعة.
    /// Review title.
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// نص التعليق.
    /// Comment text.
    /// </summary>
    public string Comment { get; set; } = string.Empty;

    /// <summary>
    /// تاريخ الرد.
    /// Reply date.
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// نص رد الإدارة.
    /// Management response text.
    /// </summary>
    public string? ResponseText { get; set; }

    /// <summary>
    /// تاريخ رد الإدارة.
    /// Management response date.
    /// </summary>
    public DateTime? ResponseDate { get; set; }

    /// <summary>
    /// صور المراجعة.
    /// Review images.
    /// </summary>
    public List<ClientReviewImageDto> Images { get; set; } = new();

    /// <summary>
    /// يحدد ما إذا كانت هذه مراجعة المستخدم الحالي.
    /// Indicates whether this is the current user's review.
    /// </summary>
    public bool IsUserReview { get; set; }

    /// <summary>
    /// عدد الإعجابات.
    /// Likes count.
    /// </summary>
    public int LikesCount { get; set; }

    /// <summary>
    /// يحدد ما إذا كان المستخدم الحالي قد أعجبته هذه المراجعة.
    /// Indicates whether the current user liked this review.
    /// </summary>
    public bool IsLikedByUser { get; set; }

    /// <summary>
    /// رد إدارة العقار.
    /// Property management reply.
    /// </summary>
    public ClientReviewReplyDto? ManagementReply { get; set; }

    /// <summary>
    /// نوع الحجز المرتبط بالمراجعة.
    /// Booking type associated with the review.
    /// </summary>
    public string? BookingType { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المراجعة موصى بها.
    /// Indicates whether the review is recommended.
    /// </summary>
    public bool IsRecommended { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المراجعة قيد الاعتماد.
    /// Indicates whether the review is pending approval.
    /// </summary>
    public bool IsPendingApproval { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المراجعة معطّلة من الإدارة.
    /// Indicates whether the review is disabled by administrators.
    /// </summary>
    public bool IsDisabled { get; set; }
}

/// <summary>
/// بيانات صورة المراجعة
/// Review image data
/// </summary>
public class ClientReviewImageDto
{
    /// <summary>
    /// معرّف الرد.
    /// Reply identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// معرّف المراجعة المرتبطة بالصورة.
    /// Identifier of the review linked to the image.
    /// </summary>
    public Guid ReviewId { get; set; }

    /// <summary>
    /// اسم الملف.
    /// File name.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// رابط الصورة.
    /// Image URL.
    /// </summary>
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// رابط الصورة المصغرة.
    /// Thumbnail URL.
    /// </summary>
    public string ThumbnailUrl { get; set; } = string.Empty;

    /// <summary>
    /// التسمية التوضيحية.
    /// Caption.
    /// </summary>
    public string? Caption { get; set; }

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// حجم الملف بالبايت.
    /// File size in bytes.
    /// </summary>
    public long SizeBytes { get; set; }

    /// <summary>
    /// نوع الملف.
    /// File type.
    /// </summary>
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// فئة الصورة.
    /// Image category.
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// النص البديل.
    /// Alternative text.
    /// </summary>
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// تاريخ الرفع.
    /// Upload date.
    /// </summary>
    public DateTime UploadedAt { get; set; }
}

/// <summary>
/// بيانات رد إدارة العقار
/// Property management reply data
/// </summary>
public class ClientReviewReplyDto
{
    /// <summary>
    /// معرّف الرد.
    /// Reply identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// محتوى الرد.
    /// Reply content.
    /// </summary>
    public string Content { get; set; } = string.Empty;

    /// <summary>
    /// تاريخ الرد.
    /// Reply date.
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// اسم المرد.
    /// Replier name.
    /// </summary>
    public string ReplierName { get; set; } = string.Empty;

    /// <summary>
    /// منصب المرد.
    /// Replier position.
    /// </summary>
    public string ReplierPosition { get; set; } = string.Empty;
}