using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;
using System.Security.Claims;
using MediatR;
using YemenBooking.Application.Features.Notifications.Channels.Commands.CreateChannel;
using YemenBooking.Application.Features.Notifications.Channels.Commands.UpdateChannel;
using YemenBooking.Application.Features.Notifications.Channels.Commands.DeleteChannel;
using YemenBooking.Application.Features.Notifications.Channels.Commands.AddSubscribers;
using YemenBooking.Application.Features.Notifications.Channels.Commands.RemoveSubscribers;
using YemenBooking.Application.Features.Notifications.Channels.Commands.SendChannelNotification;
using YemenBooking.Application.Features.Notifications.Channels.Commands.UpdateUserSubscriptions;
using YemenBooking.Application.Features.Notifications.Channels.Queries.SearchChannels;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelById;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelSubscribers;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelHistory;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelsStatistics;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetUserChannels;
using YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelStatistics;

namespace YemenBooking.Api.Controllers.Admin;

/// <summary>
/// يوفّر إدارة قنوات الإشعارات من لوحة الإدارة.
/// Provides admin management for notification channels.
/// </summary>
[ApiController]
[Route("api/admin/notification-channels")]
[Authorize(Roles = "Admin,SuperAdmin")]
public class NotificationChannelsController : ControllerBase
{
    /// <summary>
    /// موزّع الأوامر والاستعلامات الخاص بالقنوات.
    /// Mediator used for channel operations.
    /// </summary>
    private readonly IMediator _mediator;
    /// <summary>
    /// مسجل الأحداث الخاص بالمتحكم.
    /// Logger used by the controller.
    /// </summary>
    private readonly ILogger<NotificationChannelsController> _logger;
    
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator والمسجل.
    /// Initializes the controller with Mediator and logger.
    /// </summary>
    public NotificationChannelsController(
        IMediator mediator,
        ILogger<NotificationChannelsController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }
    
    /// <summary>
    /// يجلب القنوات مع خيارات البحث والفلترة.
    /// Retrieves channels with search and filtering options.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetChannels(
        [FromQuery] string? search = null,
        [FromQuery] string? type = null,
        [FromQuery] bool? isActive = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var channels = await _mediator.Send(new SearchChannelsQuery
            {
                Search = search,
                Type = type,
                IsActive = isActive,
                Page = page,
                PageSize = pageSize
            });
                
