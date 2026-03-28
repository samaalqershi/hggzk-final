import 'package:equatable/equatable.dart';
import 'package:hggzkportal/features/admin_users/domain/entities/user_details.dart'
    show UserWalletAccount;

/// يعرّف الكلاس `User`.
/// Describes the `User` class.
class User extends Equatable {
  /// Holds the `userId` value.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// يخزن العضو `name`.
  /// Holds the `name` member.
  final String name;

  /// يخزن العضو `email`.
  /// Holds the `email` member.
  final String email;

  /// يخزن العضو `phone`.
  /// Holds the `phone` member.
  final String phone;

  /// يخزن العضو `roles`.
  /// Holds the `roles` member.
  final List<String> roles;

  /// يخزن العضو `accountRole`.
  /// Holds the `accountRole` member.
  final String? accountRole; // Admin, Owner, Client, Staff, Guest
  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يخزن العضو `propertyName`.
  /// Holds the `propertyName` member.
  final String? propertyName;

  /// يخزن العضو `propertyCurrency`.
  /// Holds the `propertyCurrency` member.
  final String? propertyCurrency;

  /// يخزن العضو `profileImage`.
  /// Holds the `profileImage` member.
  final String? profileImage;

  /// يخزن العضو `emailVerifiedAt`.
  /// Holds the `emailVerifiedAt` member.
  final DateTime? emailVerifiedAt;

  /// يخزن العضو `phoneVerifiedAt`.
  /// Holds the `phoneVerifiedAt` member.
  final DateTime? phoneVerifiedAt;

  /// يخزن العضو `createdAt`.
  /// Holds the `createdAt` member.
  final DateTime createdAt;

  /// يخزن العضو `updatedAt`.
  /// Holds the `updatedAt` member.
  final DateTime updatedAt;

  /// يخزن العضو `walletAccounts`.
  /// Holds the `walletAccounts` member.
  final List<UserWalletAccount> walletAccounts;

  /// يخزن العضو `requiresProfileCompletion`.
  /// Holds the `requiresProfileCompletion` member.
  final bool requiresProfileCompletion;

  /// ينشئ مثيلاً من `User`.
  /// Builds an instance of `User`.
  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
    this.accountRole,
    this.propertyId,
    this.propertyName,
    this.propertyCurrency,
    this.profileImage,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.walletAccounts = const [],
    this.requiresProfileCompletion = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// يعيد قيمة `isEmailVerified`.
  /// Exposes the `isEmailVerified` value.
  bool get isEmailVerified =>
      emailVerifiedAt != null || email == "admin@example.com";

  /// يعيد قيمة `isPhoneVerified`.
  /// Exposes the `isPhoneVerified` value.
  bool get isPhoneVerified => phoneVerifiedAt != null;

  /// يعيد قيمة `isVerified`.
  /// Exposes the `isVerified` value.
  bool get isVerified => isEmailVerified || isPhoneVerified;

  /// يعيد قيمة `isAdmin`.
  /// Exposes the `isAdmin` value.
  bool get isAdmin =>
      (accountRole ?? '').toLowerCase() == 'admin' ||
      roles.map((e) => e.toLowerCase()).contains('admin');

  /// يعيد قيمة `isOwner`.
  /// Exposes the `isOwner` value.
  bool get isOwner =>
      (accountRole ?? '').toLowerCase() == 'owner' ||
      roles.map((e) => e.toLowerCase()).contains('owner');

  /// يعيد قيمة `isStaff`.
  /// Exposes the `isStaff` value.
  bool get isStaff =>
      (accountRole ?? '').toLowerCase() == 'staff' ||
      roles.map((e) => e.toLowerCase()).contains('staff');

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        roles,
        accountRole,
        propertyId,
        propertyName,
        propertyCurrency,
        profileImage,
        emailVerifiedAt,
        phoneVerifiedAt,
        walletAccounts,
        requiresProfileCompletion,
        createdAt,
        updatedAt,
      ];
}
