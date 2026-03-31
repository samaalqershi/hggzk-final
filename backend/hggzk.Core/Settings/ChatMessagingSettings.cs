using System;

namespace YemenBooking.Core.Settings
{
    /// <summary>
    /// Runtime controls for chat realtime transport and user-facing push
    /// notifications.
    /// إعدادات تشغيلية تتحكم في ناقل الشات اللحظي وإشعارات الرسائل
    /// الظاهرة للمستخدم.
    /// </summary>
    public class ChatMessagingSettings
    {
        /// <summary>
        /// Chooses the realtime transport for chat events.
        /// WebSocket | Fcm | Both
        /// يحدد ناقل الأحداث اللحظية للشات.
        /// </summary>
        public string RealtimeTransport { get; set; } = "Both";

        /// <summary>
        /// Enables or disables user-visible push notifications for new
        /// incoming chat messages.
        /// يفعّل أو يعطل إشعارات الدفع الظاهرة للمستخدم للرسائل الجديدة.
        /// </summary>
        public bool EnableMessagePushNotifications { get; set; } = true;

        /// <summary>
        /// True when websocket-based chat realtime delivery is enabled.
        /// تكون صحيحة عند تفعيل النقل اللحظي عبر WebSocket.
        /// </summary>
        public bool IsWebSocketEnabled =>
            string.Equals(RealtimeTransport, "WebSocket", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(RealtimeTransport, "Both", StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// True when FCM-based chat delivery is enabled.
        /// تكون صحيحة عند تفعيل النقل عبر FCM.
        /// </summary>
        public bool IsFcmEnabled =>
            string.Equals(RealtimeTransport, "Fcm", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(RealtimeTransport, "Both", StringComparison.OrdinalIgnoreCase);
    }
}
