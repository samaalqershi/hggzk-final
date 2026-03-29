import 'package:equatable/equatable.dart';
import 'money.dart';
import 'pricing_model.dart';

class Service extends Equatable {
  final String id;
  final String propertyId;
  final String propertyName;
  final String? propertyNameEn;
  final String name;
  final String? nameEn;
  final Money price;
  final PricingModel pricingModel;
  final String icon;
  final String? description;
  final String? descriptionEn;
  const Service({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    this.propertyNameEn,
    required this.name,
    this.nameEn,
    required this.price,
    required this.pricingModel,
    required this.icon,
    this.description,
    this.descriptionEn,
  });
  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        propertyNameEn,
        name,
        nameEn,
        price,
        pricingModel,
        icon,
        description,
        descriptionEn,
      ];
}
