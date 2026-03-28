import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/cities_repository.dart';

/// Updates an existing city while keeping the rename flow explicit.
///
/// يحدّث مدينة موجودة مع إبقاء مسار إعادة التسمية واضحًا.
class UpdateCityUseCase implements UseCase<City, UpdateCityParams> {
  /// Repository used to apply the update.
  ///
  /// المستودع المستخدم لتنفيذ التحديث.
  final CitiesRepository repository;

  /// Connects the use case to the repository layer.
  ///
  /// يربط هذا use case بطبقة المستودع.
  UpdateCityUseCase(this.repository);

  @override

  /// Replaces the existing city record using the old name as the lookup key.
  ///
  /// يستبدل سجل المدينة الحالي باستخدام الاسم القديم كمفتاح للبحث.
  Future<Either<Failure, City>> call(UpdateCityParams params) async {
    return await repository.updateCity(params.oldName, params.city);
  }
}

/// Parameters for renaming or replacing one city record.
///
/// معاملات إعادة تسمية أو استبدال سجل مدينة واحد.
class UpdateCityParams extends Equatable {
  /// Previous city name used to locate the record before replacing it.
  ///
  /// اسم المدينة السابق المستخدم للوصول إلى السجل قبل استبداله.
  final String oldName;

  /// Replacement city payload that should be stored instead.
  ///
  /// بيانات المدينة البديلة التي يجب حفظها.
  final City city;

  /// Captures the rename target and the new payload in one immutable object.
  ///
  /// يجمع هدف إعادة التسمية والبيانات الجديدة في كائن ثابت واحد.
  const UpdateCityParams({
    required this.oldName,
    required this.city,
  });

  @override

  /// Comparison keys for the original name and replacement city payload.
  ///
  /// مفاتيح المقارنة للاسم الأصلي وبيانات المدينة البديلة.
  List<Object?> get props => [oldName, city];
}
