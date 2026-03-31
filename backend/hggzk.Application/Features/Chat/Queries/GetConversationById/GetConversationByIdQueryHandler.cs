using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using MediatR;
using AutoMapper;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetConversationById
{
    /// <summary>
    /// يعالج الاستعلام ويعيد النتائج المطلوبة.
    /// Processes the query and returns the requested data.
    /// </summary>
    public class GetConversationByIdQueryHandler : IRequestHandler<GetConversationByIdQuery, ResultDto<ChatConversationDto>>
    {
        private readonly IChatConversationRepository _repository;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public GetConversationByIdQueryHandler(IChatConversationRepository repository, IMapper mapper, ICurrentUserService currentUserService)
        {
            _repository = repository;
            _mapper = mapper;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<ChatConversationDto>> Handle(GetConversationByIdQuery request, CancellationToken cancellationToken)
        {
            // Load with details to include participants and messages for accurate lastMessage/updatedAt
            var conv = await _repository.GetByIdWithDetailsAsync(request.ConversationId, cancellationToken);
            if (conv == null)
                return ResultDto<ChatConversationDto>.Failure("المحادثة غير موجودة");

            var dto = _mapper.Map<ChatConversationDto>(conv);
            var currentUserId = _currentUserService.UserId;
            dto.UnreadCount = conv.Messages
                .Where(m => m.SenderId != currentUserId)
                .Count(m =>
                    !string.Equals(m.Status, "read", System.StringComparison.OrdinalIgnoreCase) &&
                    !m.ReadAt.HasValue);
            dto.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.CreatedAt);
            dto.UpdatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.UpdatedAt);
            if (dto.LastMessage != null)
            {
                dto.LastMessage.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessage.CreatedAt);
                dto.LastMessage.UpdatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessage.UpdatedAt);
                if (dto.LastMessage.EditedAt.HasValue)
                    dto.LastMessage.EditedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessage.EditedAt.Value);
                if (dto.LastMessage.DeliveryReceipt != null)
                {
                    if (dto.LastMessage.DeliveryReceipt.DeliveredAt.HasValue)
                        dto.LastMessage.DeliveryReceipt.DeliveredAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessage.DeliveryReceipt.DeliveredAt.Value);
                    if (dto.LastMessage.DeliveryReceipt.ReadAt.HasValue)
                        dto.LastMessage.DeliveryReceipt.ReadAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessage.DeliveryReceipt.ReadAt.Value);
                }
            }
            if (dto.LastMessageTime.HasValue)
                dto.LastMessageTime = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.LastMessageTime.Value);
            return ResultDto<ChatConversationDto>.Ok(dto);
        }
    }
} 
