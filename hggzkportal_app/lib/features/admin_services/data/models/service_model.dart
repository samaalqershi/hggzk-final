import '../../domain/entities/service.dart';
import '../../domain/entities/pricing_model.dart';
import 'money_model.dart';

/// 🛎️ Model للخدمة
class ServiceModel extends Service {
  /// العربية: ينشئ مثيلًا جديدًا من `ServiceModel`.
  const ServiceModel({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    super.propertyNameEn,
    required super.name,
    super.nameEn,
    required super.price,
    required super.pricingModel,
    required super.icon,
    super.description,
    super.descriptionEn,
  });
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle pricing model from backend format
    final pricingModelData = json['pricingModel'];
    PricingModel pricingModel;

    if (pricingModelData is Map) {
      pricingModel = PricingModel.fromValue(pricingModelData.keys.first);
    } else {
      pricingModel =
          PricingModel.fromValue('${pricingModelData ?? 'PerBooking'}');
    }

    return ServiceModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyNameEn: json['propertyNameEn'],
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      price: MoneyModel.fromJson(json['price'] ?? {}),
      pricingModel: pricingModel,
      icon: json['icon'] ?? 'room_service',
      description: json['description'],
      descriptionEn: json['descriptionEn'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyNameEn': propertyNameEn,
      'name': name,
      'nameEn': nameEn,
      'price': MoneyModel(
        amount: price.amount,
        currency: price.currency,
        formattedAmount: price.formattedAmount,
      ).toJson(),
      'pricingModel': pricingModel.value,
      'icon': icon,
      if (description != null) 'description': description,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
    };
  }

  Service toEntity() => Service(
        id: id,
        propertyId: propertyId,
        propertyName: propertyName,
        propertyNameEn: propertyNameEn,
        name: name,
        nameEn: nameEn,
        price: price,
        pricingModel: pricingModel,
        icon: icon,
        description: description,
        descriptionEn: descriptionEn,
      );
}
