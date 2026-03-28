import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `SettingsEvent`.
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateLanguageEvent extends SettingsEvent {
  /// العربية: يخزن القيمة `languageCode`.
  final String languageCode;
  const UpdateLanguageEvent(this.languageCode);
  @override
  List<Object> get props => [languageCode];
}

class UpdateThemeEvent extends SettingsEvent {
  /// العربية: يحدد ما إذا كانت القيمة `isDarkMode` مفعلة.
  final bool isDarkMode;
  const UpdateThemeEvent(this.isDarkMode);
  @override
  List<Object> get props => [isDarkMode];
}

class UpdateBiometricEvent extends SettingsEvent {
  /// العربية: يخزن القيمة `enabled`.
  final bool enabled;
  const UpdateBiometricEvent(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class UpdateNotificationSettingsEvent extends SettingsEvent {
  /// العربية: يخزن القيمة `settings`.
  final NotificationSettings settings;
  const UpdateNotificationSettingsEvent(this.settings);
  @override
  List<Object> get props => [settings];
}

class UpdateCurrencyEvent extends SettingsEvent {
  /// العربية: يخزن القيمة `currencyCode`.
  final String currencyCode;
  const UpdateCurrencyEvent(this.currencyCode);
  @override
  List<Object> get props => [currencyCode];
}

class UpdateTimeZoneEvent extends SettingsEvent {
  /// العربية: يخزن القيمة `timeZone`.
  final String timeZone;
  const UpdateTimeZoneEvent(this.timeZone);
  @override
  List<Object> get props => [timeZone];
}

class ResetSettingsEvent extends SettingsEvent {}

class SyncSettingsEvent extends SettingsEvent {}

class AcceptPrivacyPolicyEvent extends SettingsEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `AcceptPrivacyPolicyEvent`.
  const AcceptPrivacyPolicyEvent();
  @override
  List<Object?> get props => [];
}
