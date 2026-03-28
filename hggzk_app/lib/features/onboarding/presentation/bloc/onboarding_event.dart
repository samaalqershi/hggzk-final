import 'package:equatable/equatable.dart';

/// Base contract for onboarding actions that check startup state or persist
/// the user's selected city and currency.
///
/// العقد الأساسي لأحداث التهيئة الأولى التي تفحص حالة الإقلاع أو تحفظ
/// المدينة والعملة المختارتين.
abstract class OnboardingEvent extends Equatable {
  /// Shared constructor for typed onboarding events.
  ///
  /// مُنشئ مشترك لأحداث التهيئة المقيّدة بالنوع.
  const OnboardingEvent();

  /// Subclasses decide which values identify the event.
  ///
  /// الفئات الفرعية هي التي تحدد القيم المعرّفة للحدث.
  @override
  List<Object?> get props => [];
}

/// Requests the first-run check that decides whether onboarding should open.
///
/// يطلب فحص التشغيل الأول الذي يحدد ما إذا كانت شاشة التهيئة يجب أن تظهر.
class CheckFirstRunEvent extends OnboardingEvent {
  /// Triggers the startup-state check.
  ///
  /// يطلق فحص حالة الإقلاع.
  const CheckFirstRunEvent();
}

/// Persists the selected city and currency after the onboarding step finishes.
///
/// يحفظ المدينة والعملة المختارتين بعد انتهاء خطوة التهيئة.
class CompleteOnboardingEvent extends OnboardingEvent {
  /// Selected city name that should be stored locally.
  ///
  /// اسم المدينة المختارة التي يجب حفظها محليًا.
  final String city;

  /// Currency code chosen by the user during onboarding.
  ///
  /// رمز العملة الذي اختاره المستخدم أثناء التهيئة.
  final String currencyCode;

  /// Packages the onboarding selections for persistence.
  ///
  /// يجمع اختيارات التهيئة تمهيدًا لحفظها.
  const CompleteOnboardingEvent(
      {required this.city, required this.currencyCode});

  /// Equality depends on both onboarding selections.
  ///
  /// تعتمد المساواة على اختياري المدينة والعملة.
  @override
  List<Object?> get props => [city, currencyCode];
}
