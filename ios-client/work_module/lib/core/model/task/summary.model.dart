/// 任务汇总模型，承载 Dashboard 顶部统计卡片所需的数量数据。
class Summary {
  /// 创建任务汇总数据。
  ///
  /// 四个数量参数分别对应页面顶部的四张统计卡片。
  const Summary({
    required this.myTaskCount,
    required this.dueTodayCount,
    required this.inProgressCount,
    required this.unreadCount,
  });

  /// 从接口 JSON 构建汇总数据，异常或缺失的数量统一回退为 0。
  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      myTaskCount: int.tryParse(json['myTaskCount']?.toString() ?? '') ?? 0,
      dueTodayCount: int.tryParse(json['dueTodayCount']?.toString() ?? '') ?? 0,
      inProgressCount:
          int.tryParse(json['inProgressCount']?.toString() ?? '') ?? 0,
      unreadCount: int.tryParse(json['unreadCount']?.toString() ?? '') ?? 0,
    );
  }

  /// 当前用户负责的全部任务数量。
  final int myTaskCount;

  /// 今天截止的任务数量。
  final int dueTodayCount;

  /// 当前处于进行中状态的任务数量。
  final int inProgressCount;

  /// 当前用户尚未阅读的通知数量。
  final int unreadCount;
}
