/// 当前账号的永久删除预约状态。
final class AccountDeletionStatus {
  /// 创建账号删除状态。
  ///
  /// [scheduled] 表示是否存在有效预约；[scheduledAt] 是服务器返回的 UTC 删除时间。
  const AccountDeletionStatus({
    required this.scheduled,
    required this.scheduledAt,
  });

  /// 是否已预约永久删除。
  final bool scheduled;

  /// 预约删除的准确时间；未预约或服务端时间无效时为空。
  final DateTime? scheduledAt;

  /// 从服务端账号删除状态对象创建模型。
  ///
  /// [json] 必须包含 scheduled；scheduledAt 缺失或无法解析时安全回退为空。
  factory AccountDeletionStatus.fromJson(dynamic json) {
    if (json is! Map) {
      return const AccountDeletionStatus(scheduled: false, scheduledAt: null);
    }
    // scheduled 表示服务端当前仍保留一条可撤销删除请求。
    final scheduled = json['scheduled'] == true;
    // scheduledAt 统一解析为 UTC 时间，页面展示时再转换为设备本地时区。
    final scheduledAt = DateTime.tryParse(
      json['scheduledAt']?.toString() ?? '',
    )?.toUtc();
    return AccountDeletionStatus(
      scheduled: scheduled && scheduledAt != null,
      scheduledAt: scheduled ? scheduledAt : null,
    );
  }
}
