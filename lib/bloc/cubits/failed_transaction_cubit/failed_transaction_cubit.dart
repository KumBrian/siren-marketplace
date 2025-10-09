import 'package:flutter_bloc/flutter_bloc.dart';

import 'failed_transaction_state.dart';

class FailedTransactionCubit extends Cubit<FailedTransactionState> {
  FailedTransactionCubit() : super(const FailedTransactionState());

  void toggleReason(String reason) {
    // Deselect if same reason clicked again, otherwise select new
    emit(
      state.selectedReason == reason
          ? const FailedTransactionState()
          : FailedTransactionState(selectedReason: reason),
    );
  }

  void clear() => emit(const FailedTransactionState());
}
