import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/unit.dart';
import '../../../domain/entities/unit_analytics.dart';
import '../../../domain/usecases/get_unit_details_usecase.dart';
import '../../../domain/usecases/get_unit_analytics_usecase.dart';
import '../../../domain/usecases/delete_unit_usecase.dart';
import '../../../domain/usecases/assign_unit_to_sections_usecase.dart';

part 'unit_details_event.dart';
part 'unit_details_state.dart';

/// يمثل هذا الكلاس UnitDetailsBloc البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsBloc in the admin unit workflow.
class UnitDetailsBloc extends Bloc<UnitDetailsEvent, UnitDetailsState> {
  /// This field keeps the getUnitDetailsUseCase value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة getUnitDetailsUseCase التي يعتمد عليها مسار إدارة الوحدات.
  final GetUnitDetailsUseCase getUnitDetailsUseCase;

  /// يحتفظ هذا الحقل بقيمة getUnitAnalyticsUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the getUnitAnalyticsUseCase value used by the admin unit workflow.
  final GetUnitAnalyticsUseCase getUnitAnalyticsUseCase;

  /// يحتفظ هذا الحقل بقيمة deleteUnitUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the deleteUnitUseCase value used by the admin unit workflow.
  final DeleteUnitUseCase deleteUnitUseCase;

  /// يحتفظ هذا الحقل بقيمة assignUnitToSectionsUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the assignUnitToSectionsUseCase value used by the admin unit workflow.
  final AssignUnitToSectionsUseCase assignUnitToSectionsUseCase;

  /// ينشئ هذا المُنشئ مثيلاً من UnitDetailsBloc.
  /// This constructor creates an instance of UnitDetailsBloc.
  UnitDetailsBloc({
    required this.getUnitDetailsUseCase,
    required this.getUnitAnalyticsUseCase,
    required this.deleteUnitUseCase,
    required this.assignUnitToSectionsUseCase,
  }) : super(UnitDetailsInitial()) {
    on<LoadUnitDetailsEvent>(_onLoadUnitDetails);
    on<DeleteUnitDetailsEvent>(_onDeleteUnit);
    on<AssignToSectionsEvent>(_onAssignToSections);
  }

  /// ينفذ هذا الأسلوب عملية _onLoadUnitDetails ضمن مسار إدارة الوحدات.
  /// This method performs the _onLoadUnitDetails operation in the admin unit workflow.
  Future<void> _onLoadUnitDetails(
    LoadUnitDetailsEvent event,
    Emitter<UnitDetailsState> emit,
  ) async {
    emit(UnitDetailsLoading());

    final result = await getUnitDetailsUseCase(
      GetUnitDetailsParams(unitId: event.unitId),
    );

    await result.fold(
      (failure) async {
        emit(UnitDetailsError(message: failure.message));
      },
      (unit) async {
        UnitAnalytics? analytics;

        final analyticsResult = await getUnitAnalyticsUseCase(
          GetUnitAnalyticsParams(unitId: event.unitId),
        );
        analyticsResult.fold(
          (_) {},
          (a) => analytics = a,
        );

        emit(UnitDetailsLoaded(unit: unit, analytics: analytics));
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _onDeleteUnit ضمن مسار إدارة الوحدات.
  /// This method performs the _onDeleteUnit operation in the admin unit workflow.
  Future<void> _onDeleteUnit(
    DeleteUnitDetailsEvent event,
    Emitter<UnitDetailsState> emit,
  ) async {
    final result = await deleteUnitUseCase(event.unitId);

    result.fold(
      (failure) => emit(UnitDetailsError(message: failure.message)),
      (_) => emit(UnitDeleted()),
    );
  }

  /// ينفذ هذا الأسلوب عملية _onAssignToSections ضمن مسار إدارة الوحدات.
  /// This method performs the _onAssignToSections operation in the admin unit workflow.
  Future<void> _onAssignToSections(
    AssignToSectionsEvent event,
    Emitter<UnitDetailsState> emit,
  ) async {
    final result = await assignUnitToSectionsUseCase(
      AssignUnitToSectionsParams(
        unitId: event.unitId,
        sectionIds: event.sectionIds,
      ),
    );

    result.fold(
      (failure) => emit(UnitDetailsError(message: failure.message)),
      (_) {
        if (state is UnitDetailsLoaded) {
          add(LoadUnitDetailsEvent(unitId: event.unitId));
        }
      },
    );
  }
}
