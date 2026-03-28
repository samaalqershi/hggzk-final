import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_channel.dart';

/// العربية: تمثل اللقطة الحالية لإدارة القنوات، بما في ذلك القوائم
/// والإحصاءات وحالات العمليات الجارية حتى ترى الواجهة التقدم الحقيقي.
class ChannelsState extends Equatable {
  /// العربية: القائمة الأساسية للقنوات الظاهرة في لوحة الإدارة.
  final List<NotificationChannel> channels;

  /// العربية: القناة التي يركز عليها المستخدم الآن.
  final NotificationChannel? selectedChannel;

  /// العربية: المستخدمون أو الأدوار المرتبطة بكل قناة.
  final List<UserChannelSubscription> subscribers;

  /// العربية: سجل الإشعارات التي أُرسلت عبر القنوات.
  final List<ChannelNotificationHistory> history;

  /// العربية: الإحصاءات المجمعة لكل قناة.
  final ChannelStatistics? statistics;

  /// العربية: بيانات تحليلية خام يمكن تحويلها إلى بطاقات أو رسوم.
  final Map<String, dynamic>? channelStatistics;

  /// العربية: تشير إلى أن القوائم أو الإحصاءات ما زالت تُحمّل.
  final bool isLoading;

  /// العربية: تعني أن إنشاء قناة جديدة جارٍ الآن.
  final bool isCreating;

  /// العربية: تعني أن تعديل قناة جارٍ الآن.
  final bool isUpdating;

  /// العربية: تعني أن حذف قناة جارٍ الآن.
  final bool isDeleting;

  /// العربية: تعني أن إرسال إشعار أو رسالة عبر قناة جارٍ الآن.
  final bool isSending;

  /// العربية: رسالة الخطأ الأخيرة إن حدثت مشكلة.
  final String? error;

  /// العربية: رسالة النجاح التي تؤكد اكتمال العملية.
  final String? successMessage;

  /// العربية: يهيئ حالة متوازنة حتى تبقى كل عملية واضحة ومقصودة في الواجهة.
  const ChannelsState({
    this.channels = const [],
    this.selectedChannel,
    this.subscribers = const [],
    this.history = const [],
    this.statistics,
    this.channelStatistics,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isSending = false,
    this.error,
    this.successMessage,
  });

  /// العربية: يصنع نسخة جديدة مع الإبقاء على القيم غير المرسلة كما هي حتى
  /// يكون التحديث الجزئي آمنًا ويحافظ على السياق.
  ChannelsState copyWith({
    List<NotificationChannel>? channels,
    NotificationChannel? selectedChannel,
    List<UserChannelSubscription>? subscribers,
    List<ChannelNotificationHistory>? history,
    ChannelStatistics? statistics,
    Map<String, dynamic>? channelStatistics,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isSending,
    String? error,
    String? successMessage,
  }) {
    return ChannelsState(
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      subscribers: subscribers ?? this.subscribers,
      history: history ?? this.history,
      statistics: statistics ?? this.statistics,
      channelStatistics: channelStatistics ?? this.channelStatistics,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isSending: isSending ?? this.isSending,
      error: error,
      successMessage: successMessage,
    );
  }

  /// العربية: تعتمد المساواة على الحقول المرئية وحالات العمل حتى يحدث
  /// إعادة البناء فقط عند تغير فعلي.
  @override
  List<Object?> get props => [
        channels,
        selectedChannel,
        subscribers,
        history,
        statistics,
        channelStatistics,
        isLoading,
        isCreating,
        isUpdating,
        isDeleting,
        isSending,
        error,
        successMessage,
      ];
}
