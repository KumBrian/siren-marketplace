import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<bool> {
  NotificationsCubit() : super(false);

  void toggle() => emit(!state);
}
