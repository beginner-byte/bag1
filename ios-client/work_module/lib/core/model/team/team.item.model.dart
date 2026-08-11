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
