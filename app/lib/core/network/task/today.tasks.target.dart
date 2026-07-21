import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/base.target.dart';

/// 今日待办接口定义，mock 响应由 MockAuthBackend 统一模拟。
class TodayTasksTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get path => '/v1/tasks/today';
}
