import 'package:dio/dio.dart';

/// 网络层统一异常，避免业务层直接依赖 DioException 的细节。
final class NetworkException implements Exception {
  /// 创建网络异常对象。
  const NetworkException({required this.message, this.statusCode, this.error});

  /// 给页面或业务层使用的错误文案。
  final String message;

  /// HTTP 状态码，没有响应时为空。
  final int? statusCode;

  /// 原始异常对象，便于日志上报或调试。
  final Object? error;

  /// 将 Dio 异常转换为项目统一异常。
  ///
  /// [exception] 是 Dio 请求过程中抛出的异常。
  factory NetworkException.fromDio(DioException exception) {
    final statusCode = exception.response?.statusCode;

    return NetworkException(
      message: _messageFromDio(exception),
      statusCode: statusCode,
      error: exception,
    );
  }

  /// 根据 Dio 异常类型转换用户可读文案。
  static String _messageFromDio(DioException exception) {
    if (exception.response?.statusCode == 401) {
      return '登录已失效,请重新登录!';
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return '网络连接超时';
      case DioExceptionType.badResponse:
        return '服务器响应异常';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      case DioExceptionType.badCertificate:
        return '证书校验失败';
      case DioExceptionType.unknown:
        return '网络请求失败';
    }
  }

  @override
  String toString() => message;
}
