part of "catch_bloc.dart";

abstract class CatchesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCatches extends CatchesEvent {}

class AddCatch extends CatchesEvent {
  final Catch catchModel;

  AddCatch(this.catchModel);

  @override
  List<Object?> get props => [catchModel];
}

class UpdateCatchEvent extends CatchesEvent {
  final Catch catchModel;

  UpdateCatchEvent(this.catchModel);

  @override
  List<Object?> get props => [catchModel];
}

class DeleteCatchEvent extends CatchesEvent {
  final String catchId;

  DeleteCatchEvent(this.catchId);

  @override
  List<Object?> get props => [catchId];
}

class LoadCatchesByFisher extends CatchesEvent {
  final String fisherId;

  LoadCatchesByFisher({required this.fisherId});

  @override
  List<Object> get props => [fisherId];
}
