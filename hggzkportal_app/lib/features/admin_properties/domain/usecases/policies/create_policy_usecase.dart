// lib/features/admin_properties/domain/usecases/policies/create_policy_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import 'package:hggzkportal/core/usecases/usecase.dart';
import '../../entities/policy.dart';
import '../../repositories/policies_repository.dart';

class CreatePolicyParams {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final PolicyType policyType;
  final String description;
  final String? descriptionEn;
  final String rules;
  final String? rulesEn;
  CreatePolicyParams({
    required this.propertyId,
    required this.policyType,
    required this.description,
    this.descriptionEn,
    required this.rules,
    this.rulesEn,
  });
  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'type': _policyTypeToString(policyType),
        'policyType': _policyTypeToString(policyType),
        'description': description,
        if (descriptionEn != null) 'descriptionEn': descriptionEn,
        'rules': rules,
        if (rulesEn != null) 'rulesEn': rulesEn,
      };

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

class CreatePolicyUseCase implements UseCase<String, CreatePolicyParams> {
  /// العربية: يخزن القيمة `repository`.
  final PoliciesRepository repository;
  CreatePolicyUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(CreatePolicyParams params) async {
    return await repository.createPolicy(params.toJson());
  }
}
