import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/base.target.dart';

/// 获取当前账号全部有效登录设备的请求目标。
final class LoginDevicesTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get path => '/v1/auth/devices';
}
