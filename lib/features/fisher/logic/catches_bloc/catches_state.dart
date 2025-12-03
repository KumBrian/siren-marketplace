part of 'catches_cubit.dart';

class CatchesState extends Equatable {
  final bool loading;
  final List<Catch> catches;
  final String? error;

  const CatchesState({
    this.loading = false,
    this.catches = const [],
    this.error,
  });

  CatchesState copyWith({bool? loading, List<Catch>? catches, String? error}) {
    return CatchesState(
      loading: loading ?? this.loading,
      catches: catches ?? this.catches,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, catches, error];
}
