part of 'unit_details_bloc.dart';

abstract class UnitDetailsState extends Equatable {
  const UnitDetailsState();

  @override
  List<Object?> get props => [];
}

class UnitDetailsInitial extends UnitDetailsState {}

class UnitDetailsLoading extends UnitDetailsState {}

class UnitDetailsLoaded extends UnitDetailsState {
  final Unit unit;
  final UnitAnalytics? analytics;

  const UnitDetailsLoaded({required this.unit, this.analytics});

  @override
  List<Object?> get props => [unit, analytics];
}

class UnitDeleted extends UnitDetailsState {}

class UnitDetailsError extends UnitDetailsState {
  final String message;

  const UnitDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}