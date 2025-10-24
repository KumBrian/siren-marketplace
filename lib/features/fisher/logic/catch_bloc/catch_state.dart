part of "catch_bloc.dart";

abstract class CatchesState extends Equatable {
  const CatchesState();

  @override
  List<Object> get props => [];
}

class CatchesInitial extends CatchesState {}

class CatchesLoading extends CatchesState {}

class CatchDeletedSuccess extends CatchesState {}

class CatchesLoaded extends CatchesState {
  final List<Catch> catches;

  const CatchesLoaded(this.catches);

  @override
  List<Object> get props => [catches];
}

class CatchesError extends CatchesState {
  final String message;

  const CatchesError(this.message);

  @override
  List<Object> get props => [message];
}
