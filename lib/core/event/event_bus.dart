import 'dart:async';

import 'app_events.dart';

class EventBus {
  EventBus._();

  static final EventBus instance = EventBus._();

  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  void fire(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
