import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';
import '../../../domain/services/expiration_service.dart';
import 'expiration_state.dart';

class ExpirationCubit extends Cubit<ExpirationState> {
  final ExpirationService _expirationService;
  Timer? _periodicTimer;

  ExpirationCubit({ExpirationService? expirationService})
    : _expirationService = expirationService ?? DI().expirationService,
      super(const ExpirationState());

  /// Start periodic expiration check (runs every hour)
  void startPeriodicCheck() {
    // Run immediately on start
    runMaintenance();

    // Then run every hour
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => runMaintenance(),
    );
  }

  /// Stop periodic checks
  void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Manually run expiration maintenance
  Future<void> runMaintenance() async {
    if (state.isRunning) return; // Prevent concurrent runs

    emit(state.copyWith(isRunning: true));

    try {
      final (expired, deleted) = await _expirationService.runMaintenance();

      emit(
        ExpirationState(
          lastRun: DateTime.now(),
          expiredCount: expired,
          deletedCount: deleted,
          isRunning: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isRunning: false));
    }
  }

  @override
  Future<void> close() {
    _periodicTimer?.cancel();
    return super.close();
  }
}
