import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 为仍在等待成员的任务追加负责人。
final class AddTaskAssigneesTarget extends BaseTarget {
  /// 使用任务 ID 和去重后的 Worker 用户 ID 创建请求。
  AddTaskAssigneesTarget({required this.taskId, required this.assigneeIds});

  /// Worker 任务公开 ID。
  final String taskId;

  /// 新增负责人 Worker 用户 ID。
  final List<String> assigneeIds;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/tasks/assignees';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'taskId': taskId, 'assigneeIds': assigneeIds},
    encoding: ParameterEncoding.json,
  );
}
