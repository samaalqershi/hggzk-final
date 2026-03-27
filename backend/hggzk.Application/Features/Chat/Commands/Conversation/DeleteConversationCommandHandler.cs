using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Chat.Commands.Conversation
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class DeleteConversationCommandHandler : IRequestHandler<DeleteConversationCommand, ResultDto>
    {
        private readonly IChatConversationRepository _conversationRepo;
        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public DeleteConversationCommandHandler(IChatConversationRepository conversationRepo)
        {
            _conversationRepo = conversationRepo;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(DeleteConversationCommand request, CancellationToken cancellationToken)
        {
            var conv = await _conversationRepo.GetByIdAsync(request.ConversationId);
            if (conv == null)
                return ResultDto.Failure("المحادثة غير موجودة");

            await _conversationRepo.DeleteConversationAsync(conv, cancellationToken);
            await _conversationRepo.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok(null, "تم حذف المحادثة بنجاح");
        }
    }
}
