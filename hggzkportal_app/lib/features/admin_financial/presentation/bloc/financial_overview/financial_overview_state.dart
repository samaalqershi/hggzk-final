// lib/features/admin_financial/presentation/bloc/financial_overview/financial_overview_state.dart

part of 'financial_overview_bloc.dart';

abstract class FinancialOverviewState extends Equatable {
  const FinancialOverviewState();
  @override
  List<Object?> get props => [];
}

class FinancialOverviewInitial extends FinancialOverviewState {}

class FinancialOverviewLoading extends FinancialOverviewState {}

class FinancialOverviewLoaded extends FinancialOverviewState {
  final FinancialReport report;
  final List<ChartOfAccount> accounts;
  final List<FinancialTransaction> recentTransactions;
  final FinancialSummary? summary;
  final List<ChartData> revenueChartData;
  final List<ChartData> expenseChartData;
  final List<ChartData> cashFlowChartData;
  final DateTime startDate;
  final DateTime endDate;
  final bool isLoadingChart;
  final bool isExporting;
  final String? exportedFilePath;
  final String? exportError;
  const FinancialOverviewLoaded({
    required this.report,
    required this.accounts,
    required this.recentTransactions,
    this.summary,
    this.revenueChartData = const [],
    this.expenseChartData = const [],
    this.cashFlowChartData = const [],
    required this.startDate,
    required this.endDate,
    this.isLoadingChart = false,
    this.isExporting = false,
    this.exportedFilePath,
    this.exportError,
  });

  // 🎯 Helper Methods
  double get totalBalance {
    return accounts.fold(0, (sum, account) => sum + account.balance);
  }

  int get activeAccountsCount {
    return accounts.where((a) => a.isActive).length;
  }

  List<ChartOfAccount> get mainAccounts {
    return accounts.where((a) => a.category == AccountCategory.main).toList();
  }

  List<FinancialTransaction> get pendingTransactions {
    return recentTransactions.where((t) => t.isPending).toList();
  }

  List<FinancialTransaction> get postedTransactions {
    return recentTransactions.where((t) => t.isPosted).toList();
  }

  FinancialOverviewLoaded copyWith({
    FinancialReport? report,
    List<ChartOfAccount>? accounts,
    List<FinancialTransaction>? recentTransactions,
    FinancialSummary? summary,
    List<ChartData>? revenueChartData,
    List<ChartData>? expenseChartData,
    List<ChartData>? cashFlowChartData,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoadingChart,
    bool? isExporting,
    String? exportedFilePath,
    String? exportError,
  }) {
    return FinancialOverviewLoaded(
      report: report ?? this.report,
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      summary: summary ?? this.summary,
      revenueChartData: revenueChartData ?? this.revenueChartData,
      expenseChartData: expenseChartData ?? this.expenseChartData,
      cashFlowChartData: cashFlowChartData ?? this.cashFlowChartData,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoadingChart: isLoadingChart ?? this.isLoadingChart,
      isExporting: isExporting ?? this.isExporting,
      exportedFilePath: exportedFilePath ?? this.exportedFilePath,
      exportError: exportError ?? this.exportError,
    );
  }

  @override
  List<Object?> get props => [
        report,
        accounts,
        recentTransactions,
        summary,
        revenueChartData,
        expenseChartData,
        cashFlowChartData,
        startDate,
        endDate,
        isLoadingChart,
        isExporting,
        exportedFilePath,
        exportError,
      ];
}

class FinancialOverviewError extends FinancialOverviewState {
  final String message;
  const FinancialOverviewError(this.message);
  @override
  List<Object?> get props => [message];
}
