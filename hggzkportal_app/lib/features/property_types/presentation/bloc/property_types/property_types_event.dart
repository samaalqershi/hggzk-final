import 'package:equatable/equatable.dart';

/// Base event for canonical property-type presentation flows.
/// الحدث الأساسي لتدفقات العرض الخاصة بميزة أنواع العقار القانونية.
abstract class PropertyTypesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyTypesEvent`.
  const PropertyTypesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyTypesEvent extends PropertyTypesEvent {
  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;

  final int pageSize;

  const LoadPropertyTypesEvent({
    this.pageNumber = 1,
    this.pageSize = 1000,
  });

  @override
  List<Object> get props => [pageNumber, pageSize];
}

class CreatePropertyTypeEvent extends PropertyTypesEvent {
  /// العربية: يخزن القيمة `name`.
  final String name;

  final String description;

  final List<String> defaultAmenities;

  final String icon;

  const CreatePropertyTypeEvent({
    required this.name,
    required this.description,
    required this.defaultAmenities,
    required this.icon,
  });

  @override
  List<Object> get props => [name, description, defaultAmenities, icon];
}

class UpdatePropertyTypeEvent extends PropertyTypesEvent {
  /// العربية: يخزن القيمة `propertyTypeId`.
  final String propertyTypeId;

  final String name;

  final String description;

  final List<String> defaultAmenities;

  final String icon;

  const UpdatePropertyTypeEvent({
    required this.propertyTypeId,
    required this.name,
    required this.description,
    required this.defaultAmenities,
    required this.icon,
  });

  @override
  List<Object> get props =>
      [propertyTypeId, name, description, defaultAmenities, icon];
}

class DeletePropertyTypeEvent extends PropertyTypesEvent {
  /// العربية: يخزن القيمة `propertyTypeId`.
  final String propertyTypeId;

  const DeletePropertyTypeEvent({required this.propertyTypeId});

  @override
  List<Object> get props => [propertyTypeId];
}

class SelectPropertyTypeEvent extends PropertyTypesEvent {
  /// العربية: يخزن القيمة `propertyTypeId`.
  final String? propertyTypeId;

  const SelectPropertyTypeEvent({this.propertyTypeId});

  @override
  List<Object?> get props => [propertyTypeId];
}
