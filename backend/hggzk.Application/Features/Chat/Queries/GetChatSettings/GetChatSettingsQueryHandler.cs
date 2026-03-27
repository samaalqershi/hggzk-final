using System.Threading;
using System.Threading.Tasks;
using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetChatSettings
{
    /// <summary>
    /// يعالج الاستعلام ويعيد النتائج المطلوبة.
    /// Processes the query and returns the requested data.
    /// </summary>
    public class GetChatSettingsQueryHandler : IRequestHandler<GetChatSettingsQuery, ResultDto<ChatSettingsDto>>
    {
        private readonly IChatSettingsRepository _settingsRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetChatSettingsQueryHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public GetChatSettingsQueryHandler(
            IChatSettingsRepository settingsRepo,
            ICurrentUserService currentUserService,
            IMapper mapper,
            ILogger<GetChatSettingsQueryHandler> logger)
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
        public async Task<ResultDto<ChatSettingsDto>> Handle(GetChatSettingsQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جلب إعدادات الشات للمستخدم {UserId}", _currentUserService.UserId);
            var userId = _currentUserService.UserId;
            var settings = await _settingsRepo.GetByUserIdAsync(userId, cancellationToken);
            if (settings == null)
                return ResultDto<ChatSettingsDto>.Failure("لم يتم العثور على إعدادات الشات", errorCode: "not_found");

            var dto = _mapper.Map<ChatSettingsDto>(settings);
            return ResultDto<ChatSettingsDto>.Ok(dto);
        }
    }
} 