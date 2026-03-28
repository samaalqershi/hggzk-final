import 'package:equatable/equatable.dart';

/// العربية: يمثل مرفقًا يمكن ربطه بالعقارات مع بيانات العرض والحالة وعدد
/// العقارات التي يستخدمه.
/// with its display data, state, and usage counts.
class Amenity extends Equatable {
  /// العربية: المعرّف الفريد للمرفق.
  final String id;

  /// العربية: الاسم المعروض للمرفق داخل الإدارة.
  final String name;

  /// العربية: وصف يوضح وظيفة المرفق أو قيمة إضافته.
  final String description;

  /// العربية: الرمز البصري المستخدم لتمثيل المرفق.
  final String icon;

  /// العربية: تاريخ إنشاء السجل.
  final DateTime? createdAt;

  /// العربية: آخر وقت تم فيه تعديل السجل.
  final DateTime? updatedAt;

  /// العربية: يحدد ما إذا كان المرفق متاحًا للاستخدام حاليًا.
  final bool? isActive;

  /// العربية: عدد العقارات المرتبطة بهذا المرفق.
  final int? propertiesCount;

  /// العربية: متوسط الكلفة الإضافية عند تفعيل هذا المرفق.
  final double? averageExtraCost;

  /// العربية: يبني تمثيل المرفق مع الحالة والإحصائيات المرافقة له.
  /// state and metrics.
  const Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.propertiesCount = 0,
    this.averageExtraCost = 0,
  });

  /// العربية: ينشئ نسخة معدلة من المرفق مع الإبقاء على بقية الحقول كما هي.
  /// untouched.
  Amenity copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? propertiesCount,
    double? averageExtraCost,
  }) {
    return Amenity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      propertiesCount: propertiesCount ?? this.propertiesCount,
      averageExtraCost: averageExtraCost ?? this.averageExtraCost,
    );
  }

  /// العربية: يحدد حقول المساواة حتى تُقارن القيم لا المرجع فقط.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        createdAt,
        updatedAt,
        isActive,
        propertiesCount,
        averageExtraCost,
      ];
}

/// العربية: يجمع المؤشرات التشغيلية الخاصة بالمرافق لاستخدامها في لوحات
/// الإحصاء وتقارير الإدارة.
/// reports can present them consistently.
class AmenityStats {
  /// العربية: إجمالي عدد المرافق المعرفة.
  final int totalAmenities;

  /// العربية: عدد المرافق النشطة حاليًا.
  final int activeAmenities;

  /// العربية: مجموع الإسنادات بين المرافق والعقارات.
  final int totalAssignments;

  /// العربية: إجمالي الإيراد المرتبط بهذه المرافق.
  final double totalRevenue;

  /// العربية: توزيع الشعبية حسب اسم المرفق وعدد مرات الاستخدام.
  final Map<String, int> popularAmenities;

  /// العربية: الإيراد المنسوب لكل مرفق على حدة.
  final Map<String, double> revenueByAmenity;

  /// العربية: يبني حزمة الإحصاءات المستخدمة في واجهات الإدارة.
  const AmenityStats({
    required this.totalAmenities,
    required this.activeAmenities,
    required this.totalAssignments,
    required this.totalRevenue,
    required this.popularAmenities,
    required this.revenueByAmenity,
  });
}
