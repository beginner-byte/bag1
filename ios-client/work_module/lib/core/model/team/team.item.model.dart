/// 团队列表项模型，承载列表卡片需要的基础信息。
class TeamItem {
  /// 创建团队列表项。
  const TeamItem({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    required this.creator,
    required this.members,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    this.groupId = '',
    this.groupStatus = 'legacy',
    this.groupAction = 'none',
    this.groupOperationId = '',
  });

  /// 从接口 JSON 构建团队，缺失或非法日期安全回退为 null。
  factory TeamItem.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    final creatorData = creator is Map
        ? creator.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final members = json['members'];

    return TeamItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      creator: TeamMemberSummary.fromJson(creatorData),
      members: members is List
          ? members
                .whereType<Map<String, dynamic>>()
                .map(TeamMemberSummary.fromJson)
                .toList(growable: false)
          : const [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      groupId: json['groupId']?.toString() ?? '',
      groupStatus: json['groupStatus']?.toString() ?? 'legacy',
      groupAction: json['groupAction']?.toString() ?? 'none',
      groupOperationId: json['groupOperationId']?.toString() ?? '',
    );
  }

  /// 复制团队快照，仅替换调用方明确传入的成员列表。
  TeamItem copyWith({List<TeamMemberSummary>? members}) {
    return TeamItem(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      creator: creator,
      members: members ?? this.members,
      createdAt: createdAt,
      startDate: startDate,
      endDate: endDate,
      groupId: groupId,
      groupStatus: groupStatus,
      groupAction: groupAction,
      groupOperationId: groupOperationId,
    );
  }

  /// 团队唯一标识，后续用于进入团队详情。
  final String id;

  /// 团队名称。
  final String name;

  /// 团队介绍，空字符串表示创建者尚未填写。
  final String description;

  /// 团队头像地址，空字符串表示使用团队图标兜底。
  final String avatarUrl;

  /// 团队创建人的简要信息。
  final TeamMemberSummary creator;

  /// 团队成员摘要，用于列表头像预览。
  final List<TeamMemberSummary> members;

  /// 团队创建时间。
  final DateTime? createdAt;

  /// 团队计划开始日期。
  final DateTime? startDate;

  /// 团队计划结束日期，null 表示没有固定截止日期。
  final DateTime? endDate;

  /// CandyTalk 群唯一标识；建群绑定成功前为空。
  final String groupId;

  /// Worker 保存的团队群生命周期状态。
  final String groupStatus;

  /// Worker 当前允许创建人执行的下一步动作。
  final String groupAction;

  /// 已领取建群操作的幂等标识；未领取时为空。
  final String groupOperationId;
}

/// 团队成员摘要，只保留列表头像和创建人展示需要的字段。
class TeamMemberSummary {
  /// 创建团队成员摘要。
  const TeamMemberSummary({
    required this.id,
    this.candyUserUid = '',
    required this.name,
    required this.avatarUrl,
  });

  /// 从接口 JSON 构建成员摘要，头像缺失时保留空值供 UI 使用姓名兜底。
  factory TeamMemberSummary.fromJson(Map<String, dynamic> json) {
    return TeamMemberSummary(
      id: json['id']?.toString() ?? '',
      candyUserUid: json['candyUserUid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
    );
  }

  /// 成员唯一标识。
  final String id;

  /// CandyTalk 稳定用户标识，仅由 iOS 换票创建的 Worker 账号返回。
  final String candyUserUid;

  /// 成员展示名称。
  final String name;

  /// 成员头像地址，空字符串表示使用姓名首字兜底。
  final String avatarUrl;
}

/// Worker 决定的团队群创建命令。
final class TeamGroupCommand {
  /// 从团队群接口 JSON 构建命令和完整成员集合。
  factory TeamGroupCommand.fromJson(Map<String, dynamic> json) {
    final members = json['members'];
    return TeamGroupCommand(
      action: json['action']?.toString() ?? 'none',
      teamId: json['teamId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      operationId: json['operationId']?.toString() ?? '',
      members: members is List
          ? members
                .whereType<Map<String, dynamic>>()
                .map(TeamMemberSummary.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  /// 创建不可变团队群命令。
  const TeamGroupCommand({
    required this.action,
    required this.teamId,
    required this.title,
    required this.operationId,
    required this.members,
  });

  /// `create` 表示当前创建人设备应执行建群。
  final String action;

  /// Worker 团队公开标识。
  final String teamId;

  /// CandyTalk 初始群名称。
  final String title;

  /// 本次领取操作的 UUID。
  final String operationId;

  /// 当前团队全部成员，首次建群至少三人。
  final List<TeamMemberSummary> members;
}

/// 添加成员后的兼容响应，并携带可能的建群动作。
final class AddTeamMemberResult {
  /// 解析旧成员字段和新增动作字段。
  factory AddTeamMemberResult.fromJson(Map<String, dynamic> json) =>
      AddTeamMemberResult(
        member: TeamMemberSummary.fromJson(json),
        action: json['action']?.toString() ?? 'none',
        teamId: json['teamId']?.toString() ?? '',
      );

  /// 创建添加成员结果。
  const AddTeamMemberResult({
    required this.member,
    required this.action,
    required this.teamId,
  });

  /// 已加入或已邀请的成员摘要。
  final TeamMemberSummary member;

  /// `create` 表示需要继续领取团队群创建。
  final String action;

  /// 动作归属团队公开标识。
  final String teamId;
}

/// Worker 领取的一条团队群成员邀请命令。
final class TeamGroupMemberCommand {
  /// 从 Worker JSON 构建成员邀请命令。
  factory TeamGroupMemberCommand.fromJson(Map<String, dynamic> json) {
    final member = json['member'];
    return TeamGroupMemberCommand(
      action: json['action']?.toString() ?? 'none',
      teamId: json['teamId']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      operationId: json['operationId']?.toString() ?? '',
      member: TeamMemberSummary.fromJson(
        member is Map<String, dynamic> ? member : const {},
      ),
    );
  }

  /// 创建不可变成员邀请命令。
  const TeamGroupMemberCommand({
    required this.action,
    required this.teamId,
    required this.groupId,
    required this.operationId,
    required this.member,
  });

  /// `invite_member` 表示应调用 CandyTalk 邀请接口。
  final String action;

  /// Worker 团队公开标识。
  final String teamId;

  /// 已绑定 CandyTalk 群标识。
  final String groupId;

  /// 本次领取操作的 UUID。
  final String operationId;

  /// 本次需要邀请的新团队成员。
  final TeamMemberSummary member;
}
