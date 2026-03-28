import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/features/home/domain/usecases/get_property_types_usecase.dart';
import 'package:hggzk/features/reference/domain/usecases/get_cities_usecase.dart';
import 'package:hggzk/features/reference/domain/usecases/get_currencies_usecase.dart';
import 'package:hggzk/core/services/data_sync_service.dart';
import '../../../../core/usecases/usecase.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// Runs startup preload work and reports progress to the splash screen.
/// يدير أعمال التحميل المسبق عند الإقلاع ويبلغ شاشة البداية بالتقدم.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  /// Service that synchronizes cached reference data.
  /// الخدمة التي تزامن البيانات المرجعية المخبأة.
  final DataSyncService dataSyncService;

  /// Use case that refreshes property types.
  /// حالة الاستخدام التي تحدّث أنواع العقارات.
  final GetPropertyTypesUseCase getPropertyTypesUseCase;

  /// Use case that refreshes cities.
  /// حالة الاستخدام التي تحدّث المدن.
  final GetCitiesUseCase getCitiesUseCase;

  /// Use case that refreshes currencies.
  /// حالة الاستخدام التي تحدّث العملات.
  final GetCurrenciesUseCase getCurrenciesUseCase;

  /// Injects the preload dependencies used during app startup.
  /// يحقن الاعتمادات التي تُستخدم أثناء بدء التشغيل.
  SplashBloc({
    required this.dataSyncService,
    required this.getPropertyTypesUseCase,
    required this.getCitiesUseCase,
    required this.getCurrenciesUseCase,
  }) : super(const SplashInitial()) {
    on<PreloadAppDataEvent>(_onPreload);
  }

  /// Preloads shared reference data and emits incremental progress updates.
  /// يحمل البيانات المرجعية المشتركة ويصدر تحديثات تقدم متدرجة.
  Future<void> _onPreload(
      PreloadAppDataEvent event, Emitter<SplashState> emit) async {
    emit(const SplashLoading(progress: 0.05));
    try {
      // Run operations in parallel where possible
      final futures = <Future<dynamic>>[
        dataSyncService
            .syncAllData(), // property types, unit types, dynamic fields
        getPropertyTypesUseCase(NoParams()), // ensure domain side cached too
        getCitiesUseCase(NoParams()),
        getCurrenciesUseCase(NoParams()),
      ];

      double completed = 0;
      final total = futures.length.toDouble();

      for (final f in futures) {
        await f;
        completed += 1;
        emit(SplashLoading(progress: (completed / total).clamp(0, 1)));
      }

      // Collect stats
      final stats = dataSyncService.getDataStats();
      emit(SplashLoaded(stats: stats));
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