            return Ok(new
            {
                success = true,
                data = channels,
                pagination = new
                {
                    page,
                    pageSize,
                    hasMore = channels.Count() == pageSize
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting channels");
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب القنوات" });
        }
    }
    
    /// <summary>
    /// يجلب قناة محددة مع إحصائياتها.
    /// Retrieves a specific channel together with its statistics.
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetChannel(Guid id)
    {
        try
        {
            var channel = await _mediator.Send(new GetChannelByIdQuery { ChannelId = id });
            if (channel == null)
            {
                return NotFound(new { success = false, message = "القناة غير موجودة" });
            }
            
            var statistics = await _mediator.Send(new GetChannelStatisticsQuery { ChannelId = id });
            
            return Ok(new
            {
                success = true,
                data = new
                {
                    channel,
                    statistics
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب القناة" });
        }
    }
    
    /// <summary>
    /// ينشئ قناة إشعارات جديدة.
    /// Creates a new notification channel.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateChannel([FromBody] CreateChannelRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { success = false, message = "البيانات غير صحيحة", errors = ModelState });
            }
            
            var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? Guid.Empty.ToString());
            
            var channel = await _mediator.Send(new CreateChannelCommand
            {
                Name = request.Name,
                Identifier = request.Identifier,
                Description = request.Description,
                Type = request.Type ?? "CUSTOM",
                Icon = request.Icon,
                Color = request.Color,
                CreatedBy = userId
            });
                
            return Ok(new
            {
                success = true,
                message = "تم إنشاء القناة بنجاح",
                data = channel
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating channel");
            return StatusCode(500, new { success = false, message = "حدث خطأ في إنشاء القناة" });
        }
    }
    
    /// <summary>
    /// يحدّث قناة إشعارات موجودة.
    /// Updates an existing notification channel.
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateChannel(Guid id, [FromBody] UpdateChannelRequest request)
    {
        try
        {
            var channel = await _mediator.Send(new UpdateChannelCommand
            {
                ChannelId = id,
                Name = request.Name,
                Description = request.Description,
                IsActive = request.IsActive,
                Icon = request.Icon,
                Color = request.Color
            });
                
            return Ok(new
            {
                success = true,
                message = "تم تحديث القناة بنجاح",
                data = channel
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { success = false, message = "القناة غير موجودة" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في تحديث القناة" });
        }
    }
    
    /// <summary>
    /// يحذف قناة إشعارات.
    /// Deletes a notification channel.
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteChannel(Guid id)
    {
        try
        {
            var result = await _mediator.Send(new DeleteChannelCommand { ChannelId = id });
            if (!result)
            {
                return NotFound(new { success = false, message = "القناة غير موجودة" });
            }
            
            return Ok(new
            {
                success = true,
                message = "تم حذف القناة بنجاح"
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في حذف القناة" });
        }
    }
    
    /// <summary>
    /// يجلب مشتركي القناة.
    /// Retrieves channel subscribers.
    /// </summary>
    [HttpGet("{id}/subscribers")]
    public async Task<IActionResult> GetChannelSubscribers(Guid id, [FromQuery] bool activeOnly = true)
    {
        try
        {
            var subscribers = await _mediator.Send(new GetChannelSubscribersQuery { ChannelId = id, ActiveOnly = activeOnly });
            
            return Ok(new
            {
                success = true,
                data = subscribers.Select(s => new
                {
                    s.Id,
                    s.UserId,
                    userName = s.User?.Name,
                    userEmail = s.User?.Email,
                    s.IsActive,
                    s.IsMuted,
                    s.SubscribedAt,
                    s.UnsubscribedAt,
                    s.NotificationsReceivedCount,
                    s.LastNotificationReceivedAt
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting channel subscribers");
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب المشتركين" });
        }
    }
    
    /// <summary>
    /// يضيف مستخدمين كمشتركين في القناة.
    /// Adds users as channel subscribers.
    /// </summary>
    [HttpPost("{id}/subscribers")]
    public async Task<IActionResult> AddSubscribers(Guid id, [FromBody] AddSubscribersRequest request)
    {
        try
        {
            var count = await _mediator.Send(new AddSubscribersCommand { ChannelId = id, UserIds = request.UserIds });
            
            return Ok(new
            {
                success = true,
                message = $"تم إضافة {count} مشترك بنجاح",
                data = new { addedCount = count }
            });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { success = false, message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding subscribers to channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في إضافة المشتركين" });
        }
    }
    
    /// <summary>
    /// يزيل مشتركين من القناة.
    /// Removes subscribers from the channel.
    /// </summary>
    [HttpDelete("{id}/subscribers")]
    public async Task<IActionResult> RemoveSubscribers(Guid id, [FromBody] RemoveSubscribersRequest request)
    {
        try
        {
            var count = await _mediator.Send(new RemoveSubscribersCommand { ChannelId = id, UserIds = request.UserIds });
            
            return Ok(new
            {
                success = true,
                message = $"تم إزالة {count} مشترك بنجاح",
                data = new { removedCount = count }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing subscribers from channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في إزالة المشتركين" });
        }
    }
    
    /// <summary>
    /// يرسل إشعارًا عبر القناة.
    /// Sends a notification through the channel.
    /// </summary>
    [HttpPost("{id}/send")]
    public async Task<IActionResult> SendChannelNotification(Guid id, [FromBody] SendChannelNotificationRequest request)
    {
        try
        {
            var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? Guid.Empty.ToString());
            
            var history = await _mediator.Send(new SendChannelNotificationCommand
            {
                ChannelId = id,
                Title = request.Title,
                Content = request.Content,
                Type = request.Type ?? "INFO",
                SenderId = userId,
                Data = request.Data
            });
                
            return Ok(new
            {
                success = true,
                message = "تم إرسال الإشعار بنجاح",
                data = new
                {
                    history.Id,
                    history.RecipientsCount,
                    history.SuccessfulDeliveries,
                    history.FailedDeliveries,
                    history.SentAt
                }
            });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { success = false, message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification to channel {ChannelId}", id);
            return StatusCode(500, new { success = false, message = "حدث خطأ في إرسال الإشعار" });
        }
    }
    
    /// <summary>
    /// يجلب سجل الإشعارات الخاص بالقناة.
    /// Retrieves the channel notification history.
    /// </summary>
    [HttpGet("{id}/history")]
    public async Task<IActionResult> GetChannelHistory(
        Guid id,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var history = await _mediator.Send(new GetChannelHistoryQuery { ChannelId = id, Page = page, PageSize = pageSize });
            
            return Ok(new
            {
                success = true,
                data = history,
                pagination = new
                {
                    page,
                    pageSize,
                    hasMore = history.Count() == pageSize
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting channel history");
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب السجل" });
        }
    }
    
    /// <summary>
    /// يجلب إحصائيات القنوات.
    /// Retrieves channel statistics.
    /// </summary>
    [HttpGet("statistics")]
    public async Task<IActionResult> GetStatistics()
    {
        try
        {
            var stats = await _mediator.Send(new GetChannelsStatisticsQuery());
            
            return Ok(new
            {
                success = true,
                data = stats
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting channels statistics");
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب الإحصائيات" });
        }
    }
    
    /// <summary>
    /// يجلب قنوات مستخدم محدد.
    /// Retrieves channels for a specific user.
    /// </summary>
    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserChannels(Guid userId)
    {
        try
        {
            var channels = await _mediator.Send(new GetUserChannelsQuery { UserId = userId, ActiveOnly = true });
            
            return Ok(new
            {
                success = true,
                data = channels
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user channels");
            return StatusCode(500, new { success = false, message = "حدث خطأ في جلب قنوات المستخدم" });
        }
    }
    
    /// <summary>
    /// يحدّث اشتراكات المستخدم في القنوات.
    /// Updates the user's channel subscriptions.
    /// </summary>
    [HttpPut("user/{userId}/subscriptions")]
    public async Task<IActionResult> UpdateUserSubscriptions(Guid userId, [FromBody] UpdateUserSubscriptionsRequest request)
    {
        try
        {
            // إضافة/إزالة الاشتراكات عبر CQRS
            await _mediator.Send(new UpdateUserSubscriptionsCommand
            {
                UserId = userId,
                ChannelsToAdd = request.ChannelsToAdd,
                ChannelsToRemove = request.ChannelsToRemove
            });
            
            // الحصول على القنوات المحدثة
            var channels = await _mediator.Send(new GetUserChannelsQuery { UserId = userId, ActiveOnly = false });
            
            return Ok(new
            {
                success = true,
                message = "تم تحديث اشتراكات المستخدم بنجاح",
                data = channels
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user subscriptions");
            return StatusCode(500, new { success = false, message = "حدث خطأ في تحديث الاشتراكات" });
        }
    }
}

#region Request Models

/// <summary>
/// يصف البيانات المطلوبة لإنشاء قناة.
/// Describes the payload required to create a channel.
/// </summary>
public class CreateChannelRequest
{
    /// <summary>
    /// اسم القناة.
    /// The channel name.
    /// </summary>
    public string Name { get; set; } = null!;
    /// <summary>
    /// المعرّف النصي الفريد للقناة.
    /// The channel's unique string identifier.
    /// </summary>
    public string Identifier { get; set; } = null!;
    /// <summary>
    /// وصف القناة.
    /// The channel description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// نوع القناة.
    /// The channel type.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// أيقونة القناة.
    /// The channel icon.
    /// </summary>
    public string? Icon { get; set; }
    /// <summary>
    /// لون القناة.
    /// The channel color.
    /// </summary>
    public string? Color { get; set; }
}

/// <summary>
/// يصف الحقول القابلة للتحديث في القناة.
/// Describes the fields that can be updated on a channel.
/// </summary>
public class UpdateChannelRequest
{
    /// <summary>
    /// اسم القناة الجديد.
    /// The updated channel name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// وصف القناة الجديد.
    /// The updated channel description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// حالة التفعيل الجديدة.
    /// The updated active state.
    /// </summary>
    public bool? IsActive { get; set; }
    /// <summary>
    /// الأيقونة الجديدة.
    /// The updated icon.
    /// </summary>
    public string? Icon { get; set; }
    /// <summary>
    /// اللون الجديد.
    /// The updated color.
    /// </summary>
    public string? Color { get; set; }
}

/// <summary>
/// يصف المستخدمين الذين سيُضافون إلى القناة.
/// Describes the users to add to the channel.
/// </summary>
public class AddSubscribersRequest
{
    /// <summary>
    /// قائمة معرّفات المستخدمين.
    /// The list of user identifiers.
    /// </summary>
    public List<Guid> UserIds { get; set; } = new();
}

/// <summary>
/// يصف المستخدمين الذين سيُزال اشتراكهم من القناة.
/// Describes the users to remove from the channel.
/// </summary>
public class RemoveSubscribersRequest
{
    /// <summary>
    /// قائمة معرّفات المستخدمين.
    /// The list of user identifiers.
    /// </summary>
    public List<Guid> UserIds { get; set; } = new();
}

/// <summary>
/// يصف بيانات الإشعار المرسل عبر القناة.
/// Describes the notification payload sent through the channel.
/// </summary>
public class SendChannelNotificationRequest
{
    /// <summary>
    /// عنوان الإشعار.
    /// The notification title.
    /// </summary>
    public string Title { get; set; } = null!;
    /// <summary>
    /// محتوى الإشعار.
    /// The notification content.
    /// </summary>
    public string Content { get; set; } = null!;
    /// <summary>
    /// نوع الإشعار.
    /// The notification type.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// بيانات إضافية مرفقة بالإشعار.
    /// Additional notification data.
    /// </summary>
    public Dictionary<string, string>? Data { get; set; }
}

/// <summary>
/// يصف القنوات المراد إضافتها أو إزالتها من اشتراكات المستخدم.
/// Describes the channels to add to or remove from a user's subscriptions.
/// </summary>
public class UpdateUserSubscriptionsRequest
{
    /// <summary>
    /// القنوات المطلوب إضافتها.
    /// Channels to add.
    /// </summary>
    public List<Guid>? ChannelsToAdd { get; set; }
    /// <summary>
    /// القنوات المطلوب إزالتها.
    /// Channels to remove.
    /// </summary>
    public List<Guid>? ChannelsToRemove { get; set; }
}

#endregion
