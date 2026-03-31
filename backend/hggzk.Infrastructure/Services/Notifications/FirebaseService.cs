using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using YemenBooking.Core.Settings;

namespace YemenBooking.Infrastructure.Services.Notifications
{
    /// <summary>
    /// يمثل خدمة إرسال إشعارات Firebase باستخدام Firebase Admin SDK.
    /// Represents a Firebase notification service backed by Firebase Admin SDK.
    /// </summary>
    public class FirebaseService : IFirebaseService
    {
        private static readonly TimeSpan NotificationTimeout = TimeSpan.FromSeconds(3);
        private static readonly HashSet<string> ChatRealtimeTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "new_message",
            "message_updated",
            "message_deleted",
            "message_status_updated",
            "reaction_added",
            "reaction_removed",
            "conversation_created",
            "conversation_updated",
            "user_status_changed"
        };

        private readonly ILogger<FirebaseService> _logger;
        private readonly ChatMessagingSettings _chatMessagingSettings;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة Firebase.
        /// Creates a new instance of the Firebase service.
        /// </summary>
        public FirebaseService(
            ILogger<FirebaseService> logger,
            IOptions<ChatMessagingSettings> chatMessagingSettings)
        {
            _logger = logger;
            _chatMessagingSettings = chatMessagingSettings.Value;
        }

