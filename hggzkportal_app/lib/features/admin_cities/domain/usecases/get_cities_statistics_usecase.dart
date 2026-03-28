import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cities_repository.dart';

/// Requests the analytics snapshot used by the cities dashboard cards.
///
/// يطلب لقطة التحليلات التي تعتمد عليها بطاقات لوحة المدن.
class GetCitiesStatisticsUseCase
    implements UseCase<Map<String, dynamic>, GetCitiesStatsParams> {
  /// Repository that aggregates the backend statistics.
  ///
  /// المستودع الذي يجمع الإحصائيات من الخادم.
  final CitiesRepository repository;

  /// Creates the analytics query boundary for the cities dashboard.
  ///
  /// ينشئ حد الاستعلام التحليلي الخاص بلوحة المدن.
  GetCitiesStatisticsUseCase(this.repository);

  @override

  /// Forwards the requested date range to the repository and returns dashboard metrics.
  ///
  /// يمرر نطاق التاريخ المطلوب إلى المستودع ويعيد مؤشرات لوحة المعلومات.
  Future<Either<Failure, Map<String, dynamic>>> call(
      GetCitiesStatsParams params) async {
    return await repository.getCitiesStatistics(
        startDate: params.startDate, endDate: params.endDate);
  }
}

/// Parameters that define the time window for city statistics.
///
/// معاملات تحدد النافذة الزمنية لإحصائيات المدن.
class GetCitiesStatsParams {
  /// Inclusive lower bound of the analytics window.
  ///
  /// الحد الأدنى الشامل لنافذة التحليلات.
  final DateTime? startDate;

  /// Inclusive upper bound of the analytics window.
  ///
  /// الحد الأعلى الشامل لنافذة التحليلات.
  final DateTime? endDate;

  /// Creates a statistics request for the optional date window.
  ///
  /// ينشئ طلب إحصائيات لنافذة التاريخ الاختيارية.
  GetCitiesStatsParams({this.startDate, this.endDate});
}
