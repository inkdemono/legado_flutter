import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Stream<T> streamFromListenables<T>(
  Ref ref, {
  required List<Listenable> listenables,
  required T Function() read,
}) {
  final controller = StreamController<T>.broadcast(sync: true);

  void emit() {
    if (!controller.isClosed) {
      controller.add(read());
    }
  }

  for (final listenable in listenables) {
    listenable.addListener(emit);
  }

  ref.onDispose(() {
    for (final listenable in listenables) {
      listenable.removeListener(emit);
    }
    unawaited(controller.close());
  });

  emit();
  return controller.stream;
}
