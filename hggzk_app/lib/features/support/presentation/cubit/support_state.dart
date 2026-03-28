import 'package:equatable/equatable.dart';

/// Shared state contract for the support form and its submission lifecycle.
///
/// العقد المشترك لحالة نموذج الدعم ودورة إرسال الرسالة.
abstract class SupportState extends Equatable {
  /// Base constructor for all concrete support states.
  ///
  /// المُنشئ الأساسي لكل الحالات الفعلية للدعم.
  const SupportState();

  /// The base state has no payload on its own.
  ///
  /// الحالة الأساسية لا تحمل بيانات بذاتها.
  @override
  List<Object?> get props => [];
}

/// No request is currently running and the form is ready for input.
///
/// لا يوجد طلب جارٍ والنموذج جاهز للإدخال.
class SupportInitial extends SupportState {}

/// The support message is currently being submitted to the backend.
///
/// رسالة الدعم تُرسل الآن إلى الخادم.
class SupportLoading extends SupportState {}

/// The backend accepted the request and returned a tracking reference.
///
/// الخادم قبل الطلب وأعاد رقمًا مرجعيًا للتتبع.
class SupportSuccess extends SupportState {
  /// Confirmation text shown to the user after the request succeeds.
  ///
  /// نص التأكيد الذي يُعرض بعد نجاح الإرسال.
  final String message;

  /// Tracking number that support staff can use to find the request.
  ///
  /// الرقم المرجعي الذي يستخدمه فريق الدعم لتتبع الطلب.
  final String referenceNumber;

  /// Stores both the visible confirmation and the internal tracking reference.
  ///
  /// يحتفظ برسالة التأكيد ورقم التتبع الداخلي معًا.
  const SupportSuccess({
    required this.message,
    required this.referenceNumber,
  });

  /// Equality depends on the confirmation text and reference number.
  ///
  /// تعتمد المساواة على نص التأكيد ورقم المرجع.
  @override
  List<Object?> get props => [message, referenceNumber];
}

/// The submission failed and the UI should surface the error message.
///
/// فشل الإرسال ويجب أن تعرض الواجهة رسالة الخطأ.
class SupportError extends SupportState {
  /// Error text that should be shown to the user or logged for debugging.
  ///
  /// نص الخطأ الذي يمكن عرضه للمستخدم أو تسجيله للتشخيص.
  final String message;

  /// Keeps the failure description from the support workflow.
  ///
  /// يحتفظ بوصف الفشل الصادر من مسار الدعم.
  const SupportError({required this.message});

  /// Equality depends only on the error message.
  ///
  /// تعتمد المساواة على رسالة الخطأ فقط.
  @override
  List<Object?> get props => [message];
}
