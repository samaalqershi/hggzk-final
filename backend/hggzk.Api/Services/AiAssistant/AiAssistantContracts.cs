using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Api.Services.AiAssistant;

/// <summary>
/// يمثل طلب محادثة موجهًا إلى المساعد الذكي.
/// Represents a chat request sent to the AI assistant.
/// </summary>
public sealed class AiAssistantChatRequest
{
    /// <summary>
    /// نص الرسالة الأساسية المرسلة إلى المساعد.
    /// Primary message text sent to the assistant.
    /// </summary>
    [Required]
    [MaxLength(2000)]
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// سجل الرسائل السابقة المستخدم كسياق.
    /// Previous conversation history used as context.
    /// </summary>
    public List<AiAssistantHistoryMessage>? History { get; set; }

    /// <summary>
    /// اللغة أو الإعداد المحلي المطلوب للرد.
    /// Requested locale for the response.
    /// </summary>
    public string? Locale { get; set; }

    /// <summary>
    /// المنطقة الزمنية المرتبطة بالطلب الحالي.
    /// Time zone associated with the current request.
    /// </summary>
    public string? TimeZone { get; set; }

    /// <summary>
    /// يحدد ما إذا كان يجب التعامل مع الطلب كموضوع جديد.
    /// Indicates whether the current request should be treated as a new topic.
    /// </summary>
    public bool StartFresh { get; set; }
}

/// <summary>
/// يمثل رسالة سابقة ضمن سجل المحادثة.
/// Represents a previous message in the conversation history.
/// </summary>
public sealed class AiAssistantHistoryMessage
{
    /// <summary>
    /// دور المرسل في الرسالة السابقة.
    /// Sender role for the previous message.
    /// </summary>
    public string Role { get; set; } = "user";

    /// <summary>
    /// محتوى الرسالة السابقة.
    /// Content of the previous message.
    /// </summary>
    public string Content { get; set; } = string.Empty;
}

/// <summary>
/// يمثل نتيجة تنفيذ أداة داخل دورة المحادثة.
/// Represents the result of a tool execution within the conversation flow.
/// </summary>
public sealed class AiAssistantToolExecution
{
    /// <summary>
    /// اسم الأداة التي تم تنفيذها.
    /// Name of the executed tool.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كان التنفيذ قد نجح.
    /// Indicates whether the execution succeeded.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// ملخص موجز لنتيجة التنفيذ.
    /// Short summary of the execution result.
    /// </summary>
    public string Summary { get; set; } = string.Empty;
}

/// <summary>
/// يمثل الرد النهائي الصادر عن المساعد.
/// Represents the final response returned by the assistant.
/// </summary>
public sealed class AiAssistantChatResponse
{
    /// <summary>
    /// نص الرد النهائي.
    /// Final reply text.
    /// </summary>
    public string Reply { get; set; } = string.Empty;

    /// <summary>
    /// اسم النموذج المستخدم في توليد الرد.
    /// Model name used to generate the response.
    /// </summary>
    public string Model { get; set; } = string.Empty;

    /// <summary>
    /// نتائج تنفيذ الأدوات المرتبطة بالرد.
    /// Tool execution results associated with the response.
    /// </summary>
    public List<AiAssistantToolExecution> ToolExecutions { get; set; } = new();

    /// <summary>
    /// البطاقات المنسقة المعروضة للمستخدم.
    /// Structured cards presented to the user.
    /// </summary>
    public List<AiAssistantResultCard> Cards { get; set; } = new();
}

/// <summary>
/// يمثل نتيجة إعادة ضبط المحادثة.
/// Represents the result of resetting the conversation state.
/// </summary>
public sealed class AiAssistantConversationResetResponse
{
    /// <summary>
    /// وقت تنفيذ إعادة الضبط بتوقيت UTC.
    /// UTC time when the reset was performed.
    /// </summary>
    public DateTime ResetAtUtc { get; set; }

    /// <summary>
    /// يحدد ما إذا تم الاحتفاظ بذاكرة الملف الشخصي.
    /// Indicates whether profile memory was preserved.
    /// </summary>
    public bool PreservedProfileMemory { get; set; } = true;
}

/// <summary>
/// يمثل بطاقة نتيجة منسقة يعرضها المساعد.
/// Represents a structured result card returned by the assistant.
/// </summary>
public sealed class AiAssistantResultCard
{
    /// <summary>
    /// نوع البطاقة، مثل عقار أو وحدة.
    /// Card type, such as property or unit.
    /// </summary>
    public string Type { get; set; } = "property";

    /// <summary>
    /// معرّف العقار المرتبط بالبطاقة.
    /// Identifier of the property linked to the card.
    /// </summary>
    public string PropertyId { get; set; } = string.Empty;

    /// <summary>
    /// معرّف الوحدة المرتبطة بالبطاقة.
    /// Identifier of the unit linked to the card.
    /// </summary>
    public string? UnitId { get; set; }

    /// <summary>
    /// العنوان الرئيسي للبطاقة.
    /// Primary title of the card.
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// العنوان الفرعي للبطاقة.
    /// Secondary title of the card.
    /// </summary>
    public string Subtitle { get; set; } = string.Empty;

    /// <summary>
    /// اسم المدينة المرتبطة بالبطاقة.
    /// City name associated with the card.
    /// </summary>
    public string City { get; set; } = string.Empty;

    /// <summary>
    /// رابط الصورة الرئيسية للبطاقة.
    /// Primary image URL for the card.
    /// </summary>
    public string? ImageUrl { get; set; }

    /// <summary>
    /// السعر المعروض في البطاقة.
    /// Price shown on the card.
    /// </summary>
    public decimal? Price { get; set; }

    /// <summary>
    /// رمز العملة المستخدم في السعر.
    /// Currency code used for the price.
    /// </summary>
    public string? Currency { get; set; }

    /// <summary>
    /// الشارة المختصرة المعروضة على البطاقة.
    /// Short badge shown on the card.
    /// </summary>
    public string? Badge { get; set; }

    /// <summary>
    /// بيانات وصفية اختيارية لعرض البطاقة بشكل أغنى.
    /// Optional metadata used for richer card rendering.
    /// </summary>
    public Dictionary<string, object?>? Metadata { get; set; }
}
