import 'service.dart';

/// 📋 Entity لتفاصيل الخدمة
class ServiceDetails extends Service {
  /// العربية: يخزن القيمة `createdAt`.
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? description;
  const ServiceDetails({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    required super.name,
    required super.price,
    required super.pricingModel,
    required super.icon,
    this.createdAt,
    this.updatedAt,
    this.description,
  });
  @override
  List<Object?> get props => [
        ...super.props,
        createdAt,
        updatedAt,
        description,
      ];
}
