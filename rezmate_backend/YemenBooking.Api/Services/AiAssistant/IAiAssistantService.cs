using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Services.AiAssistant;

public interface IAiAssistantService
{
    Task<ResultDto<AiAssistantChatResponse>> ChatAsync(
        AiAssistantChatRequest request,
        CancellationToken cancellationToken = default);

    Task<ResultDto<AiAssistantConversationResetResponse>> ResetConversationAsync(
        CancellationToken cancellationToken = default);
}
