using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Services.AiAssistant;

/// <summary>
/// يمثل عقد خدمة المساعد الذكي.
/// Represents the AI assistant service contract.
/// </summary>
public interface IAiAssistantService
{
    /// <summary>
    /// يعالج طلب محادثة ويعيد ردًا منظّمًا.
    /// Processes a chat request and returns a structured response.
    /// </summary>
    Task<ResultDto<AiAssistantChatResponse>> ChatAsync(
        AiAssistantChatRequest request,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يعيد ضبط المحادثة مع إمكانية الاحتفاظ بذاكرة الملف الشخصي.
    /// Resets the conversation while optionally preserving profile memory.
    /// </summary>
    Task<ResultDto<AiAssistantConversationResetResponse>> ResetConversationAsync(
        CancellationToken cancellationToken = default);
}
