import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/core/base/base_service.dart';
import 'package:legado_flutter/core/exceptions/app_exceptions.dart';

class _TestService extends BaseService {
  _TestService({
    required this.initDelay,
    this.shouldFail = false,
  });

  final Duration initDelay;
  final bool shouldFail;
  int initCallCount = 0;

  @override
  Future<void> onInit() async {
    initCallCount++;
    await Future<void>.delayed(initDelay);
    if (shouldFail) {
      throw StateError('init failed');
    }
  }
}

void main() {
  test('concurrent init only runs onInit once', () async {
    final service = _TestService(initDelay: const Duration(milliseconds: 10));

    await Future.wait([
      service.init(),
      service.init(),
      service.init(),
    ]);

    expect(service.initCallCount, 1);
    expect(service.isInitialized, isTrue);
  });

  test('failed init can retry', () async {
    final failingService = _TestService(
      initDelay: const Duration(milliseconds: 1),
      shouldFail: true,
    );

    await expectLater(
      failingService.init(),
      throwsA(isA<ServiceException>()),
    );

    final retryService = _TestService(
      initDelay: const Duration(milliseconds: 1),
    );
    await retryService.init();

    expect(retryService.initCallCount, 1);
    expect(retryService.isInitialized, isTrue);
  });
}
