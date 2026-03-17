import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legado_flutter/providers/reader_provider.dart';

void main() {
  group('ReaderState', () {
    test('copyWith 应正确更新字段', () {
      const state = ReaderState(
        chapters: [],
        currentChapterIndex: 0,
        isLoading: true,
      );
      final next = state.copyWith(
        currentChapterIndex: 2,
        isLoading: false,
      );
      expect(next.currentChapterIndex, 2);
      expect(next.isLoading, false);
      expect(next.chapters, state.chapters);
    });

    test('初始状态应符合默认值', () {
      const state = ReaderState();
      expect(state.chapters, isEmpty);
      expect(state.currentChapterIndex, 0);
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
    });
  });

  group('ReaderViewModel', () {
    test('build 应返回初始状态', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(readerViewModelProvider);
      expect(state.book, isNull);
      expect(state.chapters, isEmpty);
      expect(state.currentChapterIndex, 0);
      expect(state.isLoading, isTrue);
    });

    test('setCurrentChapterIndex 在无章节时不修改状态', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(readerViewModelProvider.notifier);
      notifier.setCurrentChapterIndex(0);
      expect(container.read(readerViewModelProvider).currentChapterIndex, 0);
    });
  });
}
