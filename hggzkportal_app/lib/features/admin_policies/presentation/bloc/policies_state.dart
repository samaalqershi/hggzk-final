import 'package:equatable/equatable.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/policy.dart';

abstract class PoliciesState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PoliciesState`.
  const PoliciesState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class PoliciesInitial extends PoliciesState {
  /// العربية: ينشئ مثيلًا جديدًا من `PoliciesInitial`.
  const PoliciesInitial();
}

/// جاري التحميل
class PoliciesLoading extends PoliciesState {
  /// العربية: ينشئ مثيلًا جديدًا من `PoliciesLoading`.
  const PoliciesLoading();
}

/// تم تحميل السياسات بنجاح
class PoliciesLoaded extends PoliciesState {
  /// العربية: يخزن القيمة `policies`.
  final PaginatedResult<Policy> policies;

  final String? searchTerm;

  final String? propertyId;

  final PolicyType? policyType;

  final Policy? selectedPolicy;

  final PolicyStats? stats;

  const PoliciesLoaded({
    required this.policies,
    this.searchTerm,
    this.propertyId,
    this.policyType,
    this.selectedPolicy,
    this.stats,
  });

  PoliciesLoaded copyWith({
    PaginatedResult<Policy>? policies,
    String? searchTerm,
    String? propertyId,
    PolicyType? policyType,
    Policy? selectedPolicy,
    PolicyStats? stats,
    bool clearSelectedPolicy = false,
  }) {
    return PoliciesLoaded(
      policies: policies ?? this.policies,
      searchTerm: searchTerm ?? this.searchTerm,
      propertyId: propertyId ?? this.propertyId,
      policyType: policyType ?? this.policyType,
      selectedPolicy:
          clearSelectedPolicy ? null : (selectedPolicy ?? this.selectedPolicy),
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        policies,
        searchTerm,
        propertyId,
        policyType,
        selectedPolicy,
        stats,
      ];
}

/// خطأ في تحميل السياسات
class PoliciesError extends PoliciesState {
  /// العربية: يخزن القيمة `message`.
  final String message;

  const PoliciesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// جاري تنفيذ عملية على سياسة
class PolicyOperationInProgress extends PoliciesState {
  /// العربية: يخزن القيمة `operation`.
  final String operation;

  final String? policyId;

  const PolicyOperationInProgress({
    required this.operation,
    this.policyId,
  });

  @override
  List<Object?> get props => [operation, policyId];
}

/// نجاح عملية على سياسة
class PolicyOperationSuccess extends PoliciesState {
  /// العربية: يخزن القيمة `message`.
  final String message;

  final String? policyId;

  const PolicyOperationSuccess({
    required this.message,
    this.policyId,
  });

  @override
  List<Object?> get props => [message, policyId];
}

/// فشل عملية على سياسة
class PolicyOperationFailure extends PoliciesState {
  /// العربية: يخزن القيمة `message`.
  final String message;

  final String? policyId;

  const PolicyOperationFailure({
    required this.message,
    this.policyId,
  });

  @override
  List<Object?> get props => [message, policyId];
}

/// تم تحميل سياسات عقار معين
class PolicyByPropertyLoaded extends PoliciesState {
  /// العربية: يخزن القيمة `policies`.
  final List<Policy> policies;

  final String propertyId;

  const PolicyByPropertyLoaded({
    required this.policies,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [policies, propertyId];
}

/// تم تحميل سياسة واحدة
class PolicyDetailsLoaded extends PoliciesState {
  /// العربية: يخزن القيمة `policy`.
  final Policy policy;

  const PolicyDetailsLoaded({required this.policy});

  @override
  List<Object?> get props => [policy];
}
