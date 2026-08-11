import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// CandyTalk 解散成功后关闭 Worker 任务生命周期。
final class DissolvedTaskGroupTarget extends BaseTarget {
  /// 构造任务删除来源的幂等完成请求。
  DissolvedTaskGroupTarget({required this.groupId, required this.operationId});

  final String groupId;
  final String operationId;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/tasks/group/dissolved';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'groupId': groupId,
      'operationId': operationId,
      'source': 'task_delete',
    },
    encoding: ParameterEncoding.json,
  );
}
