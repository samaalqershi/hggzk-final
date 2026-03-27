using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers.Images
{
    /// <summary>
    /// نموذج طلب لرفع صورة مع بيانات النموذج المرافقة.
    /// Request model for image uploads and related form data.
    /// </summary>
    public class UploadImageRequest
    {
        /// <summary>
        /// الملف المراد رفعه.
        /// File to upload.
        /// </summary>
        [FromForm(Name = "file")]
        public IFormFile File { get; set; } = null!;

        /// <summary>
        /// صورة مصغرة للفيديو يرسلها العميل عند الحاجة.
        /// Optional client-provided video thumbnail.
        /// </summary>
        [FromForm(Name = "videoThumbnail")]
        public IFormFile? VideoThumbnail { get; set; }

        /// <summary>
        /// المفتاح المؤقت المرتبط بالرفع.
        /// Temporary key for the upload.
        /// </summary>
        [FromForm(Name = "tempKey")]
        public string? TempKey { get; set; }

        /// <summary>
        /// فئة الصورة.
        /// Image category.
        /// </summary>
        [FromForm(Name = "category")]
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// معرف العقار.
        /// Property identifier.
        /// </summary>
        [FromForm(Name = "propertyId")]
        public string? PropertyId { get; set; }

        /// <summary>
        /// معرف الوحدة.
        /// Unit identifier.
        /// </summary>
        [FromForm(Name = "unitId")]
        public string? UnitId { get; set; }

        /// <summary>
        /// معرف القسم للربط المباشر مع كيان القسم.
        /// Section identifier for direct section linkage.
        /// </summary>
        [FromForm(Name = "sectionId")]
        public string? SectionId { get; set; }

        /// <summary>
        /// ربط الصورة بسجل عقار داخل قسم.
        /// Links the image to a property record in a section.
        /// </summary>
        [FromForm(Name = "propertyInSectionId")]
        public string? PropertyInSectionId { get; set; }

        /// <summary>
        /// ربط الصورة بسجل وحدة داخل قسم.
        /// Links the image to a unit record in a section.
        /// </summary>
        [FromForm(Name = "unitInSectionId")]
        public string? UnitInSectionId { get; set; }

        /// <summary>
        /// اسم المدينة.
        /// City name.
        /// </summary>
        [FromForm(Name = "cityName")]
        public string? CityName { get; set; }

        /// <summary>
        /// بديل لقبول cityId من التطبيق.
        /// Alias that maps cityId to the backend city name.
        /// </summary>
        [FromForm(Name = "cityId")]
        public string? CityId { get; set; }

        /// <summary>
        /// النص البديل للصورة.
        /// Alternative text for the image.
        /// </summary>
        [FromForm(Name = "alt")]
        public string? Alt { get; set; }

        /// <summary>
        /// سياق الحفظ.
        /// Save context.
        /// </summary>
        [FromForm(Name = "context")]
        public string? Context { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت الصورة رئيسية.
        /// Indicates whether the image is primary.
        /// </summary>
        [FromForm(Name = "isPrimary")]
        public bool? IsPrimary { get; set; }

        /// <summary>
        /// ترتيب الصورة.
        /// Image order.
        /// </summary>
        [FromForm(Name = "order")]
        public int? Order { get; set; }

        /// <summary>
        /// الوسوم المرتبطة بالصورة.
        /// Tags associated with the image.
        /// </summary>
        [FromForm(Name = "tags")]
        public string? Tags { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت الصورة 360 درجة.
        /// Indicates whether the image is 360-degree.
        /// </summary>
        [FromForm(Name = "is360")]
        public bool? Is360 { get; set; }
    }
} 
