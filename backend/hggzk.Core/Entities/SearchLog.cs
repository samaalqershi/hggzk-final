using System;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities
{
    /// <summary>
    /// يسجل عملية بحث واحدة نفذها مستخدم داخل النظام.
    /// Records a single search action performed by a user in the system.
    /// </summary>
    [Display(Name = "سجل عمليات البحث من قبل المستخدمين")]
    public class SearchLog : BaseEntity<Guid>
    {
        /// <summary>
        /// معرّف المستخدم الذي نفذ عملية البحث.
        /// Identifies the user who performed the search.
        /// </summary>
        [Display(Name = "معرف المستخدم الذي قام بالبحث")]
        public Guid UserId { get; set; }

        /// <summary>
        /// نوع الكيان الذي نُفذت عليه عملية البحث، مثل Property أو Unit.
        /// The target entity searched, such as Property or Unit.
        /// </summary>
        [Display(Name = "نوع البحث")]
        public string SearchType { get; set; } = string.Empty;

        /// <summary>
        /// معايير البحث والفلترة كما تم تمريرها، محفوظة بصيغة JSON.
        /// The submitted search and filter criteria, stored as JSON.
        /// </summary>
        [Display(Name = "معايير البحث والفلترة")]
        public string CriteriaJson { get; set; } = "{}";

        /// <summary>
        /// عدد النتائج التي أرجعها البحث.
        /// The number of results returned by the search.
        /// </summary>
        [Display(Name = "عدد النتائج المرجعة")]
        public int ResultCount { get; set; }

        /// <summary>
        /// رقم الصفحة المطلوبة ضمن نتائج البحث.
        /// The requested page number within the search results.
        /// </summary>
        [Display(Name = "رقم الصفحة")]
        public int PageNumber { get; set; }

        /// <summary>
        /// عدد العناصر في الصفحة الواحدة.
        /// The number of items per page.
        /// </summary>
        [Display(Name = "حجم الصفحة")]
        public int PageSize { get; set; }
    }
} 
