using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Queries.GetUploadProgress
{
    /// <summary>
    /// يعالج أمر الحصول على تقدم الرفع.
    /// Handles the get upload progress command.
    /// </summary>
    public class GetUploadProgressQueryHandler : IRequestHandler<GetUploadProgressQuery, ResultDto<UploadProgressDto>>
    {
        private readonly ILogger<GetUploadProgressQueryHandler> _logger;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [GetUploadProgressQueryHandler].
        /// Initializes a new instance of [GetUploadProgressQueryHandler].
        /// </summary>
        public GetUploadProgressQueryHandler(ILogger<GetUploadProgressQueryHandler> logger)
        {
            _logger = logger;
        }
        /// <summary>
        /// يعالج استعلام تقدم الرفع ويعيد الحالة الحالية.
        /// Handles the upload progress query and returns the current status.
        /// </summary>
        public Task<ResultDto<UploadProgressDto>> Handle(GetUploadProgressQuery request, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(request.TaskId))
                return Task.FromResult(ResultDto<UploadProgressDto>.Failure("معرف المهمة مطلوب", "Task identifier is required", "TASK_ID_REQUIRED"));

            _logger.LogWarning("تم طلب تتبع تقدم رفع غير مدعوم حالياً لمعرف المهمة {TaskId}", request.TaskId);
            return Task.FromResult(ResultDto<UploadProgressDto>.Failure(
                "تتبع تقدم الرفع غير متاح حالياً",
                "Upload progress tracking is not supported yet",
                "UPLOAD_PROGRESS_NOT_SUPPORTED"));
        }
    }
}
