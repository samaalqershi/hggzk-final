import 'package:equatable/equatable.dart';

/// 📋 Entity للسياسة
class Policy extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  final String propertyId;

  final String? propertyName;

  final PolicyType type;

  final String description;

  final String? descriptionEn;

  final String? rules;

  final String? rulesEn;

  final int cancellationWindowDays;

  final bool requireFullPaymentBeforeConfirmation;

  final double minimumDepositPercentage;

  final int minHoursBeforeCheckIn;

  final bool? cancellationFreeCancel;

  final bool? cancellationFullRefund;

  final int? cancellationRefundPercentage;

  final int? cancellationDaysBeforeCheckIn;

  final int? cancellationHoursBeforeCheckIn;

  final bool? cancellationNonRefundable;

  final String? cancellationPenaltyAfterDeadline;

  final bool? paymentDepositRequired;

  final bool? paymentFullPaymentRequired;

  final double? paymentDepositPercentage;

  final bool? paymentAcceptCash;

  final bool? paymentAcceptCard;

  final bool? paymentPayAtProperty;

  final bool? paymentCashPreferred;

  final List<String>? paymentAcceptedMethods;

  final String? checkInTime;

  final String? checkOutTime;

  final String? checkInFrom;

  final String? checkInUntil;

  final bool? checkInFlexible;

  final bool? checkInFlexibleCheckIn;

  final bool? checkInRequiresCoordination;

  final bool? checkInContactOwner;

  final String? checkInEarlyCheckInNote;

  final String? checkInEarlyCheckInNoteEn;

  final String? checkInLateCheckOutNote;

  final String? checkInLateCheckOutFee;

  final bool? childrenAllowed;

  final int? childrenFreeUnderAge;

  final int? childrenHalfPriceUnderAge;

  final int? childrenMaxChildrenPerRoom;

  final int? childrenMaxChildren;

  final String? childrenCribsNote;

  final String? childrenCribsNoteEn;

  final bool? childrenPlaygroundAvailable;

  final bool? childrenKidsMenuAvailable;

  final bool? petsAllowed;

  final String? petsReason;

  final String? petsReasonEn;

  final double? petsFeeAmount;

  final String? petsMaxWeight;

  final bool? petsRequiresApproval;

  final bool? petsNoFees;

  final bool? petsPetFriendly;

  final bool? petsOutdoorSpace;

  final bool? petsStrict;

  final bool? modificationAllowed;

  final int? modificationFreeModificationHours;

  final String? modificationFeesAfter;

  final bool? modificationFlexible;

  final String? modificationReason;

  final String? modificationReasonEn;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final bool? isActive;

  const Policy({
    required this.id,
    required this.propertyId,
    this.propertyName,
    required this.type,
    required this.description,
    this.descriptionEn,
    this.rules,
    this.rulesEn,
    this.cancellationWindowDays = 0,
    this.requireFullPaymentBeforeConfirmation = false,
    this.minimumDepositPercentage = 0.0,
    this.minHoursBeforeCheckIn = 0,
    this.cancellationFreeCancel,
    this.cancellationFullRefund,
    this.cancellationRefundPercentage,
    this.cancellationDaysBeforeCheckIn,
    this.cancellationHoursBeforeCheckIn,
    this.cancellationNonRefundable,
    this.cancellationPenaltyAfterDeadline,
    this.paymentDepositRequired,
    this.paymentFullPaymentRequired,
    this.paymentDepositPercentage,
    this.paymentAcceptCash,
    this.paymentAcceptCard,
    this.paymentPayAtProperty,
    this.paymentCashPreferred,
    this.paymentAcceptedMethods,
    this.checkInTime,
    this.checkOutTime,
    this.checkInFrom,
    this.checkInUntil,
    this.checkInFlexible,
    this.checkInFlexibleCheckIn,
    this.checkInRequiresCoordination,
    this.checkInContactOwner,
    this.checkInEarlyCheckInNote,
    this.checkInEarlyCheckInNoteEn,
    this.checkInLateCheckOutNote,
    this.checkInLateCheckOutFee,
    this.childrenAllowed,
    this.childrenFreeUnderAge,
    this.childrenHalfPriceUnderAge,
    this.childrenMaxChildrenPerRoom,
    this.childrenMaxChildren,
    this.childrenCribsNote,
    this.childrenCribsNoteEn,
    this.childrenPlaygroundAvailable,
    this.childrenKidsMenuAvailable,
    this.petsAllowed,
    this.petsReason,
    this.petsReasonEn,
    this.petsFeeAmount,
    this.petsMaxWeight,
    this.petsRequiresApproval,
    this.petsNoFees,
    this.petsPetFriendly,
    this.petsOutdoorSpace,
    this.petsStrict,
    this.modificationAllowed,
    this.modificationFreeModificationHours,
    this.modificationFeesAfter,
    this.modificationFlexible,
    this.modificationReason,
    this.modificationReasonEn,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Policy copyWith({
    String? id,
    String? propertyId,
    String? propertyName,
    PolicyType? type,
    String? description,
    String? descriptionEn,
    String? rules,
    String? rulesEn,
    int? cancellationWindowDays,
    bool? requireFullPaymentBeforeConfirmation,
    double? minimumDepositPercentage,
    int? minHoursBeforeCheckIn,
    bool? cancellationFreeCancel,
    bool? cancellationFullRefund,
    int? cancellationRefundPercentage,
    int? cancellationDaysBeforeCheckIn,
    int? cancellationHoursBeforeCheckIn,
    bool? cancellationNonRefundable,
    String? cancellationPenaltyAfterDeadline,
    bool? paymentDepositRequired,
    bool? paymentFullPaymentRequired,
    double? paymentDepositPercentage,
    bool? paymentAcceptCash,
    bool? paymentAcceptCard,
    bool? paymentPayAtProperty,
    bool? paymentCashPreferred,
    List<String>? paymentAcceptedMethods,
    String? checkInTime,
    String? checkOutTime,
    String? checkInFrom,
    String? checkInUntil,
    bool? checkInFlexible,
    bool? checkInFlexibleCheckIn,
    bool? checkInRequiresCoordination,
    bool? checkInContactOwner,
    String? checkInEarlyCheckInNote,
    String? checkInEarlyCheckInNoteEn,
    String? checkInLateCheckOutNote,
    String? checkInLateCheckOutFee,
    bool? childrenAllowed,
    int? childrenFreeUnderAge,
    int? childrenHalfPriceUnderAge,
    int? childrenMaxChildrenPerRoom,
    int? childrenMaxChildren,
    String? childrenCribsNote,
    String? childrenCribsNoteEn,
    bool? childrenPlaygroundAvailable,
    bool? childrenKidsMenuAvailable,
    bool? petsAllowed,
    String? petsReason,
    String? petsReasonEn,
    double? petsFeeAmount,
    String? petsMaxWeight,
    bool? petsRequiresApproval,
    bool? petsNoFees,
    bool? petsPetFriendly,
    bool? petsOutdoorSpace,
    bool? petsStrict,
    bool? modificationAllowed,
    int? modificationFreeModificationHours,
    String? modificationFeesAfter,
    bool? modificationFlexible,
    String? modificationReason,
    String? modificationReasonEn,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Policy(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      type: type ?? this.type,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      rules: rules ?? this.rules,
      rulesEn: rulesEn ?? this.rulesEn,
      cancellationWindowDays:
          cancellationWindowDays ?? this.cancellationWindowDays,
      requireFullPaymentBeforeConfirmation:
          requireFullPaymentBeforeConfirmation ??
              this.requireFullPaymentBeforeConfirmation,
      minimumDepositPercentage:
          minimumDepositPercentage ?? this.minimumDepositPercentage,
      minHoursBeforeCheckIn:
          minHoursBeforeCheckIn ?? this.minHoursBeforeCheckIn,
      cancellationFreeCancel:
          cancellationFreeCancel ?? this.cancellationFreeCancel,
      cancellationFullRefund:
          cancellationFullRefund ?? this.cancellationFullRefund,
      cancellationRefundPercentage:
          cancellationRefundPercentage ?? this.cancellationRefundPercentage,
      cancellationDaysBeforeCheckIn:
          cancellationDaysBeforeCheckIn ?? this.cancellationDaysBeforeCheckIn,
      cancellationHoursBeforeCheckIn:
          cancellationHoursBeforeCheckIn ?? this.cancellationHoursBeforeCheckIn,
      cancellationNonRefundable:
          cancellationNonRefundable ?? this.cancellationNonRefundable,
      cancellationPenaltyAfterDeadline: cancellationPenaltyAfterDeadline ??
          this.cancellationPenaltyAfterDeadline,
      paymentDepositRequired:
          paymentDepositRequired ?? this.paymentDepositRequired,
      paymentFullPaymentRequired:
          paymentFullPaymentRequired ?? this.paymentFullPaymentRequired,
      paymentDepositPercentage:
          paymentDepositPercentage ?? this.paymentDepositPercentage,
      paymentAcceptCash: paymentAcceptCash ?? this.paymentAcceptCash,
      paymentAcceptCard: paymentAcceptCard ?? this.paymentAcceptCard,
      paymentPayAtProperty: paymentPayAtProperty ?? this.paymentPayAtProperty,
      paymentCashPreferred: paymentCashPreferred ?? this.paymentCashPreferred,
      paymentAcceptedMethods:
          paymentAcceptedMethods ?? this.paymentAcceptedMethods,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInFrom: checkInFrom ?? this.checkInFrom,
      checkInUntil: checkInUntil ?? this.checkInUntil,
      checkInFlexible: checkInFlexible ?? this.checkInFlexible,
      checkInFlexibleCheckIn:
          checkInFlexibleCheckIn ?? this.checkInFlexibleCheckIn,
      checkInRequiresCoordination:
          checkInRequiresCoordination ?? this.checkInRequiresCoordination,
      checkInContactOwner: checkInContactOwner ?? this.checkInContactOwner,
      checkInEarlyCheckInNote:
          checkInEarlyCheckInNote ?? this.checkInEarlyCheckInNote,
      checkInEarlyCheckInNoteEn:
          checkInEarlyCheckInNoteEn ?? this.checkInEarlyCheckInNoteEn,
      checkInLateCheckOutNote:
          checkInLateCheckOutNote ?? this.checkInLateCheckOutNote,
      checkInLateCheckOutFee:
          checkInLateCheckOutFee ?? this.checkInLateCheckOutFee,
      childrenAllowed: childrenAllowed ?? this.childrenAllowed,
      childrenFreeUnderAge: childrenFreeUnderAge ?? this.childrenFreeUnderAge,
      childrenHalfPriceUnderAge:
          childrenHalfPriceUnderAge ?? this.childrenHalfPriceUnderAge,
      childrenMaxChildrenPerRoom:
          childrenMaxChildrenPerRoom ?? this.childrenMaxChildrenPerRoom,
      childrenMaxChildren: childrenMaxChildren ?? this.childrenMaxChildren,
      childrenCribsNote: childrenCribsNote ?? this.childrenCribsNote,
      childrenCribsNoteEn: childrenCribsNoteEn ?? this.childrenCribsNoteEn,
      childrenPlaygroundAvailable:
          childrenPlaygroundAvailable ?? this.childrenPlaygroundAvailable,
      childrenKidsMenuAvailable:
          childrenKidsMenuAvailable ?? this.childrenKidsMenuAvailable,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      petsReason: petsReason ?? this.petsReason,
      petsReasonEn: petsReasonEn ?? this.petsReasonEn,
      petsFeeAmount: petsFeeAmount ?? this.petsFeeAmount,
      petsMaxWeight: petsMaxWeight ?? this.petsMaxWeight,
      petsRequiresApproval: petsRequiresApproval ?? this.petsRequiresApproval,
      petsNoFees: petsNoFees ?? this.petsNoFees,
      petsPetFriendly: petsPetFriendly ?? this.petsPetFriendly,
      petsOutdoorSpace: petsOutdoorSpace ?? this.petsOutdoorSpace,
      petsStrict: petsStrict ?? this.petsStrict,
      modificationAllowed: modificationAllowed ?? this.modificationAllowed,
      modificationFreeModificationHours: modificationFreeModificationHours ??
          this.modificationFreeModificationHours,
      modificationFeesAfter:
          modificationFeesAfter ?? this.modificationFeesAfter,
      modificationFlexible: modificationFlexible ?? this.modificationFlexible,
      modificationReason: modificationReason ?? this.modificationReason,
      modificationReasonEn: modificationReasonEn ?? this.modificationReasonEn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        type,
        description,
        descriptionEn,
        rules,
        rulesEn,
        cancellationWindowDays,
        requireFullPaymentBeforeConfirmation,
        minimumDepositPercentage,
        minHoursBeforeCheckIn,
        cancellationFreeCancel,
        cancellationFullRefund,
        cancellationRefundPercentage,
        cancellationDaysBeforeCheckIn,
        cancellationHoursBeforeCheckIn,
        cancellationNonRefundable,
        cancellationPenaltyAfterDeadline,
        paymentDepositRequired,
        paymentFullPaymentRequired,
        paymentDepositPercentage,
        paymentAcceptCash,
        paymentAcceptCard,
        paymentPayAtProperty,
        paymentCashPreferred,
        paymentAcceptedMethods,
        checkInTime,
        checkOutTime,
        checkInFrom,
        checkInUntil,
        checkInFlexible,
        checkInFlexibleCheckIn,
        checkInRequiresCoordination,
        checkInContactOwner,
        checkInEarlyCheckInNote,
        checkInEarlyCheckInNoteEn,
        checkInLateCheckOutNote,
        checkInLateCheckOutFee,
        childrenAllowed,
        childrenFreeUnderAge,
        childrenHalfPriceUnderAge,
        childrenMaxChildrenPerRoom,
        childrenMaxChildren,
        childrenCribsNote,
        childrenCribsNoteEn,
        childrenPlaygroundAvailable,
        childrenKidsMenuAvailable,
        petsAllowed,
        petsReason,
        petsReasonEn,
        petsFeeAmount,
        petsMaxWeight,
        petsRequiresApproval,
        petsNoFees,
        petsPetFriendly,
        petsOutdoorSpace,
        petsStrict,
        modificationAllowed,
        modificationFreeModificationHours,
        modificationFeesAfter,
        modificationFlexible,
        modificationReason,
        modificationReasonEn,
        createdAt,
        updatedAt,
        isActive,
      ];
}

/// نوع السياسة
enum PolicyType {
  cancellation,
  checkIn,
  children,
  pets,
  payment,
  modification;

  String get displayName {
    switch (this) {
      case PolicyType.cancellation:
        return 'سياسة الإلغاء';
      case PolicyType.checkIn:
        return 'سياسة تسجيل الدخول';
      case PolicyType.children:
        return 'سياسة الأطفال';
      case PolicyType.pets:
        return 'سياسة الحيوانات الأليفة';
      case PolicyType.payment:
        return 'سياسة الدفع';
      case PolicyType.modification:
        return 'سياسة التعديل';
    }
  }

  String get apiValue {
    switch (this) {
      case PolicyType.cancellation:
        return 'Cancellation';
      case PolicyType.checkIn:
        return 'CheckIn';
      case PolicyType.children:
        return 'Children';
      case PolicyType.pets:
        return 'Pets';
      case PolicyType.payment:
        return 'Payment';
      case PolicyType.modification:
        return 'Modification';
    }
  }

  static PolicyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cancellation':
        return PolicyType.cancellation;
      case 'checkin':
        return PolicyType.checkIn;
      case 'children':
        return PolicyType.children;
      case 'pets':
        return PolicyType.pets;
      case 'payment':
        return PolicyType.payment;
      case 'modification':
        return PolicyType.modification;
      default:
        return PolicyType.cancellation;
    }
  }
}

/// 📊 Entity لإحصائيات السياسات
class PolicyStats {
  /// العربية: يخزن القيمة `totalPolicies`.
  final int totalPolicies;

  final int activePolicies;

  final int policiesByType;

  final Map<String, int> policyTypeDistribution;

  final double averageCancellationWindow;

  const PolicyStats({
    required this.totalPolicies,
    required this.activePolicies,
    required this.policiesByType,
    required this.policyTypeDistribution,
    required this.averageCancellationWindow,
  });
}
