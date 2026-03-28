// lib/features/admin_financial/presentation/bloc/accounts/accounts_state.dart

part of 'accounts_bloc.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();
  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<ChartOfAccount> accounts;
  final List<ChartOfAccount> allAccounts;
  final bool showMainOnly;
  final AccountType? selectedType;
  final String? searchQuery;
  final bool isProcessing;
  final String? successMessage;
  final String? error;
  AccountsLoaded({
    required this.accounts,
    List<ChartOfAccount>? allAccounts,
    this.showMainOnly = false,
    this.selectedType,
    this.searchQuery,
    this.isProcessing = false,
    this.successMessage,
    this.error,
  }) : allAccounts = allAccounts ?? accounts;
  AccountsLoaded copyWith({
    List<ChartOfAccount>? accounts,
    List<ChartOfAccount>? allAccounts,
    bool? showMainOnly,
    AccountType? selectedType,
    String? searchQuery,
    bool? isProcessing,
    String? successMessage,
    String? error,
  }) {
    return AccountsLoaded(
      accounts: accounts ?? this.accounts,
      allAccounts: allAccounts ?? this.allAccounts,
      showMainOnly: showMainOnly ?? this.showMainOnly,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        allAccounts,
        showMainOnly,
        selectedType,
        searchQuery,
        isProcessing,
        successMessage,
        error,
      ];
}

class AccountsError extends AccountsState {
  final String message;
  const AccountsError(this.message);
  @override
  List<Object> get props => [message];
}
