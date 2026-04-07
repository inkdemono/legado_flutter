import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/core/error/global_error_handler.dart';

void main() {
  group('GlobalErrorHandler', () {
    test('extracts status code from HttpException message', () {
      final error = HttpException(
        'Invalid statusCode: 404',
        uri: Uri.parse('https://example.com/cover.jpg'),
      );

      expect(GlobalErrorHandler.extractHttpStatusCode(error), 404);
    });

    test('ignores media 404 errors', () {
      final error = HttpException(
        'Invalid statusCode: 404',
        uri: Uri.parse('https://example.com/audio.mp3'),
      );

      expect(GlobalErrorHandler.isIgnorableMediaHttpError(error), isTrue);
    });

    test('does not ignore non-media 404 errors', () {
      final error = HttpException(
        'Invalid statusCode: 404',
        uri: Uri.parse('https://example.com/api/book'),
      );

      expect(GlobalErrorHandler.isIgnorableMediaHttpError(error), isFalse);
    });

    test('does not ignore non-404 media errors', () {
      final error = HttpException(
        'Invalid statusCode: 500',
        uri: Uri.parse('https://example.com/cover.webp'),
      );

      expect(GlobalErrorHandler.isIgnorableMediaHttpError(error), isFalse);
    });
  });
}
