import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/event/app_events.dart';
import '../core/event/event_bus.dart';

final eventBusProvider = Provider<EventBus>((ref) {
  return EventBus.instance;
});

final bookCollectionEventProvider =
    StreamProvider<BookCollectionChangedEvent>((ref) {
  return ref.watch(eventBusProvider).on<BookCollectionChangedEvent>();
});

final bookGroupEventProvider = StreamProvider<BookGroupChangedEvent>((ref) {
  return ref.watch(eventBusProvider).on<BookGroupChangedEvent>();
});

final bookSourceEventProvider = StreamProvider<BookSourceChangedEvent>((ref) {
  return ref.watch(eventBusProvider).on<BookSourceChangedEvent>();
});
