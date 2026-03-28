// lib/features/admin_financial/domain/entities/chart_of_account.dart

import 'package:equatable/equatable.dart';

class ChartOfAccount extends Equatable {
  final String id;
  final String accountNumber;
  final String nameAr;
  final String nameEn;
  final AccountType accountType;
  final AccountCategory category;
  final AccountNature normalBalance;
  final int level;
  final String? description;
  final double balance;
  final String currency;
  final bool isActive;
  final bool isSystemAccount;
  final bool canPost;
  final String? parentAccountId;
  final ChartOfAccount? parentAccount;
  final List<ChartOfAccount>? subAccounts;
  final String? userId;
  final String? propertyId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ChartOfAccount({
    required this.id,
    required this.accountNumber,
    required this.nameAr,
    required this.nameEn,
    required this.accountType,
    required this.category,
    required this.normalBalance,
    required this.level,
    this.description,
    this.balance = 0,
    this.currency = 'YER',
    this.isActive = true,
    this.isSystemAccount = false,
    this.canPost = true,
    this.parentAccountId,
    this.parentAccount,
    this.subAccounts,
    this.userId,
    this.propertyId,
    required this.createdAt,
    this.updatedAt,
  });

  // 🎯 Helper Methods
  bool get isMainAccount => category == AccountCategory.main;
  bool get hasSubAccounts => subAccounts?.isNotEmpty ?? false;
  String get displayName => nameAr;

  // 🎨 Get account color based on type
  String get accountColor {
    switch (accountType) {
      case AccountType.assets:
        return '#00D4FF';
      case AccountType.liabilities:
        return '#FF3366';
      case AccountType.equity:
        return '#9D50FF';
      case AccountType.revenue:
        return '#00FF88';
      case AccountType.expenses:
        return '#FFB800';
    }
  }

  // 🔢 Get account icon based on type
  String get accountIcon {
    switch (accountType) {
      case AccountType.assets:
        return '💎';
      case AccountType.liabilities:
        return '📊';
      case AccountType.equity:
        return '🏦';
      case AccountType.revenue:
        return '💰';
      case AccountType.expenses:
        return '💸';
    }
  }

  @override
  List<Object?> get props => [
        id,
        accountNumber,
        nameAr,
        nameEn,
        accountType,
        category,
        normalBalance,
        level,
        description,
        balance,
        currency,
        isActive,
        isSystemAccount,
        canPost,
        parentAccountId,
        userId,
        propertyId,
        createdAt,
        updatedAt,
      ];
  ChartOfAccount copyWith({
    String? id,
    String? accountNumber,
    String? nameAr,
    String? nameEn,
    AccountType? accountType,
    AccountCategory? category,
    AccountNature? normalBalance,
    int? level,
    String? description,
    double? balance,
    String? currency,
    bool? isActive,
    bool? isSystemAccount,
    bool? canPost,
    String? parentAccountId,
    ChartOfAccount? parentAccount,
    List<ChartOfAccount>? subAccounts,
    String? userId,
    String? propertyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChartOfAccount(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      accountType: accountType ?? this.accountType,
      category: category ?? this.category,
      normalBalance: normalBalance ?? this.normalBalance,
      level: level ?? this.level,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      isSystemAccount: isSystemAccount ?? this.isSystemAccount,
      canPost: canPost ?? this.canPost,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      parentAccount: parentAccount ?? this.parentAccount,
      subAccounts: subAccounts ?? this.subAccounts,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AccountType {
  assets('أصول', 'Assets'),
  liabilities('التزامات', 'Liabilities'),
  equity('حقوق ملكية', 'Equity'),
  revenue('إيرادات', 'Revenue'),
  expenses('مصروفات', 'Expenses');

  final String nameAr;
  final String nameEn;
  const AccountType(this.nameAr, this.nameEn);
}

enum AccountCategory {
  main('حساب رئيسي', 'Main'),
  sub('حساب فرعي', 'Sub');

  final String nameAr;
  final String nameEn;
  const AccountCategory(this.nameAr, this.nameEn);
}

enum AccountNature {
  debit('مدين', 'Debit'),
  credit('دائن', 'Credit');

  final String nameAr;
  final String nameEn;
  const AccountNature(this.nameAr, this.nameEn);
}
