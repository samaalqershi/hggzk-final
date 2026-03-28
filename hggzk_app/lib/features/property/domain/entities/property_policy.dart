import 'package:equatable/equatable.dart';

/// Represents one policy rule displayed on the property detail page.
/// يمثل قاعدة سياسة واحدة تظهر في صفحة تفاصيل العقار.
class PropertyPolicy extends Equatable {
  /// Backend identifier of the policy record.
  /// المعرّف الخلفي لسجل السياسة.
  final String id;

  /// Internal policy type used to group similar rules.
  /// نوع السياسة الداخلي المستخدم لتجميع القواعد المتشابهة.
  final String policyType;

  /// Human-readable policy text shown to the user.
  /// نص السياسة المقروء المعروض للمستخدم.
  final String policyContent;

  /// Marks policies that should still be visible in the UI.
  /// يحدد السياسات التي يجب أن تظل ظاهرة في الواجهة.
  final bool isActive;

  /// Short category label used by the presentation layer.
  /// وسم فئة قصير تستخدمه طبقة العرض.
  final String type;

  /// Additional explanation or subtitle for the policy.
  /// شرح إضافي أو عنوان فرعي للسياسة.
  final String description;

  /// Backend rule metadata that can drive conditional rendering.
  /// بيانات قواعد الخادم التي قد تقود العرض الشرطي.
  final Map<String, dynamic> rules;

  /// Builds an immutable policy record for property details.
  /// ينشئ سجل سياسة ثابتًا لتفاصيل العقار.
  const PropertyPolicy({
    required this.id,
    required this.policyType,
    required this.policyContent,
    required this.isActive,
    required this.type,
    required this.description,
    required this.rules,
  });

  /// Keeps equality aligned with the policy payload.
  /// يحافظ على ثبات المقارنة مع حمولة السياسة.
  @override
  List<Object?> get props => [
        id,
        policyType,
        policyContent,
        isActive,
        type,
        description,
        rules,
      ];
}
