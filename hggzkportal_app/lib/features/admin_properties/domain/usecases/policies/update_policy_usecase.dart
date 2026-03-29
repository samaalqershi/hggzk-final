// lib/features/admin_properties/domain/usecases/policies/update_policy_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/policy.dart';
import '../../repositories/policies_repository.dart';

class UpdatePolicyParams {
  /// العربية: يخزن القيمة `policyId`.
  final String policyId;
  final PolicyType? policyType;
  final String? description;
  final String? descriptionEn;
  final String? rules;
  final String? rulesEn;
  UpdatePolicyParams({
    required this.policyId,
    this.policyType,
    this.description,
    this.descriptionEn,
    this.rules,
    this.rulesEn,
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (policyType != null) {
      final apiValue = _policyTypeToString(policyType!);
      data['type'] = apiValue;
      data['policyType'] = apiValue;
    }
    if (description != null) data['description'] = description;
    if (descriptionEn != null) data['descriptionEn'] = descriptionEn;
    if (rules != null) data['rules'] = rules;
    if (rulesEn != null) data['rulesEn'] = rulesEn;
    return data;
  }

  static String _policyTypeToString(PolicyType type) {
    switch (type) {
      case PolicyType.cancellation:
        return 'Cancellation';
      case PolicyType.checkIn:
        return 'CheckIn';
      case PolicyType.checkOut:
        return 'CheckOut';
      case PolicyType.payment:
        return 'Payment';
      case PolicyType.smoking:
        return 'Smoking';
      case PolicyType.pets:
        return 'Pets';
      case PolicyType.damage:
        return 'Damage';
      case PolicyType.other:
        return 'Other';
    }
  }
}

class UpdatePolicyUseCase implements UseCase<bool, UpdatePolicyParams> {
  /// العربية: يخزن القيمة `repository`.
  final PoliciesRepository repository;
  UpdatePolicyUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(UpdatePolicyParams params) async {
    return await repository.updatePolicy(params.policyId, params.toJson());
  }
}
