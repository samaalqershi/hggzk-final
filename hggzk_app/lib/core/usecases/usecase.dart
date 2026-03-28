import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Provides the shared contract for application use cases so feature modules
/// can expose one clear entry point per business action.
/// يعرّف العقدة المشتركة لحالات الاستخدام في التطبيق حتى توفّر كل ميزة نقطة
/// دخول واضحة لكل سلوك تجاري.
abstract class UseCase<Type, Params> {
  /// Runs the business action represented by the use case and returns either a
  /// domain failure or the expected result.
  /// ينفّذ السلوك التجاري الذي تمثله حالة الاستخدام ويعيد إما فشلًا نطاقيًا أو
  /// النتيجة المتوقعة.
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker object used when a use case does not require any caller-provided
/// input but still benefits from a consistent callable signature.
/// كائن إشارة يُستخدم عندما لا تحتاج حالة الاستخدام إلى مدخلات من المستدعي،
/// مع الحفاظ على توقيع موحّد لجميع حالات الاستخدام.
class NoParams extends Equatable {
  /// Empty because all `NoParams` instances should be considered equivalent.
  /// فارغة لأن جميع كائنات `NoParams` يجب أن تُعامل على أنها متكافئة.
  @override
  List<Object> get props => [];
}
