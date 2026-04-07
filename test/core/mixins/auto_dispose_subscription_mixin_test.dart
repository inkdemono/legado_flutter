import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/core/mixins/auto_dispose_subscription_mixin.dart';

void main() {
  testWidgets('AutoDisposeSubscriptionMixin cancels managed subscriptions on dispose',
      (tester) async {
    final controller = StreamController<int>.broadcast();
    var cancelCount = 0;
    controller.onCancel = () {
      cancelCount++;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: _TestSubscriptionWidget(stream: controller.stream),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(cancelCount, 1);
    await controller.close();
  });
}

class _TestSubscriptionWidget extends StatefulWidget {
  const _TestSubscriptionWidget({required this.stream});

  final Stream<int> stream;

  @override
  State<_TestSubscriptionWidget> createState() => _TestSubscriptionWidgetState();
}

class _TestSubscriptionWidgetState extends State<_TestSubscriptionWidget>
    with AutoDisposeSubscriptionMixin {
  @override
  void initState() {
    super.initState();
    listenStream(widget.stream, (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
