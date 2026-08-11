import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/base.target.dart';

/// 今日待办接口定义，由宿主注入的 Worker 会话访问真实服务。
class TodayTasksTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get path => '/v1/tasks/today';
}
