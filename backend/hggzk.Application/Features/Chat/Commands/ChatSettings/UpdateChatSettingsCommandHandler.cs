using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using AutoMapper;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.ChatSettings
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class UpdateChatSettingsCommandHandler : IRequestHandler<UpdateChatSettingsCommand, ResultDto<ChatSettingsDto>>
    {
        private readonly IChatSettingsRepository _settingsRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<UpdateChatSettingsCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public UpdateChatSettingsCommandHandler(
            IChatSettingsRepository settingsRepo,
            ICurrentUserService currentUserService,
            IMapper mapper,
            ILogger<UpdateChatSettingsCommandHandler> logger)
        {
            _settingsRepo = settingsRepo;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<ChatSettingsDto>> Handle(UpdateChatSettingsCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var userId = _currentUserService.UserId;
                _logger.LogInformation("تحديث إعدادات الشات للمستخدم {UserId}", userId);

                var settings = await _settingsRepo.GetByUserIdAsync(userId, cancellationToken)
                    ?? new YemenBooking.Core.Entities.ChatSettings { UserId = userId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow };

                if (request.NotificationsEnabled.HasValue)
                    settings.NotificationsEnabled = request.NotificationsEnabled!.Value;
                if (request.SoundEnabled.HasValue)
                    settings.SoundEnabled = request.SoundEnabled!.Value;
                if (request.ShowReadReceipts.HasValue)
                    settings.ShowReadReceipts = request.ShowReadReceipts!.Value;
                if (request.ShowTypingIndicator.HasValue)
                    settings.ShowTypingIndicator = request.ShowTypingIndicator!.Value;
                if (!string.IsNullOrWhiteSpace(request.Theme))
                    settings.Theme = request.Theme!;
                if (!string.IsNullOrWhiteSpace(request.FontSize))
                    settings.FontSize = request.FontSize!;
                if (request.AutoDownloadMedia.HasValue)
                    settings.AutoDownloadMedia = request.AutoDownloadMedia!.Value;
                if (request.BackupMessages.HasValue)
                    settings.BackupMessages = request.BackupMessages!.Value;
                settings.UpdatedAt = DateTime.UtcNow;

                await _settingsRepo.SaveSettingsAsync(settings, cancellationToken);
                await _settingsRepo.SaveChangesAsync(cancellationToken);

                var dto = _mapper.Map<ChatSettingsDto>(settings);
                return ResultDto<ChatSettingsDto>.Ok(dto, "تم تحديث إعدادات الشات بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء تحديث إعدادات الشات");
                return ResultDto<ChatSettingsDto>.Failed("حدث خطأ أثناء تحديث الإعدادات");
            }
        }
    }
} 