        /// <summary>
        /// يرسل إشعار Firebase إلى موضوع أو جهاز محدد مع الحمولة الاختيارية.
        /// Sends a Firebase notification to a topic or token with optional payload data.
        /// </summary>
        public async Task<bool> SendNotificationAsync(string topicOrToken, string title, string body, IReadOnlyDictionary<string, string>? data = null, CancellationToken cancellationToken = default)
        {
            try
            {
                var payload = data != null
                    ? new Dictionary<string, string>(data, StringComparer.Ordinal)
                    : null;
                var isChatRealtimePayload = IsChatRealtimePayload(payload);

                if (isChatRealtimePayload && !_chatMessagingSettings.IsFcmEnabled)
                {
                    _logger.LogInformation(
                        "تم تجاوز إرسال FCM للشات بسبب الإعدادات. Target={Target}, Type={Type}",
                        topicOrToken,
                        payload != null && payload.TryGetValue("type", out var typeValue) ? typeValue : null);
                    return true;
                }

                if (isChatRealtimePayload &&
                    IsIncomingChatMessagePayload(payload) &&
                    !_chatMessagingSettings.EnableMessagePushNotifications)
                {
                    payload ??= new Dictionary<string, string>(StringComparer.Ordinal);
                    payload["silent"] = "true";
                    title = string.Empty;
                    body = string.Empty;
                }

                // Determine if we are sending to a topic or a token
                // Treat the following as topics:
                // - Strings starting with "/topics/" or "topic:"
                // - User topics: "user_{id}"
                // - Role topics: "role_{roleName}"
                // - Global topics: "all" and "admins"
                bool isTopic = false;
                string? topic = null;
                string? token = null;

                if (!string.IsNullOrWhiteSpace(topicOrToken))
                {
                    var value = topicOrToken.Trim();
                    if (value.StartsWith("/topics/", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.Substring("/topics/".Length);
                    }
                    else if (value.StartsWith("topic:", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.Substring("topic:".Length);
                    }
                    else if (value.StartsWith("user_", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value; // Firebase accepts topic names without the "/topics/" prefix when using Topic property
                    }
                    else if (value.StartsWith("role_", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value;
                    }
                    else if (value.Equals("all", StringComparison.OrdinalIgnoreCase) ||
                             value.Equals("admins", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.ToLowerInvariant();
                    }
                    else
                    {
                        token = value;
                    }
                }

                // Determine if this is a silent (data-only) push
                bool isSilent = false;
                if (payload != null && payload.TryGetValue("silent", out var silentFlag))
                {
                    if (string.Equals(silentFlag, "true", StringComparison.OrdinalIgnoreCase))
                    {
                        isSilent = true;
                    }
                }
                if (string.IsNullOrWhiteSpace(title) && string.IsNullOrWhiteSpace(body))
                {
                    isSilent = true;
                }

                var channelId = "hggzk_channel";
                if (payload != null &&
                    payload.TryGetValue("channel_id", out var customChannelId) &&
                    !string.IsNullOrWhiteSpace(customChannelId))
                {
                    channelId = customChannelId;
                }

                var shouldPlaySound = !isSilent;
                if (payload != null &&
                    payload.TryGetValue("sound_enabled", out var soundEnabledValue) &&
                    string.Equals(soundEnabledValue, "false", StringComparison.OrdinalIgnoreCase))
                {
                    shouldPlaySound = false;
                }

                var androidConfig = new AndroidConfig
                {
                    Priority = Priority.High,
                    Notification = isSilent ? null : new AndroidNotification
                    {
                        // Must match app's AndroidNotificationDetails channel id
                        ChannelId = channelId,
                    },
                };

                var apnsConfig = new ApnsConfig
                {
                    Aps = isSilent
                        ? new Aps
                        {
                            // Background update without alert
                            ContentAvailable = true,
                        }
                        : new Aps
                        {
                            ContentAvailable = false,
                            Alert = new ApsAlert
                            {
                                Title = title,
                                Body = body
                            },
                            Sound = shouldPlaySound ? "default" : null,
                        },
                    Headers = new Dictionary<string, string>
                    {
                        // High priority for iOS
                        { "apns-priority", isSilent ? "5" : "10" }
                    }
                };

                var message = new Message
                {
                    Notification = isSilent ? null : new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    // Ensure a stable payload for deduplication on client-side
                    Data = BuildDataPayload(payload, title, body),
                    Android = androidConfig,
                    Apns = apnsConfig,
                };

                if (isTopic && !string.IsNullOrWhiteSpace(topic))
                {
                    message.Topic = topic; // send to topic
                }
                else if (!string.IsNullOrWhiteSpace(token))
                {
                    message.Token = token; // send to device token
                }
                else
                {
                    _logger.LogWarning("لم يتم توفير Topic أو Token صالح لإشعار Firebase");
                    return false;
                }

                try
                {
                    var response = await FirebaseMessaging.DefaultInstance
                        .SendAsync(message, cancellationToken)
                        .WaitAsync(NotificationTimeout, cancellationToken);
                    _logger.LogInformation("تم إرسال إشعار Firebase بنجاح: {Response}", response);
                    return true;
                }
                catch (TimeoutException timeoutEx)
                {
                    _logger.LogWarning(timeoutEx, "انتهت مهلة إرسال إشعار Firebase بعد {TimeoutSeconds} ثواني للهدف {Target}", NotificationTimeout.TotalSeconds, topicOrToken);
                    return false;
                }
            }
            catch (FirebaseMessagingException fcmEx)
            {
                _logger.LogError(fcmEx, "FirebaseMessagingException أثناء إرسال الإشعار. Code: {Code}, HttpResponse: {HttpResponse}", fcmEx.ErrorCode, fcmEx.HttpResponse);
                return false;
                }
                catch (OperationCanceledException canceledEx)
                {
                    if (!cancellationToken.IsCancellationRequested)
                    {
                        _logger.LogWarning(canceledEx, "تم إلغاء إرسال إشعار Firebase للهدف {Target} قبل إتمامه", topicOrToken);
                    }
                    return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في إرسال إشعار Firebase");
                return false;
            }
        }
    
        private IReadOnlyDictionary<string, string> BuildDataPayload(IReadOnlyDictionary<string, string>? extra, string title, string body)
        {
            var dict = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                {"title", title ?? string.Empty},
                {"body", body ?? string.Empty},
                {"source", "server"}
            };
            if (extra != null)
            {
                foreach (var kv in extra)
                {
                    // do not override core keys
                    if (!dict.ContainsKey(kv.Key)) dict[kv.Key] = kv.Value ?? string.Empty;
                }
            }
            return dict;
        }

        private static bool IsChatRealtimePayload(IReadOnlyDictionary<string, string>? data)
        {
            return data != null &&
                   data.TryGetValue("type", out var type) &&
                   !string.IsNullOrWhiteSpace(type) &&
                   ChatRealtimeTypes.Contains(type);
        }

        private static bool IsIncomingChatMessagePayload(IReadOnlyDictionary<string, string>? data)
        {
            return data != null &&
                   data.TryGetValue("type", out var type) &&
                   string.Equals(type, "new_message", StringComparison.OrdinalIgnoreCase);
        }
    }
}
