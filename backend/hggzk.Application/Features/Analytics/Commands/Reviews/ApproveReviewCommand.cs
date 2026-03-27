using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Analytics.Commands.Reviews
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class ApproveReviewCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرف المراجعة
        /// Review identifier
        /// </summary>
        public Guid ReviewId { get; set; }

        /// <summary>
        /// معرف المسؤول
        /// Admin identifier
        /// </summary>
        public Guid AdminId { get; set; }

        /// <summary>
        /// يُهيِّئ هذا الأمر بالقيم الأساسية المطلوبة.
        /// Initializes this command with the required values.
        /// </summary>
        public ApproveReviewCommand(Guid reviewId, Guid adminId)
        {
            ReviewId = reviewId;
            AdminId = adminId;
        }
    }
} 