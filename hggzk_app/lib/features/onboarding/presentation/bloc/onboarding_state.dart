import 'package:equatable/equatable.dart';

/// Describes the three-step startup flow that decides whether onboarding
/// should continue or finish.
///
/// يصف مسار البدء الذي يحدد هل يجب متابعة التهيئة الأولية أم إنهاؤها.
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Marks the screen before the app knows whether the user must onboard.
///
/// تمثل الحالة التي تسبق معرفة ما إذا كان المستخدم يحتاج إلى التهيئة.
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Tells the UI to keep the onboarding flow visible.
///
/// تخبر الواجهة أن مسار التهيئة يجب أن يبقى ظاهرًا.
class OnboardingRequired extends OnboardingState {
  const OnboardingRequired();
}

/// Tells the UI that onboarding can be skipped entirely.
///
/// تخبر الواجهة أن التهيئة يمكن تجاوزها بالكامل.
class OnboardingNotRequired extends OnboardingState {
  const OnboardingNotRequired();
}

/// Shows a transient saving state while choices are written to storage.
///
/// تشير إلى لحظة حفظ الاختيارات في التخزين.
class OnboardingCompleting extends OnboardingState {
  const OnboardingCompleting();
}

/// Confirms that the setup choices have been saved successfully.
///
/// تؤكد أن اختيارات الإعداد حُفظت بنجاح.
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
