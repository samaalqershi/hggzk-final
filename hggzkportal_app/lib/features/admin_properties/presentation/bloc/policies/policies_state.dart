// lib/features/admin_properties/presentation/bloc/policies/policies_state.dart

part of 'policies_bloc.dart';

abstract class PoliciesState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PoliciesState`.
  const PoliciesState();
  @override
  List<Object?> get props => [];
}

class PoliciesInitial extends PoliciesState {}

class PoliciesLoading extends PoliciesState {}

class PoliciesLoaded extends PoliciesState {
  /// العربية: يخزن القيمة `policies`.
  final List<Policy> policies;
  const PoliciesLoaded(this.policies);
  @override
  List<Object> get props => [policies];
}

class PoliciesError extends PoliciesState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const PoliciesError(this.message);
  @override
  List<Object> get props => [message];
}

class PolicyCreating extends PoliciesState {}

class PolicyCreated extends PoliciesState {
  /// العربية: يخزن القيمة `policyId`.
  final String policyId;
  const PolicyCreated(this.policyId);
  @override
  List<Object> get props => [policyId];
}

class PolicyUpdating extends PoliciesState {}

class PolicyUpdated extends PoliciesState {}

class PolicyDeleting extends PoliciesState {}

class PolicyDeleted extends PoliciesState {}
