import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 记录一次原生建群失败，保留任务供创建人重试。
final class FailTaskGroupTarget extends BaseTarget {
  /// 创建失败上报请求；message 仅携带用户安全文案。
  FailTaskGroupTarget({
    required this.taskId,
    required this.operationId,
    required this.message,
  });

  final String taskId;
  final String operationId;
  final String message;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/tasks/group/failure';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'taskId': taskId,
      'operationId': operationId,
      'message': message,
    },
    encoding: ParameterEncoding.json,
  );
}
