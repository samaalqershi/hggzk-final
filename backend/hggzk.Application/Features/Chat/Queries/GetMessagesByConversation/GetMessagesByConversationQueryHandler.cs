using System;
using System.Linq;
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

namespace YemenBooking.Application.Features.Chat.Queries.GetMessagesByConversation
{
    /// <summary>
    /// يعالج الاستعلام ويعيد النتائج المطلوبة.
    /// Processes the query and returns the requested data.
    /// </summary>
    public class GetMessagesByConversationQueryHandler : IRequestHandler<GetMessagesByConversationQuery, PaginatedResult<ChatMessageDto>>
    {
        private readonly IChatMessageRepository _messageRepo;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<GetMessagesByConversationQueryHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public GetMessagesByConversationQueryHandler(
            IChatMessageRepository messageRepo,
            IMapper mapper,
            ILogger<GetMessagesByConversationQueryHandler> logger,
            ICurrentUserService currentUserService)
        {
            _messageRepo = messageRepo;
            _mapper = mapper;
            _logger = logger;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<PaginatedResult<ChatMessageDto>> Handle(GetMessagesByConversationQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جلب الرسائل للمحادثة {ConversationId}", request.ConversationId);
            var beforeId = request.BeforeMessageId?.ToString();
            var (items, total) = await _messageRepo.GetMessagesByConversationAsync(request.ConversationId, request.PageNumber, request.PageSize, beforeId, cancellationToken);
            var dtos = _mapper.Map<IEnumerable<ChatMessageDto>>(items).ToList();
            for (int i = 0; i < dtos.Count; i++)
            {
                dtos[i].Attachments = dtos[i].Attachments
                    .GroupBy(att => att.Id)
                    .Select(group => group.First())
                    .ToList();

                dtos[i].CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dtos[i].CreatedAt);
                dtos[i].UpdatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dtos[i].UpdatedAt);
                if (dtos[i].EditedAt.HasValue)
                    dtos[i].EditedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dtos[i].EditedAt.Value);
                if (dtos[i].DeliveryReceipt != null)
                {
                    if (dtos[i].DeliveryReceipt.DeliveredAt.HasValue)
                        dtos[i].DeliveryReceipt.DeliveredAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dtos[i].DeliveryReceipt.DeliveredAt.Value);
                    if (dtos[i].DeliveryReceipt.ReadAt.HasValue)
                        dtos[i].DeliveryReceipt.ReadAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dtos[i].DeliveryReceipt.ReadAt.Value);
                }
            }
            return PaginatedResult<ChatMessageDto>.Create(dtos, request.PageNumber, request.PageSize, total);
        }
    }
} 
