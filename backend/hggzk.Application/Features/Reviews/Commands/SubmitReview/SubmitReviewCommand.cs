using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews;

namespace YemenBooking.Application.Features.Reviews.Commands.SubmitReview;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class SubmitReviewCommand : IRequest<ResultDto<SubmitReviewResponse>>
{
    /// <summary>
    /// معرّف الحجز المرتبط بالتقييم.
    /// Identifier of the booking linked to the review.
    /// </summary>
    public Guid BookingId { get; set; }
    
    /// <summary>
    /// معرّف العقار الذي تخصّه المراجعة.
    /// Identifier of the property being reviewed.
    /// </summary>
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// تقييم النظافة من 1 إلى 5.
    /// Cleanliness rating from 1 to 5.
    /// </summary>
    public int Cleanliness { get; set; }
    
    /// <summary>
    /// تقييم الخدمة من 1 إلى 5.
    /// Service rating from 1 to 5.
    /// </summary>
    public int Service { get; set; }
    
    /// <summary>
    /// تقييم الموقع من 1 إلى 5.
    /// Location rating from 1 to 5.
    /// </summary>
    public int Location { get; set; }
    
    /// <summary>
    /// تقييم القيمة من 1 إلى 5.
    /// Value rating from 1 to 5.
    /// </summary>
    public int Value { get; set; }
    
    /// <summary>
    /// تعليق المراجعة النصي.
    /// Review comment text.
    /// </summary>
    public string Comment { get; set; } = string.Empty;
    
    /// <summary>
    /// الصور المرفقة بصيغة Base64.
    /// Attached images encoded as Base64.
    /// </summary>
    public List<string> ImagesBase64 { get; set; } = new();
}

/// <summary>
/// استجابة إرسال المراجعة
/// </summary>
public class SubmitReviewResponse
{
    /// <summary>
    /// معرّف المراجعة التي تم إنشاؤها.
    /// Identifier of the created review.
    /// </summary>
    public Guid ReviewId { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كانت العملية قد نجحت.
    /// Indicates whether the operation succeeded.
    /// </summary>
    public bool Success { get; set; }
    
    /// <summary>
    /// رسالة النتيجة المرجعة.
    /// Result message returned to the caller.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}