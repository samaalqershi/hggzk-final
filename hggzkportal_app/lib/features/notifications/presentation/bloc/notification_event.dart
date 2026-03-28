import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  final int page;

  final int limit;

  final String? type;

  final bool refresh;

  const LoadNotificationsEvent({
    this.page = 1,
    this.limit = 20,
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, type, refresh];
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

class DismissNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DismissNotificationEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class LoadNotificationSettingsEvent extends NotificationEvent {
  const LoadNotificationSettingsEvent();
}

class UpdateNotificationSettingsEvent extends NotificationEvent {
  final Map<String, bool> settings;

  const UpdateNotificationSettingsEvent({required this.settings});

  @override
  List<Object> get props => [settings];
}

class LoadUnreadCountEvent extends NotificationEvent {
  const LoadUnreadCountEvent();
}
