import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 将原生 CandyTalk 建群结果幂等绑定到 Worker 任务。
final class BindTaskGroupTarget extends BaseTarget {
  /// 创建群绑定请求，成员 UID 用于服务端与任务负责人集合交叉校验。
  BindTaskGroupTarget({
    required this.taskId,
    required this.groupId,
    required this.operationId,
    required this.memberCandyUserUids,
  });

  final String taskId;
  final String groupId;
  final String operationId;
  final List<String> memberCandyUserUids;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/tasks/group/bind';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'taskId': taskId,
      'groupId': groupId,
      'operationId': operationId,
      'memberCandyUserUids': memberCandyUserUids,
    },
    encoding: ParameterEncoding.json,
  );
}
