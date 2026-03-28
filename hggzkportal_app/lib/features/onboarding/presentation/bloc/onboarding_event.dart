import 'package:equatable/equatable.dart';

/// يمثل عقد أحداث الإعداد الأولي، بحيث تحمل كل خطوة البيانات التي
/// تغيّر قرار المتابعة فقط.
/// Represents the onboarding event contract so each step carries only
/// the data that can change the startup decision.
abstract class OnboardingEvent extends Equatable {
  /// يثبت أن أحداث الإعداد غير قابلة للتغيير وقابلة للمقارنة حتى
  /// يتمكن الـ BLoC من تمييز التحولات بدقة.
  /// Keeps onboarding events immutable and comparable so the BLoC
  /// can distinguish transitions reliably.
  const OnboardingEvent();

  /// تعتمد المساواة هنا على البيانات المؤثرة في القرار فقط لأن
  /// الأحداث نفسها لا تحمل سلوكًا مستقلًا.
  /// Equality is limited to the data that influences the decision
  /// because events themselves do not carry standalone behavior.
  @override
  List<Object?> get props => [];
}

/// يطلب التحقق من حالة التشغيل الأولى لتحديد ما إذا كان الإعداد
/// مطلوبًا أم يمكن تجاوزُه مباشرة.
/// Requests the first-run check to decide whether onboarding is
/// required or can be skipped.
class CheckFirstRunEvent extends OnboardingEvent {
  /// هذا الحدث لا يحمل حقولًا إضافية لأنه مجرد إشارة لبدء الفحص.
  /// This event carries no extra fields because it only signals that
  /// the check should start.
  const CheckFirstRunEvent();
}

/// يحمل القيم النهائية التي اختارها المستخدم في الإعداد حتى يتم
/// حفظها واستخدامها عند تشغيل بقية التطبيق.
/// Carries the final choices from onboarding so they can be saved and
/// reused when the rest of the app starts.
class CompleteOnboardingEvent extends OnboardingEvent {
  /// المدينة المختارة تصبح المرجع الافتراضي لشاشات البحث والعرض بعد
  /// الإعداد.
  /// The selected city becomes the default reference for search and
  /// display screens after setup.
  final String city;

  /// رمز العملة يحدد التنسيق المالي الذي سيظهر في بقية الواجهات.
  /// The currency code sets the financial formatting used in the rest
  /// of the UI.
  final String currencyCode;

  /// يجمع اختياري المدينة والعملة في حدث واحد حتى يحفظهما الـ BLoC
  /// كجزء من إنهاء الإعداد.
  /// Bundles the city and currency selections into one event so the
  /// BLoC can persist them while completing onboarding.
  const CompleteOnboardingEvent(
      {required this.city, required this.currencyCode});

  /// تعتمد المقارنة على المدينة والعملة لأنهما يحددان نتيجة الإعداد
  /// النهائية.
  /// Equality depends on the city and currency because they define
  /// the final onboarding result.
  @override
  List<Object?> get props => [city, currencyCode];
}
