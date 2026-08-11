import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/network/base.target.dart';

/// 提交通知接受、拒绝或确认结果的请求目标。
final class HandleNotificationTarget extends BaseTarget {
  /// 创建通知处理请求。
  ///
  /// [notificationId] 是待处理通知标识；[action] 仅允许当前通知类型支持的动作。
  HandleNotificationTarget({
    required this.notificationId,
    required this.action,
  });

  /// 待处理通知的服务端唯一标识。
  final String notificationId;

  /// 本次业务动作：accept、reject 或 confirm。
  final String action;

  /// 处理通知会更新服务端业务状态，因此使用 PATCH。
  @override
  HttpMethod get method => HttpMethod.patch;

  /// 所有通知决策共用一个受保护接口。
  @override
  String get path => '/v1/notifications/action';

  /// 把通知标识和动作编码为 JSON 请求体。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'notificationId': notificationId, 'action': action},
    encoding: ParameterEncoding.json,
  );
}
