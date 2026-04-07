import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/models/book.dart';
import 'package:legado_flutter/services/startup_flow_service.dart';

void main() {
  group('StartupFlowService auto refresh workflow', () {
    test('waits for dependencies before refreshing books', () async {
      final steps = <String>[];

      await StartupFlowService.runAutoRefreshWorkflowForTesting(
        waitForDependencies: () async {
          steps.add('dependencies');
        },
        loadBookshelfBooks: () async {
          steps.add('load_books');
          return [
            Book(
              bookUrl: 'book-1',
              origin: 'source-1',
              canUpdate: true,
            ),
          ];
        },
        updateChapterLists: (books) async {
          steps.add('update_chapters');
          expect(books, hasLength(1));
          return {'book-1': true};
        },
        fireCollectionChanged: () {
          steps.add('fire_event');
        },
        refreshUpdateCount: () async {
          steps.add('refresh_count');
        },
        isMounted: () => true,
      );

      expect(
        steps,
        [
          'dependencies',
          'load_books',
          'update_chapters',
          'fire_event',
          'refresh_count',
        ],
      );
    });

    test('skips update when there are no eligible remote books', () async {
      var updateCalled = false;
      var eventFired = false;
      var refreshCalled = false;

      await StartupFlowService.runAutoRefreshWorkflowForTesting(
        waitForDependencies: () async {},
        loadBookshelfBooks: () async {
          return [
            Book(
              bookUrl: 'local-book',
              origin: BookType.localTag,
              canUpdate: false,
            ),
          ];
        },
        updateChapterLists: (books) async {
          updateCalled = true;
          return {};
        },
        fireCollectionChanged: () {
          eventFired = true;
        },
        refreshUpdateCount: () async {
          refreshCalled = true;
        },
        isMounted: () => true,
      );

      expect(updateCalled, isFalse);
      expect(eventFired, isFalse);
      expect(refreshCalled, isFalse);
    });
  });
}
