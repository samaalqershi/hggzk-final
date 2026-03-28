import 'package:equatable/equatable.dart';

/// Base state for the startup flow while the app prepares its first screen.
/// الحالة الأساسية لمسار الإقلاع أثناء تجهيز التطبيق لشاشته الأولى.
abstract class SplashState extends Equatable {
  /// Shared constructor for splash states.
  /// مُنشئ مشترك لحالات شاشة البداية.
  const SplashState();

  /// Base state has no payload, so equality depends on the subclass only.
  /// لا تحمل الحالة الأساسية بيانات، لذا تعتمد المساواة على الفئة الفرعية فقط.
  @override
  List<Object?> get props => [];
}

/// Initial state before any startup work begins.
/// حالة البداية قبل تنفيذ أي عمل تمهيدي.
class SplashInitial extends SplashState {
  /// Marks the moment the splash screen is first mounted.
  /// يحدد لحظة ظهور شاشة البداية لأول مرة.
  const SplashInitial();
}

/// Indicates that startup assets or cached data are still being prepared.
/// تشير إلى أن موارد الإقلاع أو البيانات المخبأة ما زالت قيد التجهيز.
class SplashLoading extends SplashState {
  /// Normalized progress value between `0` and `1`.
  /// قيمة تقدم معيارية بين `0` و`1`.
  final double progress; // 0..1

  /// Tracks how much of the startup sequence has completed.
  /// يتتبع مقدار ما اكتمل من تسلسل الإقلاع.
  const SplashLoading({this.progress = 0});

  /// Compares the visible progress so the animation updates correctly.
  /// يقارن التقدم الظاهر حتى تتحدث الحركة بشكل صحيح.
  @override
  List<Object?> get props => [progress];
}

/// Indicates that startup data has been prepared successfully.
/// تشير إلى أن بيانات الإقلاع أصبحت جاهزة بنجاح.
class SplashLoaded extends SplashState {
  /// Diagnostic or preload data collected during app startup.
  /// بيانات تشخيصية أو تمهيدية جُمعت أثناء بدء التشغيل.
  final Map<String, dynamic> stats;

  /// Stores startup results so the app can decide the next route.
  /// يخزن نتائج الإقلاع حتى يقرر التطبيق المسار التالي.
  const SplashLoaded({this.stats = const {}});

  /// Compares the startup payload for stable state transitions.
  /// يقارن بيانات الإقلاع لضمان انتقالات مستقرة بين الحالات.
  @override
  List<Object?> get props => [stats];
}

/// Indicates that startup failed before the app could route forward.
/// تشير إلى فشل الإقلاع قبل أن ينتقل التطبيق إلى الشاشة التالية.
class SplashError extends SplashState {
  /// Failure text that should be shown or logged during startup recovery.
  /// نص الفشل الذي يجب عرضه أو تسجيله أثناء معالجة الإقلاع.
  final String message;

  /// Captures the startup failure details.
  /// يلتقط تفاصيل فشل الإقلاع.
  const SplashError(this.message);

  /// Compares the failure message so duplicate errors do not retrigger work.
  /// يقارن رسالة الخطأ حتى لا تعيد الأخطاء المتطابقة تشغيل نفس العمل.
  @override
  List<Object?> get props => [message];
}
