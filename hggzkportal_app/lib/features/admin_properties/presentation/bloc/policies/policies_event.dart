// lib/features/admin_properties/presentation/bloc/policies/policies_event.dart

part of 'policies_bloc.dart';

abstract class PoliciesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PoliciesEvent`.
  const PoliciesEvent();
  @override
  List<Object?> get props => [];
}

class LoadPoliciesEvent extends PoliciesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String? propertyId;
  final PolicyType? policyType;
  const LoadPoliciesEvent({
    this.propertyId,
    this.policyType,
  });
  @override
  List<Object?> get props => [propertyId, policyType];
}

class CreatePolicyEvent extends PoliciesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final PolicyType policyType;
  final String description;
  final String? descriptionEn;
  final String rules;
  final String? rulesEn;
  const CreatePolicyEvent({
    required this.propertyId,
    required this.policyType,
    required this.description,
    this.descriptionEn,
    required this.rules,
    this.rulesEn,
  });
  @override
  List<Object?> get props =>
      [propertyId, policyType, description, descriptionEn, rules, rulesEn];
}

class UpdatePolicyEvent extends PoliciesEvent {
  /// العربية: يخزن القيمة `policyId`.
  final String policyId;
  final PolicyType? policyType;
  final String? description;
  final String? descriptionEn;
  final String? rules;
  final String? rulesEn;
  const UpdatePolicyEvent({
    required this.policyId,
    this.policyType,
    this.description,
    this.descriptionEn,
    this.rules,
    this.rulesEn,
  });
  @override
  List<Object?> get props =>
      [policyId, policyType, description, descriptionEn, rules, rulesEn];
}

class DeletePolicyEvent extends PoliciesEvent {
  /// العربية: يخزن القيمة `policyId`.
  final String policyId;
  const DeletePolicyEvent(this.policyId);
  @override
  List<Object> get props => [policyId];
}
