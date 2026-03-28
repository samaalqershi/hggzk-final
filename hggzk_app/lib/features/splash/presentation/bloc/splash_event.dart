import 'package:equatable/equatable.dart';

/// Base event for startup preparation before navigating away from the splash.
/// الحدث الأساسي لتهيئة بدء التشغيل قبل مغادرة شاشة البداية.
abstract class SplashEvent extends Equatable {
  /// Shared constructor for all splash events.
  /// مُنشئ مشترك لكل أحداث شاشة البداية.
  const SplashEvent();

  /// Base event carries no fields of its own.
  /// لا يحمل الحدث الأساسي أي حقول خاصة به.
  @override
  List<Object?> get props => [];
}

/// Starts the startup preload sequence.
/// يبدأ تسلسل التحميل المسبق أثناء الإقلاع.
class PreloadAppDataEvent extends SplashEvent {
  /// Forces startup data to bypass cache and refresh from source.
  /// يجبر بيانات الإقلاع على تجاوز الكاش والتحميل من المصدر مباشرة.
  final bool forceRefresh;

  /// Signals whether the preload should reuse cached results or refresh them.
  /// يحدد ما إذا كان التحميل المسبق سيعيد استخدام الكاش أم سيحدّثه.
  const PreloadAppDataEvent({this.forceRefresh = false});
}
