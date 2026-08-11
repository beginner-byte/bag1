import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/network/base.target.dart';

/// 更新任务状态接口，当前支持完成和延后两种首页快捷操作。
class UpdateTaskStatusTarget extends BaseTarget {
  UpdateTaskStatusTarget({
    required this.taskId,
    required this.status,
    this.note = '',
  });

  /// 需要更新的任务标识。
  final String taskId;

  /// 服务端状态值，仅允许 completed 或 postponed。
  final String status;

  /// 本次状态操作的可选情况说明，为空时不提交该字段。
  final String note;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/tasks/status';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'taskId': taskId,
      'status': status,
      if (note.trim().isNotEmpty) 'note': note.trim(),
    },
    encoding: ParameterEncoding.json,
  );
}
