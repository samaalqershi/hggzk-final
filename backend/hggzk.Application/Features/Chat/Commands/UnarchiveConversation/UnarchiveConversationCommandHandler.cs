using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using System.Text.Json;
using AutoMapper;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Chat.Commands.UnarchiveConversation
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class UnarchiveConversationCommandHandler : IRequestHandler<UnarchiveConversationCommand, ResultDto>
    {
        private readonly IChatConversationRepository _conversationRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly IFirebaseService _firebaseService;
        private readonly IChatSettingsRepository _chatSettingsRepository;
        private readonly ILogger<UnarchiveConversationCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public UnarchiveConversationCommandHandler(
            IChatConversationRepository conversationRepo,
            ICurrentUserService currentUserService,
            IMapper mapper,
            IFirebaseService firebaseService,
            IChatSettingsRepository chatSettingsRepository,
            ILogger<UnarchiveConversationCommandHandler> logger)
        {
            _conversationRepo = conversationRepo;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _firebaseService = firebaseService;
            _chatSettingsRepository = chatSettingsRepository;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(UnarchiveConversationCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var conversation = await _conversationRepo.GetByIdWithDetailsAsync(request.ConversationId, cancellationToken);
                if (conversation == null)
                    return ResultDto.Failure("المحادثة غير موجودة", errorCode: "conversation_not_found");

                conversation.IsArchived = false;
                await _conversationRepo.UpdateConversationAsync(conversation, cancellationToken);
                await _conversationRepo.SaveChangesAsync(cancellationToken);
                // إشعار المشاركين عبر FCM
                var userId = _currentUserService.UserId;
                foreach (var participant in conversation.Participants.Where(p => p.Id != userId))
                {
                    var participantSettings = await _chatSettingsRepository.GetByUserIdAsync(participant.Id, cancellationToken);
                    if (!(participantSettings?.NotificationsEnabled ?? true))
                    {
                        continue;
                    }

                    var payload = new System.Collections.Generic.Dictionary<string, string>
                    {
                        { "type", "conversation_updated" },
                        { "conversation_id", conversation.Id.ToString() }
                    };

                    if (!(participantSettings?.SoundEnabled ?? true))
                    {
                        payload["channel_id"] = "hggzk_chat_silent";
                        payload["sound_enabled"] = "false";
                    }

                    await _firebaseService.SendNotificationAsync(
                        $"user_{participant.Id}",
                        "تم تحديث المحادثة",
                        "تم إلغاء الأرشفة",
                        payload,
                        cancellationToken);
                }

                return ResultDto.Ok("تم إلغاء أرشفة المحادثة");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء إلغاء أرشفة المحادثة");
                return ResultDto.Failure("حدث خطأ أثناء إلغاء أرشفة المحادثة");
            }
        }
    }
} 
