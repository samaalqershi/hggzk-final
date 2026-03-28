import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// يعبّر عن عملية مجال قابلة للاستدعاء تعيد نتيجة نجاح أو فشل بشكل موحد.
/// Represents a callable domain operation that always returns a success/failure result.
abstract class UseCase<Type, Params> {
  /// Carries out the domain action while keeping input and output types explicit.
  /// ينفذ عملية المجال مع إبقاء نوع المدخلات والمخرجات واضحين.
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker object for use cases that do not need any input parameters.
/// كائن إشارة يستخدم مع الـ use cases التي لا تحتاج إلى مدخلات.
class NoParams extends Equatable {
  /// يعيد قائمة فارغة لأن هذا الكائن لا يحمل أي حمولة منطقية للمقارنة.
  /// Returns an empty list because this marker object carries no logical
  /// payload for equality.
  @override
  List<Object> get props => [];
}
