import 'package:equatable/equatable.dart';

abstract class UnitTypeFieldsEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFieldsEvent`.
  const UnitTypeFieldsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitTypeFieldsEvent extends UnitTypeFieldsEvent {
  /// العربية: يخزن القيمة `unitTypeId`.
  final String unitTypeId;

  const LoadUnitTypeFieldsEvent({required this.unitTypeId});

  @override
  List<Object> get props => [unitTypeId];
}

class SearchFieldsEvent extends UnitTypeFieldsEvent {
  /// العربية: يخزن القيمة `searchTerm`.
  final String searchTerm;

  const SearchFieldsEvent({required this.searchTerm});

  @override
  List<Object> get props => [searchTerm];
}

class CreateFieldEvent extends UnitTypeFieldsEvent {
  /// العربية: يخزن القيمة `unitTypeId`.
  final String unitTypeId;

  final Map<String, dynamic> fieldData;

  const CreateFieldEvent({
    required this.unitTypeId,
    required this.fieldData,
  });

  @override
  List<Object> get props => [unitTypeId, fieldData];
}

class UpdateFieldEvent extends UnitTypeFieldsEvent {
  /// العربية: يخزن القيمة `fieldId`.
  final String fieldId;

  final Map<String, dynamic> fieldData;

  const UpdateFieldEvent({
    required this.fieldId,
    required this.fieldData,
  });

  @override
  List<Object> get props => [fieldId, fieldData];
}

class DeleteFieldEvent extends UnitTypeFieldsEvent {
  /// العربية: يخزن القيمة `fieldId`.
  final String fieldId;

  const DeleteFieldEvent({required this.fieldId});

  @override
  List<Object> get props => [fieldId];
}
