import 'package:equatable/equatable.dart';

/// العربية: كل حدث هنا يمثل نية واضحة من الواجهة مثل تحميل القنوات أو
/// تعديلها أو إرسال إشعار عبرها.
/// Each event represents an explicit user intent such as loading channels,
/// updating a channel, or sending a notification through one.
abstract class ChannelsEvent extends Equatable {
  /// انتقال البيانات بين الطبقات.
  /// data moves across layers.
  const ChannelsEvent();

  /// الحدث فقط.
  /// based on the event type only.
  @override
  List<Object?> get props => [];
}

/// أو الحالة النشطة.
/// search text, channel type, or active status.
class LoadChannelsEvent extends ChannelsEvent {
  /// ما كتبه المستخدم.
  /// description matches what the user typed.
  final String? search;

  /// فقط بدل القائمة كاملة.
  /// screen should show one category instead of the full catalog.
  final String? type;

  /// المفعلة عن الموقوفة.
  /// when separating active channels from disabled ones.
  final bool? isActive;
  final int page;

  /// predictable.
  final int pageSize;

  /// البيانات إلى نفس النتيجة نفسها.
  /// layer resolve the same result set.
  const LoadChannelsEvent({
    this.search,
    this.type,
    this.isActive,
    this.page = 1,
    this.pageSize = 20,
  });

  /// المطلوب أصبح قائمة مختلفة.
  /// them means a different list is being requested.
  @override
  List<Object?> get props => [search, type, isActive, page, pageSize];
}

/// القنوات النشطة والمتوقفة.
/// numbers such as total, active, and inactive channels.
class LoadChannelStatisticsEvent extends ChannelsEvent {
  /// لجلب الملخص.
  /// summary fetch.
  const LoadChannelStatisticsEvent();
}

/// persistence layer.
class CreateChannelEvent extends ChannelsEvent {
  /// subscription lists.
  final String name;

  /// تغيّر الاسم المعروض.
  /// channel internally even if the display name changes later.
  final String identifier;

  /// الاشتراك فيها.
  /// and when it should be used.
  final String? description;

  /// الإدارة.
  /// console.
  final String? type;

  /// القوائم والبنرات.
  /// lists or banners.
  final String? icon;

  /// مجموعاتها.
  /// channel or group from another.
  final String? color;

  /// البيانات بين الواجهة وطبقة التخزين.
  /// split payload preparation across layers.
  const CreateChannelEvent({
    required this.name,
    required this.identifier,
    this.description,
    this.type,
    this.icon,
    this.color,
  });

  /// المقصودة قبل إنشائها.
  /// them changes which channel is being created.
  @override
  List<Object?> get props => [name, identifier, description, type, icon, color];
}

/// record from scratch.
class UpdateChannelEvent extends ChannelsEvent {
  /// الصحيحة.
  /// reaches the correct channel.
  final String id;

  /// channel.
  final String? name;

  /// a change in scope.
  final String? description;

  /// without deletion.
  final bool? isActive;

  /// القناة أو تغيير نوعها.
  /// or type change.
  final String? icon;

  /// في أماكن العرض المختلفة.
  /// wherever it appears.
  final String? color;

  /// القيم التي يريد تبديلها.
  /// admin sends only the values that should change.
  const UpdateChannelEvent({
    required this.id,
    this.name,
    this.description,
    this.isActive,
    this.icon,
    this.color,
  });

  /// التحديث المطلوبة.
  /// changes the update request itself.
  @override
  List<Object?> get props => [id, name, description, isActive, icon, color];
}

class DeleteChannelEvent extends ChannelsEvent {
  /// removed.
  final String channelId;

  /// stable reference.
  const DeleteChannelEvent(this.channelId);

  /// means a different channel.
  @override
  List<Object> get props => [channelId];
}

/// إدارة المشتركين.
/// edit page or subscriber management view.
class LoadChannelDetailsEvent extends ChannelsEvent {
  /// the server.
  final String channelId;

