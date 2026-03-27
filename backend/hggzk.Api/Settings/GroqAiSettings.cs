namespace YemenBooking.Api.Settings;

/// <summary>
/// Settings used to call Groq Chat Completions API.
/// </summary>
public sealed class GroqAiSettings
{
    /// <summary>
    /// خاصية BaseUrl.
    /// BaseUrl property.
    /// </summary>
    public string BaseUrl { get; set; } = "https://api.groq.com";

    /// <summary>
    /// خاصية ApiKey.
    /// ApiKey property.
    /// </summary>
    public string ApiKey { get; set; } = string.Empty;

    /// <summary>
    /// خاصية Model.
    /// Model property.
    /// </summary>
    public string Model { get; set; } = "llama-3.1-8b-instant";

    /// <summary>
    /// خاصية Temperature.
    /// Temperature property.
    /// </summary>
    public double Temperature { get; set; } = 0.2;

    /// <summary>
    /// خاصية MaxTokens.
    /// MaxTokens property.
    /// </summary>
    public int MaxTokens { get; set; } = 1200;

    /// <summary>
    /// خاصية MaxHistoryMessages.
    /// MaxHistoryMessages property.
    /// </summary>
    public int MaxHistoryMessages { get; set; } = 16;

    /// <summary>
    /// خاصية MaxToolIterations.
    /// MaxToolIterations property.
    /// </summary>
    public int MaxToolIterations { get; set; } = 4;

    /// <summary>
    /// HTTP timeout (seconds) when calling Groq provider.
    /// </summary>
    public int HttpTimeoutSeconds { get; set; } = 1800;

    /// <summary>
    /// Max number of recent bookings included in AI context snapshot.
    /// </summary>
    public int ContextBookingsLimit { get; set; } = 6;

    /// <summary>
    /// Max number of dynamic preference pairs included in AI context snapshot.
    /// </summary>
    public int ContextDynamicPreferencesLimit { get; set; } = 12;

    /// <summary>
    /// Max number of cards returned to mobile clients in one AI response.
    /// </summary>
    public int MaxCardsPerResponse { get; set; } = 6;

    /// <summary>
    /// Safety cap for serialized profile/context block passed to the model.
    /// </summary>
    public int MaxContextChars { get; set; } = 2800;
}
