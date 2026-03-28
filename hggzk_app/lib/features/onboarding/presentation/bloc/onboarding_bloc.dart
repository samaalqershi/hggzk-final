import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/features/reference/domain/usecases/get_cities_usecase.dart';
import 'package:hggzk/features/reference/domain/usecases/get_currencies_usecase.dart';
import 'package:hggzk/core/usecases/usecase.dart';

/// Decides whether onboarding should run and persists the user's initial
/// location and currency choices when it completes.
///
/// يقرر ما إذا كانت التهيئة مطلوبة ثم يحفظ اختيارات المدينة والعملة عند
/// اكتمالها.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// Local persistence used to remember onboarding completion and selections.
  ///
  /// التخزين المحلي المستخدم لتذكر إكمال التهيئة والاختيارات.
  final LocalStorageService localStorage;

  /// Ensures city reference data is available before onboarding starts.
  ///
  /// يضمن توفر بيانات المدن المرجعية قبل بدء التهيئة.
  final GetCitiesUseCase getCitiesUseCase;

  /// Ensures currency reference data is available before onboarding starts.
  ///
  /// يضمن توفر بيانات العملات المرجعية قبل بدء التهيئة.
  final GetCurrenciesUseCase getCurrenciesUseCase;

  /// Connects persistence and reference-data use cases to the onboarding flow.
  ///
  /// يربط التخزين المحلي وحالات الاستخدام المرجعية بمسار التهيئة.
  OnboardingBloc({
    required this.localStorage,
    required this.getCitiesUseCase,
    required this.getCurrenciesUseCase,
  }) : super(const OnboardingInitial()) {
    on<CheckFirstRunEvent>(_onCheckFirstRun);
    on<CompleteOnboardingEvent>(_onComplete);
  }

  /// Determines whether onboarding is required and primes the reference data
  /// needed by the selection page.
  ///
  /// يحدد ما إذا كانت التهيئة مطلوبة ويجهز بيانات المرجع اللازمة لصفحة
  /// الاختيار.
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

  /// Saves the selected city and currency, then marks onboarding as complete.
  ///
  /// يحفظ المدينة والعملة المختارتين ثم يعلّم أن التهيئة اكتملت.
  Future<void> _onComplete(
      CompleteOnboardingEvent event, Emitter<OnboardingState> emit) async {
    emit(const OnboardingCompleting());

    // Persist the selected onboarding values before marking the flow complete.
    await localStorage.saveSelectedCity(event.city);
    await localStorage.saveSelectedCurrency(event.currencyCode);
    await localStorage.setOnboardingCompleted(true);

    emit(const OnboardingCompleted());
  }
}
