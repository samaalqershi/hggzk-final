import 'package:hggzkportal/features/reference/domain/usecases/get_cities_usecase.dart'
    as ref_cities;
import 'package:hggzkportal/features/reference/domain/usecases/get_currencies_usecase.dart'
    as ref_currencies;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzkportal/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:hggzkportal/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:hggzkportal/services/local_storage_service.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';

/// ينسّق فحص الإعداد الأولي، ويحمّل البيانات المرجعية المطلوبة،
/// ثم يحفظ اختيارات المستخدم قبل السماح للواجهة بالانتقال إلى المسار الرئيسي.
/// Coordinates the onboarding check, loads the required reference
/// data, and persists the user's choices before allowing the UI to continue.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// يحتفظ بحالة الإعداد السابقة حتى يعرف الـ BLoC هل يعرض خطوة
  /// الإعداد أم يتجاوزها.
  /// Keeps the previous onboarding flag so the BLoC can decide
  /// whether to show setup or skip it.
  final LocalStorageService localStorage;
  /// يجلب المدن المطلوبة لتهيئة خيار الموقع الافتراضي أثناء الإعداد.
  /// Fetches the cities needed to prepare the default location choice
  /// during setup.
  final ref_cities.GetCitiesUseCase getCitiesUseCase;
  /// يجلب العملات المتاحة حتى يثبت المستخدم التنسيق المالي الملائم
  /// قبل متابعة الاستخدام.
  /// Fetches available currencies so the user can lock in a suitable
  /// financial format before continuing.
  final ref_currencies.GetCurrenciesUseCase getCurrenciesUseCase;

  /// يربط الـ BLoC بمصادره الأساسية ويبدأ من حالة محايدة حتى يصدر
  /// أول قرار مرتبط بالإعداد.
  /// Wires the BLoC to its core dependencies and starts from a neutral
  /// state until the first onboarding decision is emitted.
  OnboardingBloc({
    required this.localStorage,
    required this.getCitiesUseCase,
    required this.getCurrenciesUseCase,
  }) : super(const OnboardingInitial()) {
    on<CheckFirstRunEvent>(_onCheckFirstRun);
    on<CompleteOnboardingEvent>(_onComplete);
  }

  /// يتحقق من حالة التشغيل الأولى، وإن كان الإعداد مطلوبًا يضمن
  /// توفر المرجعيات قبل إظهار الخطوة التالية.
  /// Checks the first-run flag and, if setup is needed, ensures the
  /// reference data is ready before the next step is shown.
  Future<void> _onCheckFirstRun(
      CheckFirstRunEvent event, Emitter<OnboardingState> emit) async {
    final hasDone = localStorage.isOnboardingCompleted();
    if (hasDone) {
      emit(const OnboardingNotRequired());
      return;
    }
    // Ensure reference data exists
    await getCitiesUseCase(NoParams());
    await getCurrenciesUseCase(NoParams());
    emit(const OnboardingRequired());
  }

  /// يحفظ المدينة والعملة المختارتين ثم يعلن اكتمال الإعداد حتى
  /// تنتقل الواجهة إلى المسار التالي.
  /// Saves the selected city and currency, then emits completion so
  /// the UI can move to the next flow.
  Future<void> _onComplete(
      CompleteOnboardingEvent event, Emitter<OnboardingState> emit) async {
    emit(const OnboardingCompleting());

    // حفظ المدينة والعملة
    await localStorage.saveSelectedCity(event.city);
    await localStorage.saveSelectedCurrency(event.currencyCode);
    await localStorage.setOnboardingCompleted(true);

    emit(const OnboardingCompleted());
  }
}
