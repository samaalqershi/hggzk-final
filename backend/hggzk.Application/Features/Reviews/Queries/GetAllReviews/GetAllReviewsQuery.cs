using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reviews.Queries.GetAllReviews
{
    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetAllReviewsQuery : IRequest<PaginatedResult<ReviewDto>>
    {
        /// <summary>
        /// حالة التقييم المراد تصفيته بها.
        /// Review status filter.
        /// </summary>
        public string? Status { get; set; }

        /// <summary>
        /// الحد الأدنى لمتوسط التقييم.
        /// Minimum average rating.
        /// </summary>
        public double? MinRating { get; set; }

        /// <summary>
        /// الحد الأقصى لمتوسط التقييم.
        /// Maximum average rating.
        /// </summary>
        public double? MaxRating { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت النتائج يجب أن تحتوي على صور.
        /// Indicates whether results must include images.
        /// </summary>
        public bool? HasImages { get; set; }

        /// <summary>
        /// تصفية النتائج حسب معرّف العقار.
        /// Filter results by property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// تصفية النتائج حسب معرّف المستخدم.
        /// Filter results by user identifier.
        /// </summary>
        public Guid? UserId { get; set; }

        /// <summary>
        /// تصفية النتائج حسب معرّف الوحدة.
        /// Filter results by unit identifier.
        /// </summary>
        public Guid? UnitId { get; set; }
        
        /// <summary>
        /// جلب التقييمات بعد تاريخ معين.
        /// Reviews created after the specified date.
        /// </summary>
        public DateTime? ReviewedAfter { get; set; }

        /// <summary>
        /// جلب التقييمات قبل تاريخ معين.
        /// Reviews created before the specified date.
        /// </summary>
        public DateTime? ReviewedBefore { get; set; }

        /// <summary>
        /// رقم الصفحة المراد إرجاعها.
        /// Page number to return.
        /// </summary>
        public int? PageNumber { get; set; }

        /// <summary>
        /// عدد العناصر في الصفحة الواحدة.
        /// Page size to return.
        /// </summary>
        public int? PageSize { get; set; }

        /// <summary>
        /// تضمين الإحصاءات المجمعة ضمن بيانات النتيجة.
        /// Includes aggregate statistics in the result metadata.
        /// </summary>
        public bool? IncludeStats { get; set; }
    }
} 