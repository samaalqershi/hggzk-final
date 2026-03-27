using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Chat.Commands.Reaction
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class RemoveReactionCommandHandler : IRequestHandler<RemoveReactionCommand, ResultDto>
    {
        private readonly IMessageReactionRepository _reactionRepo;
        private readonly IChatMessageRepository _messageRepo;
        private readonly IChatConversationRepository _conversationRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IFirebaseService _firebaseService;
        private readonly ILogger<RemoveReactionCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public RemoveReactionCommandHandler(
            IMessageReactionRepository reactionRepo,
            IChatMessageRepository messageRepo,
            IChatConversationRepository conversationRepo,
            ICurrentUserService currentUserService,
            IFirebaseService firebaseService,
            ILogger<RemoveReactionCommandHandler> logger)
        {
            _reactionRepo = reactionRepo;
            _messageRepo = messageRepo;
            _conversationRepo = conversationRepo;
            _currentUserService = currentUserService;
            _firebaseService = firebaseService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(RemoveReactionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var userId = _currentUserService.UserId;
                _logger.LogInformation("المستخدم {UserId} يزيل تفاعل {ReactionType} من الرسالة {MessageId}", userId, request.ReactionType, request.MessageId);

                var reaction = (await _reactionRepo
                    .FindAsync(r => r.MessageId == request.MessageId && r.UserId == userId && r.ReactionType == request.ReactionType, cancellationToken))
                    .FirstOrDefault();
                if (reaction == null)
                    return ResultDto.Failure("التفاعل غير موجود");

                await _reactionRepo.DeleteReactionAsync(reaction, cancellationToken);
                await _reactionRepo.SaveChangesAsync(cancellationToken);

                // إشعار جميع المشاركين عبر FCM (بما فيهم المنفذ للعملية) صامتاً لتحديث الواجهة فوراً
                var message = await _messageRepo.GetByIdAsync(request.MessageId, cancellationToken);
                // Ensure participants are loaded to notify all reliably
                var conversation = await _conversationRepo.GetByIdWithDetailsAsync(message.ConversationId, cancellationToken)
                                   ?? await _conversationRepo.GetByIdAsync(message.ConversationId, cancellationToken);
                var dataPayload = new System.Collections.Generic.Dictionary<string, string>
                {
                    { "type", "reaction_removed" },
                    { "conversation_id", message.ConversationId.ToString() },
                    { "message_id", message.Id.ToString() },
                    { "user_id", userId.ToString() },
                    { "reaction_type", request.ReactionType },
                    { "silent", "true" }
                };

                await _firebaseService.SendNotificationAsync($"user_{userId}", string.Empty, string.Empty, dataPayload, cancellationToken);
                foreach (var participant in conversation.Participants)
                {
                    if (participant.Id == userId) continue;
                    await _firebaseService.SendNotificationAsync($"user_{participant.Id}", string.Empty, string.Empty, dataPayload, cancellationToken);
                }

                return ResultDto.Ok("تم إزالة التفاعل بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء إزالة التفاعل");
                return ResultDto.Failure("حدث خطأ أثناء إزالة التفاعل");
            }
        }
    }
} 
