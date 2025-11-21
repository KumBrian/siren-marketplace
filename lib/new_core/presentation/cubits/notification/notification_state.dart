import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final int unreadOffersCount;
  final DateTime? lastUpdated;

  const NotificationState({this.unreadOffersCount = 0, this.lastUpdated});

  NotificationState copyWith({int? unreadOffersCount, DateTime? lastUpdated}) {
    return NotificationState(
      unreadOffersCount: unreadOffersCount ?? this.unreadOffersCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [unreadOffersCount, lastUpdated];
}
