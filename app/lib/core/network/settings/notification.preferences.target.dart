import 'package:worker/core/model/settings/notification.preferences.model.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 获取当前账号通知偏好的请求目标。
final class NotificationPreferencesTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get path => '/v1/settings/notifications';
}

/// 更新当前账号通知偏好的请求目标。
final class UpdateNotificationPreferencesTarget extends BaseTarget {
  /// 创建通知偏好更新请求。
  ///
  /// [preferences] 包含总开关及三类业务通知开关。
  UpdateNotificationPreferencesTarget(this.preferences);

  /// 准备同步到账号的完整通知偏好。
  final NotificationPreferences preferences;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/settings/notifications';

  /// 使用 JSON 一次提交完整偏好，避免并发开关更新互相覆盖。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: preferences.toJson(),
    encoding: ParameterEncoding.json,
  );
}
