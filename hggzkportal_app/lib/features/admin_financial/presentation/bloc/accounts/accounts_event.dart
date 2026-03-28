// lib/features/admin_financial/presentation/bloc/accounts/accounts_event.dart

part of 'accounts_bloc.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();
  @override
  List<Object?> get props => [];
}

class LoadChartOfAccounts extends AccountsEvent {
  const LoadChartOfAccounts();
}

class SearchAccounts extends AccountsEvent {
  final String query;
  const SearchAccounts({required this.query});
  @override
  List<Object> get props => [query];
}

class FilterAccountsByType extends AccountsEvent {
  final AccountType type;
  const FilterAccountsByType({required this.type});
  @override
  List<Object> get props => [type];
}

class LoadMainAccounts extends AccountsEvent {
  const LoadMainAccounts();
}
