import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';

/// 开始创建人授权的两阶段任务删除。
final class DeleteTaskTarget extends BaseTarget {
  /// [taskId] 是 Worker 任务公共 ID，不接受群 ID 替代。
  DeleteTaskTarget(this.taskId);

  final String taskId;

  @override
  HttpMethod get method => HttpMethod.delete;

  @override
  String get path => '/v1/tasks/$taskId';
}
