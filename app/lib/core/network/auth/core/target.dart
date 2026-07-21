import 'package:dio/dio.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';

/// 接口目标定义，作用类似 Swift Moya 的 TargetType。
///
/// 每个接口通过实现此协议声明请求路径、请求方式、参数和 mock 数据。
abstract class Target {
  /// 接口路径，例如 `/user/profile`。
  String get path;

  /// 请求方法，例如 GET 或 POST。
  HttpMethod get method;

  /// 单个接口需要覆盖全局 baseUrl 时使用。
  String? get baseUrl => null;

  /// 请求任务，统一描述参数和编码方式，避免调用层同时关心 query 和 body。
  RequestTask get task => const RequestTask.plain();

  /// 请求体数据，通常用于 POST、PUT、PATCH 请求。
  Object? get body => null;

  /// 当前接口额外请求头，会和全局请求头合并。
  Map<String, dynamic>? get headers => null;

  /// 请求内容类型，默认使用 JSON。
  String? get contentType => Headers.jsonContentType;

  /// 响应类型，普通 JSON 接口通常不需要覆盖。
  ResponseType? get responseType => null;

  /// mock 模式下返回的响应数据，需要保持和真实接口响应结构一致。
  Object? get sampleData => null;

  /// mock 模式下返回的 HTTP 状态码。
  int get sampleStatusCode => 200;

  /// mock 模式下模拟的网络延迟。
  Duration get sampleDelay => const Duration(milliseconds: 300);
}
