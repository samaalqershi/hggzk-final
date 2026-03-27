using System;

namespace YemenBooking.Core.Notifications
{
    /// <summary>
    /// طلب الإشعار
    /// Notification request
    /// </summary>
    public class NotificationRequest
    {
        /// <summary>
        /// معرف المستخدم المستلم
        /// Identifier of the recipient user
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// نوع الإشعار
        /// Notification type
        /// </summary>
        public NotificationType Type { get; set; }

        /// <summary>
        /// عنوان الإشعار
        /// Notification title
        /// </summary>
        public string Title { get; set; } = null!;

        /// <summary>
        /// رسالة الإشعار
        /// Notification message
        /// </summary>
        public string Message { get; set; } = null!;

        /// <summary>
        /// بيانات إضافية للإشعار
        /// Additional data for the notification
        /// </summary>
        public object? Data { get; set; }
    }

    /// <summary>
    /// أنواع الإشعارات
    /// Notification types
    /// </summary>
    public enum NotificationType
    {
        /// <summary>
        /// قيمة تعداد BookingCancelled.
        /// BookingCancelled enum value.
        /// </summary>
        BookingCancelled,
        /// <summary>
        /// قيمة تعداد CheckInCompleted.
        /// CheckInCompleted enum value.
        /// </summary>
        CheckInCompleted,
        /// <summary>
        /// قيمة تعداد BookingCompleted.
        /// BookingCompleted enum value.
        /// </summary>
        BookingCompleted,
        /// <summary>
        /// قيمة تعداد BookingConfirmed.
        /// BookingConfirmed enum value.
        /// </summary>
        BookingConfirmed,
        /// <summary>
        /// قيمة تعداد BookingCreated.
        /// BookingCreated enum value.
        /// </summary>
        BookingCreated,
        /// <summary>
        /// قيمة تعداد BookingUpdated.
        /// BookingUpdated enum value.
        /// </summary>
        BookingUpdated,
        /// <summary>
        /// قيمة تعداد PaymentProcessed.
        /// PaymentProcessed enum value.
        /// </summary>
        PaymentProcessed,
        /// <summary>
        /// قيمة تعداد PaymentVoided.
        /// PaymentVoided enum value.
        /// </summary>
        PaymentVoided,
        /// <summary>
        /// قيمة تعداد RefundProcessed.
        /// RefundProcessed enum value.
        /// </summary>
        RefundProcessed,
        /// <summary>
        /// قيمة تعداد PaymentFailed.
        /// PaymentFailed enum value.
        /// </summary>
        PaymentFailed,
        /// <summary>
        /// قيمة تعداد System.
        /// System enum value.
        /// </summary>
        System,
        /// <summary>
        /// قيمة تعداد Promotion.
        /// Promotion enum value.
        /// </summary>
        Promotion,
        /// <summary>
        /// قيمة تعداد Alert.
        /// Alert enum value.
        /// </summary>
        Alert
    }
} 