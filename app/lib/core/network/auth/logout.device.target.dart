import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/base.target.dart';

/// 撤销当前账号指定登录设备的请求目标。
final class LogoutDeviceTarget extends BaseTarget {
  /// 创建撤销设备请求；[sessionId] 必须来自设备列表接口。
  LogoutDeviceTarget({required this.sessionId});

  /// 准备撤销的服务端公开会话标识。
  final String sessionId;

  @override
  HttpMethod get method => HttpMethod.delete;

  @override
  String get path => '/v1/auth/devices/$sessionId';
}
