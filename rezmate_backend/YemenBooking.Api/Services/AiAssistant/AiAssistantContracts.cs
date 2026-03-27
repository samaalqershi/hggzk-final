using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Api.Services.AiAssistant;

public sealed class AiAssistantChatRequest
{
    [Required]
    [MaxLength(2000)]
    public string Message { get; set; } = string.Empty;

    public List<AiAssistantHistoryMessage>? History { get; set; }

    public string? Locale { get; set; }

    public string? TimeZone { get; set; }

    /// <summary>
    /// When true, instructs assistant to treat current request as a new topic.
    /// </summary>
    public bool StartFresh { get; set; }
}

public sealed class AiAssistantHistoryMessage
{
    public string Role { get; set; } = "user";

    public string Content { get; set; } = string.Empty;
}

public sealed class AiAssistantToolExecution
{
    public string Name { get; set; } = string.Empty;

    public bool Success { get; set; }

    public string Summary { get; set; } = string.Empty;
}

public sealed class AiAssistantChatResponse
{
    public string Reply { get; set; } = string.Empty;

    public string Model { get; set; } = string.Empty;

    public List<AiAssistantToolExecution> ToolExecutions { get; set; } = new();

    public List<AiAssistantResultCard> Cards { get; set; } = new();
}

public sealed class AiAssistantConversationResetResponse
{
    public DateTime ResetAtUtc { get; set; }

    public bool PreservedProfileMemory { get; set; } = true;
}

public sealed class AiAssistantResultCard
{
    /// <summary>
    /// `property` or `unit`.
    /// </summary>
    public string Type { get; set; } = "property";

    public string PropertyId { get; set; } = string.Empty;

    public string? UnitId { get; set; }

    public string Title { get; set; } = string.Empty;

    public string Subtitle { get; set; } = string.Empty;

    public string City { get; set; } = string.Empty;

    public string? ImageUrl { get; set; }

    public decimal? Price { get; set; }

    public string? Currency { get; set; }

    public string? Badge { get; set; }

    /// <summary>
    /// Optional metadata for rich card rendering (for example review summary details).
    /// </summary>
    public Dictionary<string, object?>? Metadata { get; set; }
}
