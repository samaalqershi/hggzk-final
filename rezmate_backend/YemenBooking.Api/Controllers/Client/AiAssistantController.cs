using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Api.Services.AiAssistant;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client;

/// <summary>
/// AI assistant endpoints for client app.
/// </summary>
public sealed class AiAssistantController : BaseClientController
{
    private readonly IAiAssistantService _aiAssistantService;

    public AiAssistantController(
        IMediator mediator,
        IAiAssistantService aiAssistantService) : base(mediator)
    {
        _aiAssistantService = aiAssistantService;
    }

    /// <summary>
    /// Process a user message and return an AI response.
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
    /// Start a new conversation thread while preserving long-term profile memory.
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
