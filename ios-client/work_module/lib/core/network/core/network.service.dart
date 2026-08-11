import 'dart:async';

import 'package:dio/dio.dart' hide Response;
import 'package:get/get.dart' hide FormData, Response;
import 'package:work_module/core/network/core/response.dart';
import 'package:work_module/core/network/core/target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/network.exception.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/service/work_session_service.dart';

/// 全局网络服务，负责 Dio 初始化、请求发送和响应外壳解析。
final class NetworkService extends GetxService {
  /// Dio 实例只暴露在网络层内部，避免业务层绕过统一解析。
  final Dio _dio;

  /// 是否正在处理会话失效，用于阻止并发 401 重复通知宿主。
  bool _handlingUnauthorized = false;

  /// Worker 会话失效时通知 ios-client 的回调。
  final Future<void> Function() _onUnauthorized;

  /// 创建网络服务。
  ///
  /// [baseUrl] 是默认接口域名。
  /// [onUnauthorized] 将 401 交还 ios-client 用户体系处理。
  NetworkService({
    required String baseUrl,
    required Future<void> Function() onUnauthorized,
    // 保留对外参数名，避免把私有字段名暴露为构造参数。
  }) : _onUnauthorized = onUnauthorized, // ignore: prefer_initializing_formals
       _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           sendTimeout: const Duration(seconds: 15),
           headers: const {'Accept': 'application/json'},
         ),
       );

  /// 发送接口请求并解析后端统一响应外壳。
  ///
  /// [target] 描述接口路径、方法和参数。
  /// [decoder] 负责把响应 `data` 字段转换为业务模型。
  /// [cancelToken] 用于取消请求。
  /// HTTP 401 会清理模块内存会话并通知 ios-client 重新处理身份。
  Future<Response<T>> fetch<T>(
    Target target, {
    T Function(dynamic data)? decoder,
    CancelToken? cancelToken,
  }) async {
    try {
      final requestData = _resolveRequestData(target);
      final response = await _dio.request<dynamic>(
        _resolvePath(target),
        data: requestData.body,
        queryParameters: requestData.queryParameters,
        cancelToken: cancelToken,
        options: Options(
          method: target.method.value,
          headers: target.headers,
          contentType: requestData.contentType ?? target.contentType,
          responseType: target.responseType,
        ),
      );

      return Response<T>.fromJson(response.data, decoder: decoder);
    } on DioException catch (exception) {
      // networkException 保留统一错误文案和 HTTP 状态码，供网络层与页面共同判断。
      final networkException = NetworkException.fromDio(exception);
      if (networkException.statusCode == 401) {
        _handleUnauthorized();
      }
      throw networkException;
    } catch (error) {
      throw NetworkException(message: '网络请求失败', error: error);
    }
  }

  /// 启动会话失效处理，并忽略同一时间到达的其他 401 响应。
  ///
  /// 该方法不等待宿主处理完成，以便请求方立即接收异常并显示现有提示。
  void _handleUnauthorized() {
    if (_handlingUnauthorized) {
      return;
    }

    _handlingUnauthorized = true;
    unawaited(_clearSessionAndNotifyHost());
  }

  /// 清理模块内存会话并通知宿主，不执行任何 Worker 登录页跳转。
  Future<void> _clearSessionAndNotifyHost() async {
    try {
      if (Get.isRegistered<WorkSessionService>()) {
        Get.find<WorkSessionService>().clear();
      }
      await _onUnauthorized();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  /// 解析最终请求路径，允许单个接口覆盖默认 baseUrl。
  String _resolvePath(Target target) {
    final baseUrl = target.baseUrl;

    if (baseUrl == null || baseUrl.isEmpty) {
      return target.path;
    }

    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = target.path.startsWith('/')
        ? target.path
        : '/${target.path}';

    return '$normalizedBaseUrl$normalizedPath';
  }

  /// 根据 Target 的 task 和 encoding 解析 Dio 需要的请求参数。
  _RequestData _resolveRequestData(Target target) {
    final task = target.task;
    final parameters = task.parameters;

    if (parameters == null || parameters.isEmpty) {
      return const _RequestData();
    }

    switch (task.encoding) {
      case ParameterEncoding.query:
        return _RequestData(queryParameters: parameters);
      case ParameterEncoding.json:
        return _RequestData(
          body: parameters,
          contentType: Headers.jsonContentType,
        );
      case ParameterEncoding.form:
        return _RequestData(
          body: parameters,
          contentType: Headers.formUrlEncodedContentType,
        );
      case ParameterEncoding.multipart:
        return _RequestData(
          body: FormData.fromMap(parameters),
          contentType: Headers.multipartFormDataContentType,
        );
      case null:
        return const _RequestData();
    }
  }
}

/// Dio 请求参数解析结果，避免 body 和 queryParameters 在 Target 中同时暴露。
final class _RequestData {
  /// 创建 Dio 请求参数解析结果。
  const _RequestData({this.body, this.queryParameters, this.contentType});

  /// 请求体参数。
  final Object? body;

  /// URL query 参数。
  final Map<String, dynamic>? queryParameters;

  /// 当前请求实际使用的 content type。
  final String? contentType;
}
