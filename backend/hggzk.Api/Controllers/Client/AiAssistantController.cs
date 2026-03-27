using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Api.Services.AiAssistant;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client;

/// <summary>
/// واجهات المساعد الذكي الخاصة بالعميل.
/// Client-facing AI assistant endpoints.
/// </summary>
public sealed class AiAssistantController : BaseClientController
{
    /// <summary>
    /// خدمة المساعد الذكي المعتمدة.
    /// Backing AI assistant service.
    /// </summary>
    private readonly IAiAssistantService _aiAssistantService;

    /// <summary>
    /// يهيئ نسخة جديدة من [AiAssistantController].
    /// Initializes a new instance of [AiAssistantController].
    /// </summary>
    /// <param name="mediator">وسيط MediatR المستخدم داخل المتحكم. MediatR mediator used by the controller.</param>
    /// <param name="aiAssistantService">خدمة المساعد الذكي. AI assistant service.</param>
    public AiAssistantController(
        IMediator mediator,
        IAiAssistantService aiAssistantService) : base(mediator)
    {
        _aiAssistantService = aiAssistantService;
    }

    /// <summary>
    /// يعالج رسالة المستخدم ويعيد ردّ المساعد الذكي.
    /// Processes a user message and returns an AI response.
    /// </summary>
    [HttpPost("chat")]
    public async Task<ActionResult<ResultDto<AiAssistantChatResponse>>> Chat(
        [FromBody] AiAssistantChatRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _aiAssistantService.ChatAsync(request, cancellationToken);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// يبدأ محادثة جديدة مع الحفاظ على الذاكرة الطويلة للمستخدم.
    /// Starts a new conversation while preserving long-term profile memory.
    /// </summary>
    [HttpPost("reset")]
    public async Task<ActionResult<ResultDto<AiAssistantConversationResetResponse>>> ResetConversation(
        CancellationToken cancellationToken)
    {
        var result = await _aiAssistantService.ResetConversationAsync(cancellationToken);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }
}
