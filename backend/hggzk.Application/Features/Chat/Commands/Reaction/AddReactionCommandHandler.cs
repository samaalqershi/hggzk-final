using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;
using AutoMapper;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.Reaction
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class AddReactionCommandHandler : IRequestHandler<AddReactionCommand, ResultDto>
    {
        private readonly IMessageReactionRepository _reactionRepo;
        private readonly IChatMessageRepository _messageRepo;
        private readonly IChatConversationRepository _conversationRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IFirebaseService _firebaseService;
        private readonly IChatRealtimeNotifier _chatRealtimeNotifier;
        private readonly IMapper _mapper;
        private readonly ILogger<AddReactionCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public AddReactionCommandHandler(
            IMessageReactionRepository reactionRepo,
            IChatMessageRepository messageRepo,
            IChatConversationRepository conversationRepo,
            ICurrentUserService currentUserService,
            IFirebaseService firebaseService,
            IChatRealtimeNotifier chatRealtimeNotifier,
            IMapper mapper,
            ILogger<AddReactionCommandHandler> logger)
        {
            _reactionRepo = reactionRepo;
            _messageRepo = messageRepo;
            _conversationRepo = conversationRepo;
            _currentUserService = currentUserService;
            _firebaseService = firebaseService;
            _chatRealtimeNotifier = chatRealtimeNotifier;
            _mapper = mapper;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(AddReactionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var userId = _currentUserService.UserId;
                _logger.LogInformation("المستخدم {UserId} يضيف تفاعل {ReactionType} على الرسالة {MessageId}", userId, request.ReactionType, request.MessageId);

                // Rule: single reaction per user per message; clicking another reaction switches it,
                // clicking the same reaction toggles it off. Enforce atomically here.
                var existingReactions = await _reactionRepo
                    .FindAsync(r => r.MessageId == request.MessageId && r.UserId == userId, cancellationToken);

                var existing = existingReactions.FirstOrDefault();
                if (existing != null)
                {
                    if (string.Equals(existing.ReactionType, request.ReactionType, StringComparison.OrdinalIgnoreCase))
                    {
                        // Toggle off same reaction
                        await _reactionRepo.DeleteReactionAsync(existing, cancellationToken);
                        await _reactionRepo.SaveChangesAsync(cancellationToken);

                        // Notify removal via FCM
                        var chatMessage = await _messageRepo.GetByIdAsync(request.MessageId, cancellationToken);
                        var chatConversation = await _conversationRepo.GetByIdWithDetailsAsync(chatMessage.ConversationId, cancellationToken)
                                           ?? await _conversationRepo.GetByIdAsync(chatMessage.ConversationId, cancellationToken);
                        var dataRemoved = new System.Collections.Generic.Dictionary<string, string>
                        {
                            { "type", "reaction_removed" },
                            { "conversation_id", chatMessage.ConversationId.ToString() },
                            { "message_id", chatMessage.Id.ToString() },
                            { "user_id", userId.ToString() },
                            { "reaction_type", existing.ReactionType },
                            { "silent", "true" }
                        };
                        await _firebaseService.SendNotificationAsync($"user_{userId}", string.Empty, string.Empty, dataRemoved, cancellationToken);
                        foreach (var participant in chatConversation.Participants)
                        {
                            if (participant.Id == userId) continue;
                            await _firebaseService.SendNotificationAsync($"user_{participant.Id}", string.Empty, string.Empty, dataRemoved, cancellationToken);
                        }
                        await _chatRealtimeNotifier.NotifyReactionRemovedAsync(
                            chatMessage.ConversationId,
                            chatMessage.Id,
                            userId,
                            existing.ReactionType,
                            userId,
                            cancellationToken);
                        return ResultDto.Ok("تم إلغاء التفاعل");
                    }
                    else
                    {
                        // Switch reaction type
                        existing.ReactionType = request.ReactionType;
                        existing.UpdatedAt = DateTime.UtcNow;
                        await _reactionRepo.UpdateReactionAsync(existing, cancellationToken);
                        await _reactionRepo.SaveChangesAsync(cancellationToken);

                        var chatMessage = await _messageRepo.GetByIdAsync(request.MessageId, cancellationToken);
                        var chatConversation = await _conversationRepo.GetByIdWithDetailsAsync(chatMessage.ConversationId, cancellationToken)
                                           ?? await _conversationRepo.GetByIdAsync(chatMessage.ConversationId, cancellationToken);

                        var switchPayload = new System.Collections.Generic.Dictionary<string, string>
                        {
                            { "type", "reaction_added" },
                            { "conversation_id", chatMessage.ConversationId.ToString() },
                            { "message_id", chatMessage.Id.ToString() },
                            { "reaction_id", existing.Id.ToString() },
                            { "user_id", userId.ToString() },
                            { "reaction_type", existing.ReactionType },
                            { "silent", "true" }
                        };
                        await _firebaseService.SendNotificationAsync($"user_{userId}", string.Empty, string.Empty, switchPayload, cancellationToken);
                        foreach (var participant in chatConversation.Participants)
                        {
                            if (participant.Id == userId) continue;
                            await _firebaseService.SendNotificationAsync($"user_{participant.Id}", string.Empty, string.Empty, switchPayload, cancellationToken);
                        }
                        var switchedReactionDto = _mapper.Map<MessageReactionDto>(existing);
                        await _chatRealtimeNotifier.NotifyReactionAddedAsync(
                            chatMessage.ConversationId,
                            chatMessage.Id,
                            switchedReactionDto,
                            userId,
                            cancellationToken);
                        return ResultDto.Ok("تم تغيير التفاعل");
                    }
                }

                var reaction = new YemenBooking.Core.Entities.MessageReaction
                {
                    Id = Guid.NewGuid(),
                    MessageId = request.MessageId,
                    UserId = userId,
                    ReactionType = request.ReactionType,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _reactionRepo.AddReactionAsync(reaction, cancellationToken);
                await _reactionRepo.SaveChangesAsync(cancellationToken);

                // إشعار جميع المشاركين عبر FCM (بما فيهم المنفذ للعملية) مع بيانات كاملة صامتة لتحديث الواجهة فوراً
                var chatMessageFinal = await _messageRepo.GetByIdAsync(request.MessageId, cancellationToken);
                // Ensure participants are loaded to notify all reliably
                var chatConversationFinal = await _conversationRepo.GetByIdWithDetailsAsync(chatMessageFinal.ConversationId, cancellationToken) 
                                   ?? await _conversationRepo.GetByIdAsync(chatMessageFinal.ConversationId, cancellationToken);
                var reactionDto = _mapper.Map<MessageReactionDto>(reaction);

                var dataPayload = new System.Collections.Generic.Dictionary<string, string>
                {
                    { "type", "reaction_added" },
                    { "conversation_id", chatMessageFinal.ConversationId.ToString() },
                    { "message_id", chatMessageFinal.Id.ToString() },
                    { "reaction_id", reactionDto.Id.ToString() },
                    { "user_id", reactionDto.UserId.ToString() },
                    { "reaction_type", reactionDto.ReactionType },
                    { "silent", "true" }
                };

                // أرسل للمشارك المنفذ أيضاً لتحديث فوري بدون انتظار إعادة الجلب
                await _firebaseService.SendNotificationAsync($"user_{userId}", string.Empty, string.Empty, dataPayload, cancellationToken);

                foreach (var participant in chatConversationFinal.Participants)
                {
                    if (participant.Id == userId) continue; // تم الإرسال له أعلاه
                    await _firebaseService.SendNotificationAsync($"user_{participant.Id}", string.Empty, string.Empty, dataPayload, cancellationToken);
                }

                await _chatRealtimeNotifier.NotifyReactionAddedAsync(
                    chatMessageFinal.ConversationId,
                    chatMessageFinal.Id,
                    reactionDto,
                    userId,
                    cancellationToken);

                return ResultDto.Ok("تم إضافة التفاعل بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء إضافة التفاعل");
                return ResultDto.Failure("حدث خطأ أثناء إضافة التفاعل");
            }
        }
    }
} 
