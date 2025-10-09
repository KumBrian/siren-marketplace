import 'package:equatable/equatable.dart';

class FailedTransactionState extends Equatable {
  final String? selectedReason;

  const FailedTransactionState({this.selectedReason});

  FailedTransactionState copyWith({String? selectedReason}) {
    return FailedTransactionState(selectedReason: selectedReason);
  }

  @override
  List<Object?> get props => [selectedReason];
}
