import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/network/base.target.dart';

/// 创建团队任务接口定义。
class CreateTaskTarget extends BaseTarget {
  /// 创建任务请求，负责人使用稳定用户 ID 提交，避免依赖展示名称。
  CreateTaskTarget({
    required this.teamId,
    required this.title,
    required this.description,
    required this.time,
    required this.assigneeIds,
  });

  /// 任务所属团队标识。
  final String teamId;

  /// 任务标题。
  final String title;

  /// 任务描述，说明需要完成的具体内容。
  final String description;

  /// 任务时间或截止时间文案。
  final String time;

  /// 负责人用户 ID，允许多人共同负责。
  final List<String> assigneeIds;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/tasks';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'teamId': teamId,
      'title': title,
      'description': description,
      'time': time,
      'assigneeIds': assigneeIds,
    },
    encoding: ParameterEncoding.json,
  );
}
