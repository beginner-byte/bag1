import 'package:dio/dio.dart';
import 'package:worker/core/network/mock/mock_auth_backend.dart';
import 'package:worker/core/network/auth/core/target.dart';

/// Dio mock 拦截器，用于在开发阶段直接返回接口定义中的 sampleData。
final class MockInterceptor extends Interceptor {
  /// 创建 mock 拦截器。
  MockInterceptor({required this.enabled});

  /// 是否启用 mock 响应。
  final bool enabled;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      return handler.next(options);
    }

    final target = options.extra[MockInterceptorKeys.target];

    if (target is! Target) {
      return handler.next(options);
    }

    await Future<void>.delayed(target.sampleDelay);

    /// 认证接口需要动态状态，优先交给 mock 后端处理注册和登录关系。
    final dynamicData = await MockAuthBackend.instance.resolve(
      path: target.path,
      body: options.data,
      queryParameters: options.queryParameters,
      headers: options.headers,
    );
    final data = dynamicData ?? target.sampleData;

    if (data == null) {
      return handler.next(options);
    }

    return handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: target.sampleStatusCode,
        data: data,
      ),
    );
  }
}

/// mock 拦截器使用的 extra key，集中定义避免字符串散落。
final class MockInterceptorKeys {
  MockInterceptorKeys._();

  /// 在 Dio RequestOptions.extra 中保存 ApiTarget。
  static const target = 'AppTarget';
}
