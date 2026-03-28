import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unit.dart' as entity;
import '../repositories/property_repository.dart';

/// Fetches the units that should be shown for a property in the booking flow.
/// يجلب الوحدات التي يجب عرضها لعقار ما داخل مسار الحجز.
class GetPropertyUnitsUseCase
    implements UseCase<List<entity.Unit>, GetPropertyUnitsParams> {
  /// Repository bridge that resolves the unit list from data sources.
  /// جسر المستودع الذي يستخرج قائمة الوحدات من مصادر البيانات.
  final PropertyRepository repository;

  /// Creates the use case around the property repository contract.
  /// ينشئ حالة الاستخدام اعتمادًا على عقد مستودع العقار.
  GetPropertyUnitsUseCase({required this.repository});

  /// Requests the unit list using the property context and stay parameters.
  /// يطلب قائمة الوحدات باستخدام سياق العقار ومعطيات الإقامة.
  @override
  Future<Either<Failure, List<entity.Unit>>> call(
      GetPropertyUnitsParams params) async {
    return await repository.getPropertyUnits(
      propertyId: params.propertyId,
      checkInDate: params.checkInDate,
      checkOutDate: params.checkOutDate,
      guestsCount: params.guestsCount,
    );
  }
}

/// Parameters required to resolve the correct unit list for a property.
/// المعطيات المطلوبة للوصول إلى قائمة الوحدات الصحيحة لعقار ما.
class GetPropertyUnitsParams extends Equatable {
  /// Backend identifier of the property being queried.
  /// المعرّف الخلفي للعقار المطلوب.
  final String propertyId;

  /// Optional arrival date used to filter unit availability.
  /// تاريخ الوصول الاختياري المستخدم لتصفية التوفر.
  final DateTime? checkInDate;

  /// Optional departure date paired with the arrival date.
  /// تاريخ المغادرة الاختياري المرتبط بتاريخ الوصول.
  final DateTime? checkOutDate;

  /// Number of guests that the units must accommodate.
  /// عدد الضيوف الذين يجب أن تستوعبهم الوحدات.
  final int guestsCount;

  /// Bundles the booking context used when loading property units.
  /// يجمع سياق الحجز المستخدم عند تحميل وحدات العقار.
  const GetPropertyUnitsParams({
    required this.propertyId,
    this.checkInDate,
    this.checkOutDate,
    required this.guestsCount,
  });

  /// Keeps request equality stable for repeated identical lookups.
  /// يحافظ على ثبات مقارنة الطلبات عند تكرار نفس الاستعلام.
  @override
  List<Object?> get props =>
      [propertyId, checkInDate, checkOutDate, guestsCount];
}
