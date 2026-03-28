// lib/features/admin_financial/presentation/bloc/financial_overview/financial_overview_event.dart

part of 'financial_overview_bloc.dart';

abstract class FinancialOverviewEvent extends Equatable {
  const FinancialOverviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadFinancialOverview extends FinancialOverviewEvent {
  final DateTime startDate;
  final DateTime endDate;
  const LoadFinancialOverview({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshFinancialOverview extends FinancialOverviewEvent {}

class ChangePeriod extends FinancialOverviewEvent {
  final DateTime startDate;
  final DateTime endDate;
  const ChangePeriod({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadChartData extends FinancialOverviewEvent {
  final String chartType; // revenue, expense, cashflow
  const LoadChartData({required this.chartType});
  @override
  List<Object?> get props => [chartType];
}

class ExportReport extends FinancialOverviewEvent {
  final String format; // pdf, excel
  const ExportReport({required this.format});
  @override
  List<Object?> get props => [format];
}
