import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/import_export_book_source_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late ImportExportBookSourceUseCase useCase;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = ImportExportBookSourceUseCase(
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('ImportExportBookSourceUseCase', () {
    test('importFromJson 应该返回仓库导入数量', () async {
      mockBookSourceRepository.setImportFromJsonResult(3);

      final count = await useCase.importFromJson('[{"name":"source"}]');

      expect(count, 3);
      expect(mockBookSourceRepository.importFromJsonCallCount, 1);
      expect(mockBookSourceRepository.lastImportedJson, '[{"name":"source"}]');
    });

    test('exportToJson 应该导出显式传入的书源列表', () async {
      final sources = [
        createTestBookSourceEntity(bookSourceUrl: 'https://source1.com'),
      ];
      mockBookSourceRepository.setExportToJsonResult('[1]');

      final result = await useCase.exportToJson(sources: sources);

      expect(result, '[1]');
      expect(mockBookSourceRepository.exportToJsonCallCount, 1);
      expect(mockBookSourceRepository.lastExportedSources, sources);
      expect(mockBookSourceRepository.getAllBookSourcesCallCount, 0);
    });

    test('exportEnabledToJson 和 exportGroupToJson 应该按范围导出', () async {
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source1.com',
          enabled: true,
        ),
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source2.com',
          enabled: false,
        ).copyWith(bookSourceGroup: '其他'),
      ]);
      mockBookSourceRepository.setExportToJsonResult('[exported]');

      final enabledJson = await useCase.exportEnabledToJson();
      final enabledSources =
          List.of(mockBookSourceRepository.lastExportedSources);
      final groupJson = await useCase.exportGroupToJson('其他');
      final groupSources =
          List.of(mockBookSourceRepository.lastExportedSources);

      expect(enabledJson, '[exported]');
      expect(enabledSources, hasLength(1));
      expect(enabledSources.first.bookSourceUrl, 'https://source1.com');

      expect(groupJson, '[exported]');
      expect(groupSources, hasLength(1));
      expect(groupSources.first.bookSourceUrl, 'https://source2.com');
    });
  });
}
