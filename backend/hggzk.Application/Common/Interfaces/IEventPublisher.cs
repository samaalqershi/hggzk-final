namespace YemenBooking.Application.Common.Interfaces;

/// <summary>
/// Defines the contract for publishing integration or domain events.
/// يعرّف عقد نشر الأحداث التكاملية أو أحداث النطاق.
/// </summary>
public interface IEventPublisher
{
    /// <summary>
    /// Publishes a single event immediately through the configured publisher.
    /// ينشر حدثًا واحدًا مباشرة عبر الناشر المهيأ.
    /// </summary>
    /// <param name="eventData">Event payload. بيانات الحدث.</param>
    /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
    /// <returns>A value indicating whether publishing succeeded. قيمة تشير إلى نجاح النشر.</returns>
    Task<bool> PublishEventAsync<T>(T eventData, CancellationToken cancellationToken = default) where T : class;

    /// <summary>
    /// Publishes an event through a concise alias that delegates to <see cref="PublishEventAsync{T}(T, CancellationToken)"/>.
    /// ينشر الحدث عبر اسم مختصر موحّد يستدعي <see cref="PublishEventAsync{T}(T, CancellationToken)"/>.
    /// </summary>
    /// <param name="eventData">Event payload. بيانات الحدث.</param>
    /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
    /// <returns>A value indicating whether publishing succeeded. قيمة تشير إلى نجاح النشر.</returns>
    Task<bool> PublishAsync<T>(T eventData, CancellationToken cancellationToken = default) where T : class;
}
