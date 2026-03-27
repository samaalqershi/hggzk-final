using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetUploadProgress
{
    /// <summary>
    /// استعلام للحصول على تقدم الرفع الحالي.
    /// Query for retrieving the current upload progress.
    /// </summary>
    public class GetUploadProgressQuery : IRequest<ResultDto<UploadProgressDto>>
    {
        /// <summary>
        /// معرّف المهمة.
        /// task identifier.
        /// </summary>
        public string TaskId { get; set; } = string.Empty;
    }
} 
