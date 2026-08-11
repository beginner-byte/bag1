import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/base.target.dart';

/// 获取当前账号最近通知的请求目标。
final class NotificationsTarget extends BaseTarget {
  /// 通知列表使用只读 GET 请求。
  @override
  HttpMethod get method => HttpMethod.get;

  /// 通知中心统一读取路径。
  @override
  String get path => '/v1/notifications';
}
