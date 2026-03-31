using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
 
 namespace YemenBooking.Application.Features.Chat.Commands.Message
 {
     /// <summary>
     /// يعالج الطلب ويطبق منطق التنفيذ.
     /// Processes the request and applies the execution logic.
     /// </summary>
     public class DeleteMessageCommandHandler : IRequestHandler<DeleteMessageCommand, ResultDto>
     {
        private readonly IChatMessageRepository _messageRepo;
        private readonly IChatConversationRepository _conversationRepo;
        private readonly IFirebaseService _firebaseService;
        private readonly IChatRealtimeNotifier _chatRealtimeNotifier;
        private readonly IChatSettingsRepository _chatSettingsRepository;
 
        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public DeleteMessageCommandHandler(
            IChatMessageRepository messageRepo,
            IChatConversationRepository conversationRepo,
            IFirebaseService firebaseService,
            IChatRealtimeNotifier chatRealtimeNotifier,
            IChatSettingsRepository chatSettingsRepository)
        {
            _messageRepo = messageRepo;
            _conversationRepo = conversationRepo;
            _firebaseService = firebaseService;
            _chatRealtimeNotifier = chatRealtimeNotifier;
            _chatSettingsRepository = chatSettingsRepository;
        }
 
    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(DeleteMessageCommand request, CancellationToken cancellationToken)
        {
            var message = await _messageRepo.GetByIdAsync(request.MessageId, cancellationToken);
            if (message == null)
                return ResultDto.Failed("الرسالة غير موجودة");

            await _messageRepo.DeleteMessageAsync(message, cancellationToken);
            await _messageRepo.SaveChangesAsync(cancellationToken);

            // إرسال إشعار حذف الرسالة عبر FCM
            var conversation = await _conversationRepo.GetByIdWithDetailsAsync(message.ConversationId, cancellationToken);
            if (conversation?.Participants != null)
            {
                foreach (var participant in conversation.Participants)
                {
                    var isSender = participant.Id == message.SenderId;
                    var participantSettings = await _chatSettingsRepository.GetByUserIdAsync(participant.Id, cancellationToken);
                    if (!isSender &&
                        !(participantSettings?.NotificationsEnabled ?? true))
                    {
                        continue;
                    }

                    var payload = new System.Collections.Generic.Dictionary<string, string>
                    {
                        { "type", "message_deleted" },
                        { "conversation_id", message.ConversationId.ToString() },
                        { "message_id", message.Id.ToString() },
                        { "silent", isSender ? "true" : "false" }
                    };

                    if (!isSender &&
                        !(participantSettings?.SoundEnabled ?? true))
                    {
                        payload["channel_id"] = "hggzk_chat_silent";
                        payload["sound_enabled"] = "false";
                    }

                    await _firebaseService.SendNotificationAsync(
                        $"user_{participant.Id}",
                        isSender ? string.Empty : "تم حذف رسالة",
                        string.Empty,
                        payload,
                        cancellationToken);
                }
            }

            await _chatRealtimeNotifier.NotifyMessageDeletedAsync(
                message.ConversationId,
                message.Id,
                message.SenderId,
                cancellationToken);
            await _chatRealtimeNotifier.NotifyConversationUpdatedAsync(
                message.ConversationId,
                "message_deleted",
                message.SenderId,
                cancellationToken);

            return ResultDto.Ok(null, "تم حذف الرسالة بنجاح");
        }
    }
} 
