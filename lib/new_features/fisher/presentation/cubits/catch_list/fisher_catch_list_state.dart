import 'package:equatable/equatable.dart';

import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/enums/catch_status.dart';

abstract class FisherCatchListState extends Equatable {
  const FisherCatchListState();

  @override
  List<Object?> get props => [];
}

class FisherCatchListInitial extends FisherCatchListState {
  const FisherCatchListInitial();
}

class FisherCatchListLoading extends FisherCatchListState {
  const FisherCatchListLoading();
}

class FisherCatchListLoaded extends FisherCatchListState {
  final List<Catch> catches;
  final CatchStatus? filterStatus;

  const FisherCatchListLoaded({required this.catches, this.filterStatus});

  @override
  List<Object?> get props => [catches, filterStatus];
}

class FisherCatchListError extends FisherCatchListState {
  final String message;

  const FisherCatchListError(this.message);

  @override
  List<Object?> get props => [message];
}
