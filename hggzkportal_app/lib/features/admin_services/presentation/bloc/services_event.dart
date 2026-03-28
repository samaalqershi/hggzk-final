import 'package:equatable/equatable.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/pricing_model.dart';

/// 📨 Events للخدمات
abstract class ServicesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `ServicesEvent`.
  const ServicesEvent();
  @override
  List<Object?> get props => [];
}

/// تحميل الخدمات
class LoadServicesEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String? propertyId;
  final String? serviceType;
  final int? pageNumber;
  final int? pageSize;
  const LoadServicesEvent({
    this.propertyId,
    this.serviceType,
    this.pageNumber,
    this.pageSize,
  });
  @override
  List<Object?> get props => [propertyId, serviceType, pageNumber, pageSize];
}

/// إنشاء خدمة جديدة
class CreateServiceEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final String name;
  final Money price;
  final PricingModel pricingModel;
  final String icon;
  final String? description;
  const CreateServiceEvent({
    required this.propertyId,
    required this.name,
    required this.price,
    required this.pricingModel,
    required this.icon,
    this.description,
  });
  @override
  List<Object?> get props =>
      [propertyId, name, price, pricingModel, icon, description];
}

/// تحديث خدمة
class UpdateServiceEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;
  final String? name;
  final Money? price;
  final PricingModel? pricingModel;
  final String? icon;
  final String? description;
  const UpdateServiceEvent({
    required this.serviceId,
    this.name,
    this.price,
    this.pricingModel,
    this.icon,
    this.description,
  });
  @override
  List<Object?> get props =>
      [serviceId, name, price, pricingModel, icon, description];
}

/// حذف خدمة
class DeleteServiceEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;
  const DeleteServiceEvent(this.serviceId);
  @override
  List<Object> get props => [serviceId];
}

/// جلب تفاصيل خدمة
class LoadServiceDetailsEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;
  const LoadServiceDetailsEvent(this.serviceId);
  @override
  List<Object> get props => [serviceId];
}

/// تحديد عقار
class SelectPropertyEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String? propertyId;
  const SelectPropertyEvent(this.propertyId);
  @override
  List<Object?> get props => [propertyId];
}

/// البحث في الخدمات
class SearchServicesEvent extends ServicesEvent {
  /// العربية: يخزن القيمة `query`.
  final String query;
  const SearchServicesEvent(this.query);
  @override
  List<Object> get props => [query];
}

/// تحميل المزيد من الخدمات (للباجنيشن اللانهائي)
class LoadMoreServicesEvent extends ServicesEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `LoadMoreServicesEvent`.
  const LoadMoreServicesEvent();
}
