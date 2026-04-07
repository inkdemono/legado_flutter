import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legado_flutter/data/datasources/book_local_datasource_impl.dart';
import 'package:legado_flutter/data/datasources/book_source_local_datasource_impl.dart';
import 'package:legado_flutter/data/models/book.dart';
import 'package:legado_flutter/data/models/book_source.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:legado_flutter/services/book/book_service.dart';
import 'package:legado_flutter/services/local_config_service.dart';
import 'package:legado_flutter/services/network/network_service.dart';
import 'package:legado_flutter/services/source/book_source_service.dart';
import 'package:legado_flutter/utils/parsers/rule_parser.dart';

class _FakeBookService implements IBookService {
  _FakeBookService({required this.books});

  final List<Book> books;

  @override
  Future<List<Book>> getBookshelfBooks() async => books;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookSourceService implements IBookSourceService {
  _FakeBookSourceService({required this.sources});

  final List<BookSource> sources;

  @override
  Future<List<BookSource>> getAllBookSources({bool enabledOnly = false}) async {
    if (!enabledOnly) {
      return sources;
    }
    return sources.where((source) => source.enabled).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNetworkService implements INetworkService {
  String? lastGetUrl;
  Map<String, String>? lastHeaders;

  @override
  Dio get dio => Dio();

  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: urlPath),
      data: savePath,
      statusCode: 200,
    );
  }

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    int retryCount = 0,
    Map<String, String>? headers,
  }) async {
    lastGetUrl = url;
    lastHeaders = headers;
    return Response(
      requestOptions: RequestOptions(path: url),
      data: 'ok',
      statusCode: 200,
    );
  }

  @override
  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    int retryCount = 0,
    Map<String, String>? headers,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: url),
      data: data,
      statusCode: 200,
    );
  }
}

class _FakeLocalConfigService implements LocalConfigService {
  _FakeLocalConfigService({required this.privacyPolicyConfirmed});

  final bool privacyPolicyConfirmed;

  @override
  bool get privacyPolicyOk => privacyPolicyConfirmed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(resetAppProviderContainer);

  test('AppServices 支持通过测试容器覆盖核心 Service', () async {
    final fakeBookService = _FakeBookService(
      books: [
        Book(bookUrl: 'book-1', name: '测试书籍', origin: 'source-1'),
      ],
    );
    final fakeBookSourceService = _FakeBookSourceService(
      sources: [
        BookSource(
          bookSourceUrl: 'source-1',
          bookSourceName: '测试书源',
          enabled: true,
        ),
      ],
    );
    final fakeNetworkService = _FakeNetworkService();
    final container = ProviderContainer(
      overrides: [
        AppServices.bookService.overrideWithValue(fakeBookService),
        AppServices.bookSourceService.overrideWithValue(fakeBookSourceService),
        AppServices.networkService.overrideWithValue(fakeNetworkService),
      ],
    );

    setAppProviderContainerForTesting(container);

    expect(identical(readService(AppServices.bookService), fakeBookService),
        isTrue);
    expect(
      identical(
          readService(AppServices.bookSourceService), fakeBookSourceService),
      isTrue,
    );
    expect(
        identical(readService(AppServices.networkService), fakeNetworkService),
        isTrue);

    final bookLocalDataSource = BookLocalDataSourceImpl();
    final bookSourceLocalDataSource = BookSourceLocalDataSourceImpl();

    expect((await bookLocalDataSource.getAllBooks()).single.name, '测试书籍');
    expect(
      (await bookSourceLocalDataSource.getAllBookSources())
          .single
          .bookSourceName,
      '测试书源',
    );
  });

  test('AppServices 支持通过测试容器覆盖具体类型 Service', () {
    final fakeLocalConfigService =
        _FakeLocalConfigService(privacyPolicyConfirmed: true);
    final container = ProviderContainer(
      overrides: [
        AppServices.localConfigService
            .overrideWithValue(fakeLocalConfigService),
      ],
    );

    setAppProviderContainerForTesting(container);

    expect(
      identical(
        readService(AppServices.localConfigService),
        fakeLocalConfigService,
      ),
      isTrue,
    );
    expect(readService(AppServices.localConfigService).privacyPolicyOk, isTrue);
  });

  test('RuleParser payAction 使用可覆盖的 NetworkService Provider', () async {
    final fakeNetworkService = _FakeNetworkService();
    final container = ProviderContainer(
      overrides: [
        AppServices.networkService.overrideWithValue(fakeNetworkService),
      ],
    );

    setAppProviderContainerForTesting(container);

    final result = await RuleParser.executePayAction(
      '<html></html>',
      'https://example.com/paywall/unlock',
    );

    expect(result, isTrue);
    expect(fakeNetworkService.lastGetUrl,
        'https://example.com/paywall/unlock');
  });
}
