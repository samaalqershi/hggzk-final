using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reports.Commands.ManageReports
{
/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
    public class TakeReportActionCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف 
        /// Id identifier.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// يمثل الإجراء.
        /// Represents action.
        /// </summary>
        public string Action { get; set; } = string.Empty;

        /// <summary>
        /// يمثل ملاحظة الإجراء.
        /// Represents action note.
        /// </summary>
        public string? ActionNote { get; set; }

        /// <summary>
        /// معرّف المدير
        /// Admin ID identifier.
        /// </summary>
        public Guid AdminId { get; set; }
    }
} 