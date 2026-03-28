import 'package:equatable/equatable.dart';

/// يمثل حالات الإعداد الأولي من الفحص حتى الاكتمال حتى تستطيع
/// الواجهة متابعة كل مرحلة بشكل واضح.
/// Represents the onboarding stages from the initial check to
/// completion so the UI can follow each phase clearly.
abstract class OnboardingState extends Equatable {
  /// يضمن سلوك مقارنة ثابتًا بين حالات الإعداد حتى لا تعاد البناء
  /// إلا عند تغير المرحلة فعلًا.
  /// Keeps comparison behavior consistent across onboarding states so
  /// rebuilds only happen when the stage truly changes.
  const OnboardingState();

  /// القاعدة لا تحمل حقولًا مشتركة، لذلك تكون المساواة مبنية على
  /// النوع فقط.
  /// The base class has no shared fields, so equality falls back to
  /// the type alone.
  @override
  List<Object?> get props => [];
}

/// الحالة الأولى قبل أن يقرر الـ BLoC ما إذا كان ينبغي عرض الإعداد
/// أو تجاوزه.
/// The first state before the BLoC decides whether onboarding should
/// be shown or skipped.
class OnboardingInitial extends OnboardingState {
  /// هذه الحالة لا تضيف بيانات لأنها مجرد نقطة بدء.
  /// This state adds no data because it is only a starting point.
  const OnboardingInitial();
}

/// تشير إلى أن المستخدم لم يُكمل الإعداد بعد ويجب المرور به قبل
/// فتح التطبيق.
/// Indicates that the user still needs onboarding before entering the
/// app.
class OnboardingRequired extends OnboardingState {
  /// هذه الحالة تعبّر عن القرار نفسه، لذلك لا تحتاج إلى حقول
  /// إضافية.
  /// The decision itself is the important part, so no extra fields
  /// are needed.
  const OnboardingRequired();
}

/// تعني أن الإعداد محفوظ مسبقًا ويمكن الانتقال إلى المسار الرئيسي
/// مباشرة.
/// Means onboarding is already saved and the app can continue to the
/// main flow immediately.
class OnboardingNotRequired extends OnboardingState {
  /// لا تحتاج هذه الحالة إلى بيانات لأن الغرض منها هو تجاوز الإعداد
  /// فقط.
  /// No fields are needed because this state exists only to skip
  /// setup.
  const OnboardingNotRequired();
}

/// تمثل لحظة الحفظ الفعلية قبل إعلان نجاح الإعداد.
/// Represents the brief saving phase before onboarding is marked as
/// complete.
class OnboardingCompleting extends OnboardingState {
  /// تتيح للواجهة عرض حالة انتظار واضحة أثناء الحفظ.
  /// Lets the UI show a clear waiting state while data is persisted.
  const OnboardingCompleting();
}

/// تؤكد أن بيانات الإعداد حُفظت وأن التطبيق يمكنه المتابعة إلى
/// الشاشات الرئيسية.
/// Confirms onboarding data has been saved and the app can proceed
/// to the main screens.
class OnboardingCompleted extends OnboardingState {
  /// هذه الحالة لا تحتاج حقولًا إضافية لأن اكتمال العملية هو
  /// الإشارة المهمة.
  /// No extra fields are needed because completion itself is the key
  /// signal.
  const OnboardingCompleted();
}
