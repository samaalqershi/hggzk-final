using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YemenBooking.Core.Entities
{
    /// <summary>
    /// يمثل بيانات تعريف فهرس واحد.
    /// Tracks metadata for a single index.
    /// </summary>
    [Table("IndexMetadata")]
    public class IndexMetadata
    {
        /// <summary>
        /// نوع الفهرس.
        /// Index type.
        /// </summary>
        [Key]
        [Required]
        [MaxLength(100)]
        public string IndexType { get; set; } = string.Empty;

        /// <summary>
        /// آخر وقت تحديث للفهرس.
        /// Last update time for the index.
        /// </summary>
        [Required]
        public DateTime LastUpdateTime { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// عدد السجلات في الفهرس.
        /// Total number of records in the index.
        /// </summary>
        [Required]
        public int TotalRecords { get; set; } = 0;

        /// <summary>
        /// آخر معرف تمت معالجته.
        /// Last processed entity ID.
        /// </summary>
        public Guid? LastProcessedId { get; set; }

        /// <summary>
        /// حالة الفهرس.
        /// Index status.
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Active";

        /// <summary>
        /// رقم الإصدار للتزامن.
        /// Version number for concurrency control.
        /// </summary>
        [Required]
        public long Version { get; set; } = 1;

        /// <summary>
        /// حجم الفهرس بالبايت.
        /// Index size in bytes.
        /// </summary>
        public long FileSizeBytes { get; set; } = 0;

        /// <summary>
        /// عدد العمليات منذ آخر تحسين.
        /// Number of operations since the last optimization.
        /// </summary>
        public int OperationsSinceOptimization { get; set; } = 0;

        /// <summary>
        /// آخر وقت تم فيه تحسين الفهرس.
        /// Last optimization time.
        /// </summary>
        public DateTime? LastOptimizationTime { get; set; }

        /// <summary>
        /// معلومات إضافية بصيغة JSON.
        /// Additional metadata in JSON.
        /// </summary>
        [MaxLength(2000)]
        public string? Metadata { get; set; }

        /// <summary>
        /// آخر رسالة خطأ، إن وجدت.
        /// Last error message, if any.
        /// </summary>
        [MaxLength(1000)]
        public string? LastErrorMessage { get; set; }

        /// <summary>
        /// عدد محاولات إعادة البناء.
        /// Number of rebuild attempts.
        /// </summary>
        public int RebuildAttempts { get; set; } = 0;

        /// <summary>
        /// تاريخ الإنشاء.
        /// Creation timestamp.
        /// </summary>
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// تاريخ آخر تعديل.
        /// Last update timestamp.
        /// </summary>
        [Required]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// يحدّث طابع التعديل ويرفع رقم الإصدار بعد أي تغيير منطقي على السجل.
        /// Refreshes the modification timestamp and increments the version after any meaningful record change.
        /// </summary>
        public void MarkAsUpdated()
        {
            UpdatedAt = DateTime.UtcNow;
            Version++;
        }

        /// <summary>
        /// يعلّم الفهرس على أنه نشط بعد نجاح البناء أو التحديث ويحدّث المقاييس الأساسية المرتبطة به.
        /// Marks the index as active after a successful build or refresh and updates its core metrics.
        /// </summary>
        public void MarkAsActive(int recordCount, long fileSize)
        {
            Status = "Active";
            TotalRecords = recordCount;
            FileSizeBytes = fileSize;
            LastErrorMessage = null;
            MarkAsUpdated();
        }

        /// <summary>
        /// يحدّث السجل بحالة خطأ مع حفظ الرسالة وزيادة عداد المحاولات.
        /// Updates the record to an error state while storing the message and incrementing the retry counter.
        /// </summary>
        public void MarkAsError(string errorMessage)
        {
            Status = "Error";
            LastErrorMessage = errorMessage;
            RebuildAttempts++;
            MarkAsUpdated();
        }

        /// <summary>
        /// يضع الفهرس في حالة البناء لإظهار أن عملية الإنشاء أو إعادة التوليد جارية.
        /// Places the index in a building state to signal that generation or regeneration is in progress.
        /// </summary>
        public void MarkAsBuilding()
        {
            Status = "Building";
            LastErrorMessage = null;
            MarkAsUpdated();
        }
    }
}
