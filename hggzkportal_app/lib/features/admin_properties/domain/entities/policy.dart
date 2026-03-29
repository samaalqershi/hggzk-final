// lib/features/admin_properties/domain/entities/policy.dart

import 'package:equatable/equatable.dart';

enum PolicyType {
  cancellation,
  checkIn,
  checkOut,
  payment,
  smoking,
  pets,
  damage,
  other,
}

class Policy extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;
  final String propertyId;
  final PolicyType policyType;
  final String description;
  final String? descriptionEn;
  final String rules;
  final String? rulesEn;
  final bool isActive;
  final DateTime? effectiveDate;
  const Policy({
    required this.id,
    required this.propertyId,
    required this.policyType,
    required this.description,
    this.descriptionEn,
    required this.rules,
    this.rulesEn,
    this.isActive = true,
    this.effectiveDate,
  });
  String get policyTypeLabel {
    switch (policyType) {
      case PolicyType.cancellation:
        return 'سياسة الإلغاء';
      case PolicyType.checkIn:
        return 'تسجيل الدخول';
      case PolicyType.checkOut:
        return 'تسجيل الخروج';
      case PolicyType.payment:
        return 'الدفع';
      case PolicyType.smoking:
        return 'التدخين';
      case PolicyType.pets:
        return 'الحيوانات الأليفة';
      case PolicyType.damage:
        return 'الأضرار';
      case PolicyType.other:
        return 'أخرى';
    }
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        policyType,
        description,
        descriptionEn,
        rules,
        rulesEn,
        isActive,
        effectiveDate,
      ];
}
