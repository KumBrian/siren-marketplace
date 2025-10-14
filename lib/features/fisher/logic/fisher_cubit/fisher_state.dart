part of "fisher_cubit.dart";

abstract class FisherState {}

class FisherInitial extends FisherState {}

class FisherLoading extends FisherState {}

class FisherLoaded extends FisherState {
  final Fisher fisher;

  FisherLoaded(this.fisher);
}

class FisherError extends FisherState {
  final String message;

  FisherError(this.message);
}
