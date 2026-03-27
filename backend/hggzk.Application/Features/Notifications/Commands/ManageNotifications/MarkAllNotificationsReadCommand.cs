using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class MarkAllNotificationsReadCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف Recipient.
    /// Recipient identifier.
    /// </summary>
    public Guid RecipientId { get; set; }
} 