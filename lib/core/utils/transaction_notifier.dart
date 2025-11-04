import 'dart:async';

class TransactionNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get updates => _controller.stream;

  void notify() {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
