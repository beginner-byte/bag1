import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/network/base.target.dart';

/// 任务列表接口定义，通过查询参数复用同一个列表接口。
class TasksTarget extends BaseTarget {
  /// 创建任务列表请求，[filter] 决定任务范围，[teamId] 可限定所属团队。
  TasksTarget(this.filter, {this.teamId = ''});

  /// 当前列表需要应用的任务筛选。
  final TaskFilter filter;

  /// 团队标识，空字符串表示不限制团队。
  final String teamId;

  /// 任务列表使用 GET 请求。
  @override
  HttpMethod get method => HttpMethod.get;

  /// 所有筛选共用同一个任务列表路径。
  @override
  String get path => '/v1/tasks';

  /// 将筛选值放入 URL query，保持 GET 请求语义清晰。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'filter': filter.apiValue,
      if (teamId.isNotEmpty) 'teamId': teamId,
    },
    encoding: ParameterEncoding.query,
  );
}
