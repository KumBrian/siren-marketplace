import 'package:equatable/equatable.dart';

class ExpirationState extends Equatable {
  final DateTime? lastRun;
  final int expiredCount;
  final int deletedCount;
  final bool isRunning;

  const ExpirationState({
    this.lastRun,
    this.expiredCount = 0,
    this.deletedCount = 0,
    this.isRunning = false,
  });

  ExpirationState copyWith({
    DateTime? lastRun,
    int? expiredCount,
    int? deletedCount,
    bool? isRunning,
  }) {
    return ExpirationState(
      lastRun: lastRun ?? this.lastRun,
      expiredCount: expiredCount ?? this.expiredCount,
      deletedCount: deletedCount ?? this.deletedCount,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [lastRun, expiredCount, deletedCount, isRunning];
}
