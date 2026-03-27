using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// تنزيل مرفقات المحادثة بشكل آمن بعد التحقق من الصلاحية.
    /// Secure chat attachment downloads with access checks.
    /// </summary>
    [ApiController]
    [Authorize]
    [Route("api/common/chat/attachments")]
    public class ChatAttachmentController : ControllerBase
    {
        /// <summary>
        /// مستودع المرفقات.
        /// Attachment repository.
        /// </summary>
        private readonly IChatAttachmentRepository _attachmentRepo;
        /// <summary>
        /// مستودع المحادثات.
        /// Conversation repository.
        /// </summary>
        private readonly IChatConversationRepository _conversationRepo;
        /// <summary>
        /// خدمة المستخدم الحالي.
        /// Current user service.
        /// </summary>
        private readonly ICurrentUserService _currentUserService;
        /// <summary>
        /// مسجل الأحداث.
        /// Logger instance.
        /// </summary>
        private readonly ILogger<ChatAttachmentController> _logger;

        /// <summary>
        /// ينشئ متحكم تنزيل المرفقات مع الاعتماديات المطلوبة.
        /// Creates the attachment download controller with its dependencies.
        /// </summary>
        public ChatAttachmentController(
            IChatAttachmentRepository attachmentRepo,
            IChatConversationRepository conversationRepo,
            ICurrentUserService currentUserService,
            ILogger<ChatAttachmentController> logger)
        {
            _attachmentRepo = attachmentRepo;
            _conversationRepo = conversationRepo;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        /// <summary>
        /// ينزل مرفق المحادثة بعد التأكد من صلاحية المستخدم.
        /// Downloads a chat attachment after verifying user access.
        /// </summary>
        [HttpGet("{attachmentId}")]
        public async Task<IActionResult> DownloadAsync(Guid attachmentId)
        {
            var userId = _currentUserService.UserId;
            var attachment = await _attachmentRepo.GetByIdAsync(attachmentId);
            if (attachment == null)
                return NotFound();

            // تحقق من كون المستخدم مشاركاً في المحادثة
            var conv = await _conversationRepo.GetByIdWithParticipantsAsync(attachment.ConversationId);
            if (conv == null || !conv.Participants.Any(p => p.Id == userId))
                return Forbid();

            var filePath = attachment.FilePath;
            if (!System.IO.File.Exists(filePath))
                return NotFound();

            var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read);
            _logger.LogInformation("User {UserId} downloaded attachment {AttachmentId}", userId, attachmentId);
            var contentType = attachment.ContentType;
            if (string.IsNullOrWhiteSpace(contentType) || string.Equals(contentType, "application/octet-stream", StringComparison.OrdinalIgnoreCase))
            {
                var ext = Path.GetExtension(attachment.FileName)?.ToLowerInvariant();
                contentType = ext switch
                {
                    ".jpg" => "image/jpeg",
                    ".jpeg" => "image/jpeg",
                    ".png" => "image/png",
                    ".webp" => "image/webp",
                    ".gif" => "image/gif",
                    ".heic" => "image/heic",
                    ".m4a" => "audio/mp4",
                    ".aac" => "audio/aac",
                    ".mp3" => "audio/mpeg",
                    ".wav" => "audio/wav",
                    ".ogg" => "audio/ogg",
                    ".opus" => "audio/opus",
                    ".mp4" => "video/mp4",
                    ".mov" => "video/quicktime",
                    ".webm" => "video/webm",
                    ".mkv" => "video/x-matroska",
                    _ => attachment.ContentType ?? "application/octet-stream"
                };
            }
            return File(fileStream, contentType, enableRangeProcessing: true);
        }
    }
} 
