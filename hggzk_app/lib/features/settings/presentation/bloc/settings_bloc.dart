import 'package:hggzk/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/app/bloc/app_bloc.dart';
import 'package:hggzk/core/bloc/theme/theme_event.dart' as core_theme;
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';
import 'package:hggzk/core/services/biometric_auth_service.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_language_usecase.dart';
import '../../domain/usecases/update_theme_usecase.dart';
import '../../domain/usecases/update_biometric_usecase.dart';
import '../../domain/usecases/update_notification_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// ينسق كل تغييرات الإعدادات بين طبقة العرض، حالات البلوك، والتخزين المحلي
/// حتى تبقى التفضيلات الظاهرة للمستخدم متطابقة مع الحالة المحفوظة.
/// Coordinates all settings changes across the UI, bloc state, and local
/// persistence so the visible preferences always match what is stored.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// النسخة العاملة من الإعدادات التي تُحدَّث محليًا قبل إعادة قراءتها من
  /// المصدر الدائم.
  /// The working settings snapshot that gets updated locally before being
  /// reloaded from the persistent source.
  AppSettings? _currentSettings;

  Future<String> _tr(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    return AppLocalizations.translate(
      key,
      locale: LocaleManager.getCurrentLocale(),
      params: params,
    );
  }

  /// يحمّل النسخة المعتمدة من الإعدادات عند الطلب حتى يبدأ البلوك من حالة
  /// صحيحة.
  /// Loads the authoritative settings snapshot on demand so the bloc starts
  /// from a valid state.
  final GetSettingsUseCase getSettingsUseCase;

  /// يحمّل تبديل اللغة ويعيد كتابته في المصدر المسؤول عن حفظ التفضيلات.
  /// Persists language changes through the use case responsible for settings
  /// storage.
  final UpdateLanguageUseCase updateLanguageUseCase;

  /// يطبق تبديل الوضع الفاتح أو الداكن على الإعدادات المحفوظة.
  /// Persists the light/dark appearance selection in stored settings.
  final UpdateThemeUseCase updateThemeUseCase;

  /// يحدّث تفضيل البصمة عندما تتوفر طبقة استخدام مخصصة لذلك.
  /// Updates biometric preferences when a dedicated use case is available.
  final UpdateBiometricUseCase? updateBiometricUseCase;

  /// يكتب إعدادات الإشعارات الجديدة في المصدر المعتمد.
  /// Persists the updated notification preferences in the trusted source.
  final UpdateNotificationSettingsUseCase updateNotificationSettingsUseCase;

  /// يستعمل لتخزين الإعدادات الخفيفة التي لا تحتاج إلى نموذج domain كامل.
  /// Used for lightweight storage entries that do not need a full domain
  /// model round-trip.
  final AuthLocalDataSource localDataSource;

  /// ينسق تخزين واسترجاع سر التحقق البيومتري بشكل آمن.
  /// Coordinates secure storage and retrieval of the biometric refresh token.
  final BiometricAuthService biometricAuthService;

  /// ينشئ البلوك مع جميع الاعتمادات التي يحتاجها لتحديث الإعدادات ومزامنتها.
  /// Creates the bloc with all dependencies needed to update and sync
  /// settings.
  SettingsBloc({
    required this.getSettingsUseCase,
    required this.updateLanguageUseCase,
    required this.updateThemeUseCase,
    required this.updateNotificationSettingsUseCase,
    required this.localDataSource,
    required this.biometricAuthService,
    this.updateBiometricUseCase,
  }) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateNotificationSettingsEvent>(_onUpdateNotificationSettings);
    on<UpdateBiometricEvent>(_onUpdateBiometric);
    on<UpdateCurrencyEvent>(_onUpdateCurrency);
    on<UpdateTimeZoneEvent>(_onUpdateTimeZone);
    on<ResetSettingsEvent>(_onResetSettings);
    on<SyncSettingsEvent>(_onSyncSettings);
    on<AcceptPrivacyPolicyEvent>(_onAcceptPrivacyPolicy);

    // يبدأ بحالة القراءة الفعلية للإعدادات حتى تكون الشاشة جاهزة عند أول
    // رسم.
    add(LoadSettingsEvent());
  }

  /// يقرأ الإعدادات المخزنة ويثبتها كنسخة العمل داخل البلوك.
  /// Reads the stored settings and keeps them as the working snapshot inside
  /// the bloc.
  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await getSettingsUseCase(NoParams());

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) {
        _currentSettings = settings;
        AppBloc.theme.add(
          core_theme.SetThemeEvent(
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          ),
        );
        emit(SettingsLoaded(settings));
      },
    );
  }

  /// يغيّر لغة الواجهة ويحفظ التغيير ثم يعيد تحميل الإعدادات للتأكد من
  /// اتساق الحالة.
  /// Changes the interface language, persists it, and reloads settings to
  /// keep the bloc state aligned.
  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      final result = await updateLanguageUseCase(
        UpdateLanguageParams(languageCode: event.languageCode),
      );

      await result.fold(
        (failure) async => emit(
          SettingsError(failure.message, lastKnownSettings: _currentSettings),
        ),
        (success) async {
          _currentSettings = _currentSettings!.copyWith(
            preferredLanguage: event.languageCode,
          );
          emit(SettingsUpdated(
            _currentSettings!,
            message: await _tr('settings.language.updated'),
          ));
          add(LoadSettingsEvent());
        },
      );
    }
  }

  /// يبدّل بين الوضع الداكن والفاتح ويحدث الحالة المخزنة مع رسالة
  /// تأكيد مناسبة.
  /// Switches between dark and light mode while updating the stored state and
  /// showing a contextual confirmation message.
  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      final result = await updateThemeUseCase(
        UpdateThemeParams(isDarkMode: event.isDarkMode),
      );

      await result.fold(
        (failure) async => emit(
          SettingsError(failure.message, lastKnownSettings: _currentSettings),
        ),
        (success) async {
          _currentSettings = _currentSettings!.copyWith(
            darkMode: event.isDarkMode,
          );
          AppBloc.theme.add(
            core_theme.SetThemeEvent(
              themeMode: event.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            ),
          );
          emit(SettingsUpdated(
            _currentSettings!,
            message: event.isDarkMode
                ? await _tr('settings.theme.darkEnabled')
                : await _tr('settings.theme.lightEnabled'),
          ));
          add(LoadSettingsEvent());
        },
      );
    }
  }

  /// يطبق تفضيل المصادقة الحيوية ويزامن السر الآمن المرتبط بها إذا كان
  /// التفعيل متاحًا.
  /// Applies the biometric preference and syncs the related secure secret when
  /// biometric login is enabled.
  Future<void> _onUpdateBiometric(
    UpdateBiometricEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      if (updateBiometricUseCase == null) {
        try {
          await localDataSource.saveData('biometric_enabled', event.enabled);
          _currentSettings = _currentSettings!.copyWith(
            biometricEnabled: event.enabled,
            additionalSettings: {
              ..._currentSettings!.additionalSettings,
              'biometricEnabled': event.enabled,
            },
          );
          await _syncBiometricStorage(event.enabled);
          emit(SettingsUpdated(
            _currentSettings!,
            message: event.enabled
                ? await _tr('settings.biometric.enabled')
                : await _tr('settings.biometric.disabled'),
          ));
          add(LoadSettingsEvent());
        } catch (e) {
          emit(SettingsError(
            await _tr('settings.biometric.updateFailed'),
            lastKnownSettings: _currentSettings,
          ));
        }
        return;
      }

      final result = await updateBiometricUseCase!(
        UpdateBiometricParams(enabled: event.enabled),
      );

      await result.fold(
        (failure) async => emit(
          SettingsError(failure.message, lastKnownSettings: _currentSettings),
        ),
        (success) async {
          _currentSettings = _currentSettings!.copyWith(
            biometricEnabled: event.enabled,
            additionalSettings: {
              ..._currentSettings!.additionalSettings,
              'biometricEnabled': event.enabled,
            },
          );
          await _syncBiometricStorage(event.enabled);
          emit(SettingsUpdated(
            _currentSettings!,
            message: event.enabled
                ? await _tr('settings.biometric.enabled')
                : await _tr('settings.biometric.disabled'),
          ));
          add(LoadSettingsEvent());
        },
      );
    }
  }

  /// يحفظ إعدادات الإشعارات الجديدة ثم يعيد تحميل الحالة حتى تبقى القيم
  /// المرئية متطابقة مع التخزين.
  /// Persists the updated notification settings and reloads the state so the
  /// visible values stay aligned with storage.
  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      final result = await updateNotificationSettingsUseCase(
        UpdateNotificationSettingsParams(settings: event.settings),
      );

      await result.fold(
        (failure) async => emit(
          SettingsError(failure.message, lastKnownSettings: _currentSettings),
        ),
        (success) async {
          _currentSettings = _currentSettings!.copyWith(
            notificationSettings: event.settings,
          );
          emit(SettingsUpdated(
            _currentSettings!,
            message: await _tr('settings.notifications.updated'),
          ));
          // Reload to ensure consistency
          add(LoadSettingsEvent());
        },
      );
    }
  }

  /// يغير العملة المعروضة داخل الإعدادات ويحدث النسخة المحلية مباشرة لأن
  /// هذه القيمة لا تحتاج مسار حفظ مستقل.
  /// Updates the displayed currency directly in the local snapshot because
  /// this preference does not use a dedicated persistence path here.
  Future<void> _onUpdateCurrency(
    UpdateCurrencyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      // Since we don't have a specific use case for currency,
      // we'll update the settings directly
      _currentSettings = _currentSettings!.copyWith(
        preferredCurrency: event.currencyCode,
      );

      emit(SettingsUpdated(
        _currentSettings!,
        message: await _tr('settings.currency.updated'),
      ));
    }
  }

  /// يغير المنطقة الزمنية النشطة حتى تبقى الحسابات الزمنية والختمات
  /// الزمنية متوافقة مع بيئة المستخدم.
  /// Updates the active time zone so time-based calculations and timestamps
  /// stay aligned with the user's environment.
  Future<void> _onUpdateTimeZone(
    UpdateTimeZoneEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsUpdating(_currentSettings!));

      _currentSettings = _currentSettings!.copyWith(
        timeZone: event.timeZone,
      );

      emit(SettingsUpdated(
        _currentSettings!,
        message: await _tr('settings.timezone.updated'),
      ));
    }
  }

  /// يعيد الإعدادات إلى القيم الافتراضية ثم يعرض الحالة الجديدة بدل ترك
  /// القيم القديمة معلقة.
  /// Restores the default settings and then emits the fresh state instead of
  /// leaving the previous values in place.
  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    // Reset to default settings
    _currentSettings = const AppSettings();

    emit(SettingsUpdated(
      _currentSettings!,
      message: await _tr('settings.reset.done'),
    ));

    // Reload settings
    add(LoadSettingsEvent());
  }

  /// يطلب مهلة قصيرة ثم يعيد نشر الحالة الحالية لتقليد مزامنة خارجية
  /// عندما لا يكون هناك مسار API مباشر هنا.
  /// Waits briefly and then re-emits the current state to simulate an external
  /// sync when no dedicated API path exists in this bloc.
  Future<void> _onSyncSettings(
    SyncSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings != null) {
      emit(SettingsSyncing(_currentSettings!));

      // Simulate sync delay
      await Future.delayed(const Duration(seconds: 2));

      emit(SettingsSynced(_currentSettings!));

      // Reload settings after sync
      add(LoadSettingsEvent());
    }
  }

  /// يسجل موافقة المستخدم على سياسة الخصوصية في التخزين المحلي ويضيفها إلى
  /// snapshot الإعدادات حتى تستفيد منها بقية الطبقات.
  /// Records privacy-policy acceptance in local storage and folds it into the
  /// settings snapshot so other layers can rely on the consent state.
  Future<void> _onAcceptPrivacyPolicy(
    AcceptPrivacyPolicyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    // Save that user accepted privacy policy
    await localDataSource.saveData('privacy_policy_accepted', true);
    await localDataSource.saveData(
        'privacy_policy_accepted_date', DateTime.now().toIso8601String());

    // Optionally update settings
    if (_currentSettings != null) {
      final updatedSettings = _currentSettings!.copyWith(
        additionalSettings: {
          ..._currentSettings!.additionalSettings,
          'privacyPolicyAccepted': true,
          'privacyPolicyAcceptedDate': DateTime.now().toIso8601String(),
        },
      );
      _currentSettings = updatedSettings;
      emit(SettingsUpdated(
        updatedSettings,
        message: await _tr('settings.privacy.accepted'),
      ));
    }
  }

  /// ينسخ سر التحقق البيومتري أو يمسحه بحسب حالة التفعيل حتى يبقى الدخول
  /// الآمن متوافقًا مع التفضيل الحالي.
  /// Copies or clears the biometric refresh token depending on the enabled
  /// flag so secure sign-in always matches the current preference.
  Future<void> _syncBiometricStorage(bool enabled) async {
    if (enabled) {
      String? refreshToken;
      try {
        refreshToken = await localDataSource.getCachedRefreshToken();
      } catch (_) {}

      if (refreshToken == null || refreshToken.isEmpty) {
        final localStorage = sl<LocalStorageService>();
        final stored = localStorage.getData(StorageConstants.refreshToken);
        if (stored is String && stored.isNotEmpty) {
          refreshToken = stored;
        }
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await biometricAuthService.saveRefreshTokenSecurely(refreshToken);
        } catch (_) {}
      }
    } else {
      try {
        await biometricAuthService.clearSecureRefreshToken();
      } catch (_) {}
    }
  }
}
