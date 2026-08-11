import 'package:work_module/core/model/team/team.item.model.dart';

/// 服务端支持的通知业务类型。
enum WorkerNotificationType {
  teamInvitation,
  taskCompletion,
  unknown;

  /// 将 [value] 的接口字符串转换为稳定枚举，未知值安全回退到 [unknown]。
  static WorkerNotificationType fromWireValue(Object? value) {
    return switch (value?.toString()) {
      'teamInvitation' => teamInvitation,
      'taskCompletion' => taskCompletion,
      _ => unknown,
    };
  }
}

/// 通知的待处理或最终决策状态。
enum WorkerNotificationStatus {
  pending,
  accepted,
  rejected,
  confirmed,
  unknown;

  /// 将 [value] 的接口字符串转换为稳定枚举，未知值安全回退到 [unknown]。
  static WorkerNotificationStatus fromWireValue(Object? value) {
    return switch (value?.toString()) {
      'pending' => pending,
      'accepted' => accepted,
      'rejected' => rejected,
      'confirmed' => confirmed,
      _ => unknown,
    };
  }
}

/// 通知中心展示的一条邀请或任务完成确认。
final class WorkerNotificationItem {
  /// 创建通知模型；关联团队或任务不存在时对应字段保持为空字符串。
  const WorkerNotificationItem({
    required this.id,
    required this.type,
    required this.status,
    required this.actor,
    required this.teamId,
    required this.teamName,
    required this.taskId,
    required this.taskTitle,
    required this.taskNote,
    required this.createdAt,
  });

  /// 从 [json] 构建通知模型，并对缺失的关联对象使用安全默认值。
  factory WorkerNotificationItem.fromJson(Map<String, dynamic> json) {
    // actor、team 和 task 保留结构化数据，避免服务端文案破坏客户端多语言能力。
    final actor = json['actor'];
    final team = json['team'];
    final task = json['task'];
    // createdAt 解析失败时使用纪元时间，确保模型字段始终非空且可排序。
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');

    return WorkerNotificationItem(
      id: json['id']?.toString() ?? '',
      type: WorkerNotificationType.fromWireValue(json['type']),
      status: WorkerNotificationStatus.fromWireValue(json['status']),
      actor: actor is Map<String, dynamic>
          ? TeamMemberSummary.fromJson(actor)
          : const TeamMemberSummary(id: '', name: '', avatarUrl: ''),
      teamId: team is Map ? team['id']?.toString() ?? '' : '',
      teamName: team is Map ? team['name']?.toString() ?? '' : '',
      taskId: task is Map ? task['id']?.toString() ?? '' : '',
      taskTitle: task is Map ? task['title']?.toString() ?? '' : '',
      taskNote: task is Map ? task['note']?.toString() ?? '' : '',
      createdAt: createdAt?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// 服务端生成的通知唯一标识，用于防止重复处理。
  final String id;

  /// 通知业务类型，决定卡片文案和可用操作。
  final WorkerNotificationType type;

  /// 当前处理状态；只有 [WorkerNotificationStatus.pending] 显示操作按钮。
  final WorkerNotificationStatus status;

  /// 发起邀请或提交任务完成的用户摘要。
  final TeamMemberSummary actor;

  /// 邀请关联的团队标识，任务通知中允许为空。
  final String teamId;

  /// 邀请关联的团队名称，用于本地化消息参数。
  final String teamName;

  /// 完成确认关联的任务标识，邀请通知中允许为空。
  final String taskId;

  /// 完成确认关联的任务标题。
  final String taskTitle;

  /// 负责人提交完成时填写的可选说明。
  final String taskNote;

  /// 服务端创建时间，已经转换为设备本地时区。
  final DateTime createdAt;

  /// 返回只更新 [status] 的新实例，保留通知关联信息不变。
  WorkerNotificationItem copyWithStatus(WorkerNotificationStatus status) {
    return WorkerNotificationItem(
      id: id,
      type: type,
      status: status,
      actor: actor,
      teamId: teamId,
      teamName: teamName,
      taskId: taskId,
      taskTitle: taskTitle,
      taskNote: taskNote,
      createdAt: createdAt,
    );
  }
}
