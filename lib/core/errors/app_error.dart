/// 应用错误类型基类
/// 使用 sealed class 实现穷尽式错误处理
sealed class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message';
}

/// 网络错误
class NetworkError extends AppError {
  final int? statusCode;

  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkError($statusCode): $message';
}

/// 解析错误
class ParseError extends AppError {
  final String? rule;

  const ParseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.rule,
  });

  @override
  String toString() => 'ParseError: $message (rule: $rule)';
}

/// 数据库错误
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DatabaseError: $message';
}

/// 存储错误
class StorageError extends AppError {
  const StorageError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'StorageError: $message';
}

/// 配置错误
class ConfigError extends AppError {
  const ConfigError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ConfigError: $message';
}

/// 书源错误
class BookSourceError extends AppError {
  final String? sourceName;

  const BookSourceError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.sourceName,
  });

  @override
  String toString() => 'BookSourceError($sourceName): $message';
}

/// 验证错误
class ValidationError extends AppError {
  final String? field;

  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.field,
  });

  @override
  String toString() => 'ValidationError($field): $message';
}

/// 权限错误
class PermissionError extends AppError {
  const PermissionError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'PermissionError: $message';
}

/// 超时错误
class TimeoutError extends AppError {
  const TimeoutError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'TimeoutError: $message';
}

/// 取消错误
class CancelledError extends AppError {
  const CancelledError({
    super.message = '操作已取消',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'CancelledError: $message';
}

/// 未知错误
class UnknownError extends AppError {
  const UnknownError({
    super.message = '未知错误',
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnknownError: $message';
}

/// 结果类型
/// 用于函数返回值，支持成功和错误状态
sealed class Result<T> {
  const Result();

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failure<T>;

  /// 获取数据（成功时）
  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };

  /// 获取错误（失败时）
  AppError? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(error: final e) => e,
      };

  /// 转换数据类型
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final d) => Success(mapper(d)),
      Failure<T>(error: final e) => Failure(e),
    };
  }

  /// 异步转换数据类型
  Future<Result<R>> asyncMap<R>(Future<R> Function(T data) mapper) async {
    return switch (this) {
      Success<T>(data: final d) => Success(await mapper(d)),
      Failure<T>(error: final e) => Failure(e),
    };
  }

  /// 获取数据或默认值
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(data: final d) => d,
      Failure<T>() => defaultValue,
    };
  }

  /// 获取数据或抛出错误
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final d) => d,
      Failure<T>(error: final e) => throw e,
    };
  }

  /// 执行成功回调
  Result<T> onSuccess(void Function(T data) action) {
    if (this case Success<T>(data: final d)) {
      action(d);
    }
    return this;
  }

  /// 执行失败回调
  Result<T> onFailure(void Function(AppError error) action) {
    if (this case Failure<T>(error: final e)) {
      action(e);
    }
    return this;
  }
}

/// 成功结果
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success: $data';
}

/// 失败结果
final class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error);

  @override
  String toString() => 'Failure: $error';
}

/// 错误处理工具类
class ErrorHandler {
  ErrorHandler._();

  /// 将异常转换为 AppError
  static AppError fromException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    if (error is FormatException) {
      return ParseError(
        message: '格式解析错误: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is ArgumentError) {
      return ValidationError(
        message: '参数错误: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is StateError) {
      return ConfigError(
        message: '状态错误: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is Exception) {
      final errorStr = error.toString().toLowerCase();

      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        return NetworkError(
          message: '网络错误: $error',
          originalError: error,
          stackTrace: stackTrace,
        );
      }

      if (errorStr.contains('timeout')) {
        return TimeoutError(
          message: '请求超时',
          originalError: error,
          stackTrace: stackTrace,
        );
      }

      if (errorStr.contains('cancel')) {
        return CancelledError(
          originalError: error,
          stackTrace: stackTrace,
        );
      }
    }

    return UnknownError(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// 安全执行函数，返回 Result
  static Future<Result<T>> safeCall<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(fromException(e, stackTrace));
    }
  }

  /// 安全执行同步函数，返回 Result
  static Result<T> safeCallSync<T>(T Function() fn) {
    try {
      final result = fn();
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(fromException(e, stackTrace));
    }
  }

  /// 获取用户友好的错误消息
  static String getUserMessage(AppError error) {
    return switch (error) {
      NetworkError(:final statusCode) =>
        '网络错误${statusCode != null ? ' ($statusCode)' : ''}，请检查网络连接',
      ParseError() => '数据解析错误，请稍后重试',
      DatabaseError() => '数据库错误，请稍后重试',
      StorageError() => '存储错误，请检查存储空间',
      ConfigError() => '配置错误，请重置应用设置',
      BookSourceError(:final sourceName) =>
        '书源错误${sourceName != null ? ' ($sourceName)' : ''}，请检查书源配置',
      ValidationError(:final field) =>
        '验证错误${field != null ? ' ($field)' : ''}，请检查输入',
      PermissionError() => '权限不足，请在设置中授权',
      TimeoutError() => '操作超时，请重试',
      CancelledError() => '操作已取消',
      UnknownError() => '发生未知错误，请稍后重试',
    };
  }
}
