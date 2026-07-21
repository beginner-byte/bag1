import 'dart:async';

import 'package:dio/dio.dart' hide Response;
import 'package:get/get.dart' hide FormData, Response;
import 'package:worker/app/route/router.dart';
import 'package:worker/core/network/auth/core/response.dart';
import 'package:worker/core/network/auth/core/target.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/mock.interceptor.dart';
import 'package:worker/core/network/auth/core/network.exception.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/service/auth.service.dart';

/// 全局网络服务，负责 Dio 初始化、请求发送和响应外壳解析。
final class NetworkService extends GetxService {
  /// Dio 实例只暴露在网络层内部，避免业务层绕过统一解析。
  final Dio _dio;

  /// 是否正在处理登录失效，用于阻止并发 401 重复清理会话和跳转。
  bool _handlingUnauthorized = false;

  /// 创建网络服务。
  ///
  /// [baseUrl] 是默认接口域名。
  /// [enableMock] 控制是否通过 ApiTarget.sampleData 返回 mock 响应。
  NetworkService({String baseUrl = '', bool enableMock = false})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(MockInterceptor(enabled: enableMock));
  }

  /// 发送接口请求并解析后端统一响应外壳。
  ///
  /// [target] 描述接口路径、方法、参数和 mock 数据。
  /// [decoder] 负责把响应 `data` 字段转换为业务模型。
  /// [cancelToken] 用于取消请求。
  /// HTTP 401 会触发一次全局会话清理，并在现有失效提示结束后返回登录页。
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
          extra: {MockInterceptorKeys.target: target},
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

  /// 启动登录失效处理，并忽略同一时间到达的其他 401 响应。
  ///
  /// 该方法不等待跳转完成，以便请求方立即接收异常并显示现有失效提示。
  void _handleUnauthorized() {
    if (_handlingUnauthorized) {
      return;
    }

    _handlingUnauthorized = true;
    unawaited(_clearSessionAndReturnToAuth());
  }

  /// 清理安全存储中的失效会话，等待默认提示时长后清空路由栈并进入登录页。
  ///
  /// 安全存储删除失败时仍会跳转，避免用户继续停留在已失效的受保护页面。
  Future<void> _clearSessionAndReturnToAuth() async {
    try {
      try {
        if (Get.isRegistered<AuthService>()) {
          await Get.find<AuthService>().clearSession();
        }
      } catch (_) {
        // 存储异常不能阻断退出受保护页面，路由跳转仍按失效会话执行。
      }

      // 两秒与 EasyLoading 默认 Toast 时长一致，确保用户先看完失效提示。
      await Future<void>.delayed(const Duration(seconds: 2));
      GetRouter.onAuth();
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
