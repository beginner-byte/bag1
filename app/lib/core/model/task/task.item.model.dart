import 'package:worker/core/model/team/team.item.model.dart';

/// 任务列表项模型，只承载接口或 mock 数据中真实存在的展示字段。
class TaskItem {
  /// 构建任务列表项数据，避免把颜色 tone 等 UI 计算结果混入模型层。
  const TaskItem({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.title,
    this.description = '',
    required this.time,
    required this.statusLabel,
    this.isCompleted = false,
    this.assignees = const [],
  });

  /// 从接口 JSON 构建任务列表项，缺失字段使用空字符串保证 UI 层安全展示。
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final team = json['team'];
    final teamData = team is Map
        ? team.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final assignees = json['assignees'];

    return TaskItem(
      id: json['id']?.toString() ?? '',
      teamId: teamData['id']?.toString() ?? '',
      teamName: teamData['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      statusLabel: json['statusLabel']?.toString() ?? '',
      isCompleted: json['completed'] as bool? ?? false,
      assignees: assignees is List
          ? assignees
                .whereType<Map<String, dynamic>>()
                .map(TeamMemberSummary.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  /// 任务唯一标识，后续用于进入任务详情。
  final String id;

  /// 任务所属团队标识，用于在详情请求中恢复团队上下文。
  final String teamId;

  /// 任务所属团队名称，用于跨团队列表中说明任务来源。
  final String teamName;

  /// 任务标题，用于列表主文案。
  final String title;

  /// 任务描述，用于说明具体工作内容。
  final String description;

  /// 任务时间，用于提示截止时间或执行时段。
  final String time;

  /// 任务状态标签文案，用于右侧状态胶囊。
  final String statusLabel;

  /// 是否已经完成，用于计算团队任务完成情况。
  final bool isCompleted;

  /// 任务负责人，支持一项任务由多位团队成员共同负责。
  final List<TeamMemberSummary> assignees;
}
