/// 任务列表筛选类型，用于统一 Dashboard 入口和网络请求参数。
enum TaskFilter {
  /// 当前用户的全部任务。
  all('all'),

  /// 截止日期为今天的任务。
  dueToday('dueToday'),

  /// 当前处于进行中状态的任务。
  inProgress('inProgress');

  /// 创建筛选类型，[apiValue] 是提交给后端的稳定参数值。
  const TaskFilter(this.apiValue);

  /// 接口 `filter` 查询参数的字符串值。
  final String apiValue;
}
