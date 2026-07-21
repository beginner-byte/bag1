/// 当前账号的通知偏好，用于在不同登录设备之间同步提醒开关。
final class NotificationPreferences {
  /// 创建通知偏好模型。
  const NotificationPreferences({
    required this.enabled,
    required this.taskAssigned,
    required this.dueReminder,
    required this.collaborationMessages,
  });

  /// 是否允许 Worker 向当前账号发送任何通知。
  final bool enabled;

  /// 是否接收任务分配通知。
  final bool taskAssigned;

  /// 是否接收任务截止时间提醒。
  final bool dueReminder;

  /// 是否接收团队协作消息通知。
  final bool collaborationMessages;

  /// 使用服务端响应创建通知偏好，缺失字段采用安全默认值。
  factory NotificationPreferences.fromJson(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return defaults;
    }

    return NotificationPreferences(
      enabled: data['enabled'] as bool? ?? true,
      taskAssigned: data['taskAssigned'] as bool? ?? true,
      dueReminder: data['dueReminder'] as bool? ?? true,
      collaborationMessages: data['collaborationMessages'] as bool? ?? true,
    );
  }

  /// 新账号默认开启所有通知，用户可以在应用设置中逐项关闭。
  static const defaults = NotificationPreferences(
    enabled: true,
    taskAssigned: true,
    dueReminder: true,
    collaborationMessages: true,
  );

  /// 创建只替换指定字段的新实例，避免开关操作丢失其他偏好。
  NotificationPreferences copyWith({
    bool? enabled,
    bool? taskAssigned,
    bool? dueReminder,
    bool? collaborationMessages,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      taskAssigned: taskAssigned ?? this.taskAssigned,
      dueReminder: dueReminder ?? this.dueReminder,
      collaborationMessages:
          collaborationMessages ?? this.collaborationMessages,
    );
  }

  /// 转换为网络层提交的 JSON 字段。
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'taskAssigned': taskAssigned,
      'dueReminder': dueReminder,
      'collaborationMessages': collaborationMessages,
    };
  }
}
