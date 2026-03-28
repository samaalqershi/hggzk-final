import 'package:equatable/equatable.dart';
import '../../../domain/entities/unit_type_field.dart';

abstract class UnitTypeFieldsState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFieldsState`.
  const UnitTypeFieldsState();

  @override
  List<Object?> get props => [];
}

class UnitTypeFieldsInitial extends UnitTypeFieldsState {}

class UnitTypeFieldsLoading extends UnitTypeFieldsState {}

class UnitTypeFieldsLoaded extends UnitTypeFieldsState {
  /// العربية: يخزن القيمة `fields`.
  final List<UnitTypeField> fields;

  final List<UnitTypeField> filteredFields;

  final String searchTerm;

  const UnitTypeFieldsLoaded({
    required this.fields,
    required this.filteredFields,
    this.searchTerm = '',
  });

  UnitTypeFieldsLoaded copyWith({
    List<UnitTypeField>? fields,
    List<UnitTypeField>? filteredFields,
    String? searchTerm,
  }) {
    return UnitTypeFieldsLoaded(
      fields: fields ?? this.fields,
      filteredFields: filteredFields ?? this.filteredFields,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object> get props => [fields, filteredFields, searchTerm];
}

class UnitTypeFieldsError extends UnitTypeFieldsState {
  /// العربية: يخزن القيمة `message`.
  final String message;

  const UnitTypeFieldsError({required this.message});

  @override
  List<Object> get props => [message];
}
