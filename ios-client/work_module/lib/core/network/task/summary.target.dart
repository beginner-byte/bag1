import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/base.target.dart';

/// 任务汇总接口定义，由宿主注入的 Worker 会话访问真实服务。
class SummaryTarget extends BaseTarget {
  /// 任务汇总使用 GET 请求读取当前用户的统计数据。
  @override
  HttpMethod get method => HttpMethod.get;

  /// 保留现有接口路径，避免仓库调整影响后端协议。
  @override
  String get path => '/v1/task/summary';
}
