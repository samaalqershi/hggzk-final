import 'package:equatable/equatable.dart';

/// العربية: تغطي هذه الحالة دورة إرسال رسالة الدعم من الخمول إلى النجاح أو
/// الخطأ حتى تستطيع الواجهة أن تعرض ما يحدث للمستخدم بدقة.
/// Covers the support-message flow from idle to success or error so
/// the UI can mirror the submission lifecycle accurately.
abstract class SupportState extends Equatable {
  /// العربية: تجعل حالات الدعم قابلة للمقارنة اعتمادًا على بياناتها فقط.
  /// Makes support states comparable purely by the data they carry.
  const SupportState();

  /// العربية: لا توجد حقول مشتركة في القاعدة، لذلك تبقى المقارنة فارغة.
  /// No shared fields exist at the base level, so the comparison stays empty.
  @override
  List<Object?> get props => [];
}

/// العربية: حالة الاستعداد قبل كتابة رسالة الدعم أو إرسالها.
/// Idle state shown before the user starts composing or sending a support request.
class SupportInitial extends SupportState {}

/// العربية: تعني أن رسالة الدعم تُرسل الآن أو أن النظام يجمع بياناتها
/// المرافقة.
/// Indicates that the support message is being sent or that companion metadata is still being collected.
class SupportLoading extends SupportState {}

/// العربية: تمثل نجاح الإرسال مع الاحتفاظ برسالة التأكيد والرقم المرجعي.
/// Represents a successful send while keeping the confirmation text and reference number.
class SupportSuccess extends SupportState {
  /// العربية: النص الذي يؤكد نجاح العملية للمستخدم.
  /// Confirmation text shown to the user.
  final String message;

  /// العربية: الرقم المرجعي الذي يفيد عند المتابعة مع الدعم.
  /// Reference number useful when following up with support.
  final String referenceNumber;

  /// العربية: يسجل نتيجة الإرسال الناجحة مع البيانات المرجعية.
  /// Records the successful send result together with its reference data.
  const SupportSuccess({
    required this.message,
    required this.referenceNumber,
  });

  /// العربية: تعتمد المقارنة على الرسالة والمرجع لأنهما يحددان النتيجة الفعلية.
  /// Equality depends on the message and reference number because they define the actual result.
  @override
  List<Object?> get props => [message, referenceNumber];
}

/// العربية: تمثل تعذر إرسال الرسالة مع رسالة توضيحية مناسبة للواجهة.
/// Represents a failed send with a user-facing explanation.
class SupportError extends SupportState {
  /// العربية: سبب الفشل أو الرسالة التي يجب عرضها.
  /// Failure reason or the message that should be shown.
  final String message;

  /// العربية: يسجل الفشل مع النص المرافق له.
  /// Records the failure together with its message.
  const SupportError({required this.message});

  /// العربية: تعتمد المقارنة على رسالة الخطأ نفسها.
  /// Equality depends on the error message itself.
  @override
  List<Object> get props => [message];
}