  /// المصدر.
  /// the original details from the source.
  const LoadChannelDetailsEvent(this.channelId);

  /// واحدة.
  /// targets one channel only.
  @override
  List<Object> get props => [channelId];
}

/// فعلي إليها.
/// be managed explicitly.
class LoadChannelSubscribersEvent extends ChannelsEvent {
  final String channelId;

  /// التنظيف أو المراجعة.
  /// cleanup or review.
  final bool activeOnly;

  /// ذلك لعرض الأعضاء الحاليين.
  /// screen only needs the current member list.
  const LoadChannelSubscribersEvent({
    required this.channelId,
    this.activeOnly = true,
  });

  /// filtering is enabled.
  @override
  List<Object> get props => [channelId, activeOnly];
}

class AddSubscribersEvent extends ChannelsEvent {
  /// subscribers.
  final String channelId;

  /// the channel after saving.
  final List<String> userIds;

  /// بدل تكرار طلبات منفصلة.
  /// added as one operation instead of separate calls.
  const AddSubscribersEvent({
    required this.channelId,
    required this.userIds,
  });
  @override
  List<Object> get props => [channelId, userIds];
}

/// precisely.
class RemoveSubscribersEvent extends ChannelsEvent {
  final String channelId;

  /// revoked.
  final List<String> userIds;

  /// متناسقة.
  /// removal stays coordinated.
  const RemoveSubscribersEvent({
    required this.channelId,
    required this.userIds,
  });
  @override
  List<Object> get props => [channelId, userIds];
}

/// its subscribers.
class SendChannelNotificationEvent extends ChannelsEvent {
  final String channelId;

  /// alert.
  final String title;

  /// read.
  final String content;

  /// مثل تنبيه معلوماتي أو تحذيري.
  /// a particular category such as informational or warning.
  final String? type;

  /// المناسبة أو تبني سلوكًا خاصًا.
  /// screen or apply special behavior.
  final Map<String, String>? data;

  /// الإدارة وطبقة الشبكة.
  /// between the admin page and the network layer.
  const SendChannelNotificationEvent({
    required this.channelId,
    required this.title,
    required this.content,
    this.type,
    this.data,
  });

  /// ستصل للمشتركين.
  /// message that subscribers will receive.
  @override
  List<Object?> get props => [channelId, title, content, type, data];
}

/// أُرسل ومتى أُرسل.
/// review what was sent and when.
class LoadChannelHistoryEvent extends ChannelsEvent {
  final String channelId;

  /// جلبه كله مرة واحدة.
  /// fetching everything at once.
  final int page;

  /// batch.
  final int pageSize;

  /// ويحتاج صفحات متتابعة.
  /// history can be long and must be loaded in pages.
  const LoadChannelHistoryEvent({
    required this.channelId,
    this.page = 1,
    this.pageSize = 20,
  });
  @override
  List<Object> get props => [channelId, page, pageSize];
}

/// مرتبطة باشتراكاته الفعلية.
/// screen stays aligned with real subscriptions.
class LoadUserChannelsEvent extends ChannelsEvent {
  final String userId;

  /// on one user.
  const LoadUserChannelsEvent(this.userId);

  /// الشخصية.
  /// that person’s subscriptions.
  @override
  List<Object> get props => [userId];
}

/// أو إزالة أخرى.
/// channels and removing others.
class UpdateUserSubscriptionsEvent extends ChannelsEvent {
  final String userId;

  /// subscriptions.
  final List<String>? channelsToAdd;

  /// the user’s list.
  final List<String>? channelsToRemove;

  /// خطوة واحدة واضحة.
  /// happens in one clear step.
  const UpdateUserSubscriptionsEvent({
    required this.userId,
    this.channelsToAdd,
    this.channelsToRemove,
  });

  /// عملية المزامنة نفسها.
  /// together they define the sync operation.
  @override
  List<Object?> get props => [userId, channelsToAdd, channelsToRemove];
}
