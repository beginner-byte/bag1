import 'package:get/get.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/core/network/core/network.service.dart';
import 'package:work_module/core/network/team/add.team.member.target.dart';
import 'package:work_module/core/network/team/create.team.target.dart';
import 'package:work_module/core/network/team/search.team.member.target.dart';
import 'package:work_module/core/network/team/teams.target.dart';
import 'package:work_module/core/network/team/team.group.targets.dart';

/// 团队数据仓库，隔离页面控制器与网络响应解析。
class TeamRepository {
  /// 通过用户 ID 或注册邮箱查询成员摘要；用户不存在时返回 null。
  Future<TeamMemberSummary?> searchMember(String keyword) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<TeamMemberSummary>(
      SearchTeamMemberTarget(keyword: keyword),
      decoder: (data) =>
          TeamMemberSummary.fromJson(data as Map<String, dynamic>),
    );

    if (response.code == 0 && response.data != null) {
      return response.data;
    }

    if (response.code == 4041) {
      return null;
    }

    throw response.message ?? '搜索用户失败';
  }

  /// 通过 [teamId] 和 [userId] 发送团队邀请；只有对方接受后才建立成员关系。
  ///
  /// 成功时无返回值；用户不存在、已经加入或已有待处理邀请时抛出服务端错误。
  Future<void> inviteMember({
    required String teamId,
    required String userId,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<void>(
      InviteTeamMemberTarget(teamId: teamId, userId: userId),
    );

    if (response.code == 0) {
      return;
    }

    throw response.message ?? '发送团队邀请失败';
  }

  /// 将原生选择的 CandyTalk 好友直接加入团队，不创建待接受通知。
  Future<AddTeamMemberResult> addCandyFriend({
    required String teamId,
    required String candyUserUid,
  }) async {
    final response = await Get.find<NetworkService>()
        .fetch<AddTeamMemberResult>(
          InviteTeamMemberTarget(teamId: teamId, candyUserUid: candyUserUid),
          decoder: (data) =>
              AddTeamMemberResult.fromJson(data as Map<String, dynamic>),
        );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '添加团队成员失败';
  }

  /// 由团队创建人领取一次可重试的原生建群操作。
  Future<TeamGroupCommand> startGroup(String teamId) async {
    final response = await Get.find<NetworkService>().fetch<TeamGroupCommand>(
      StartTeamGroupTarget(teamId),
      decoder: (data) =>
          TeamGroupCommand.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) return response.data!;
    throw response.message ?? '领取团队群创建失败';
  }

  /// 将 CandyTalk 群标识绑定到 Worker 当前操作。
  Future<TeamItem> bindGroup({
    required String teamId,
    required String groupId,
    required String operationId,
    required List<String> memberCandyUserUids,
  }) async {
    final response = await Get.find<NetworkService>().fetch<TeamItem>(
      BindTeamGroupTarget(
        teamId: teamId,
        groupId: groupId,
        operationId: operationId,
        memberCandyUserUids: memberCandyUserUids,
      ),
      decoder: (data) => TeamItem.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) return response.data!;
    throw response.message ?? '绑定团队群失败';
  }

  /// 领取当前团队最早的一条待处理成员邀请。
  Future<TeamGroupMemberCommand> nextMemberInvite(String teamId) async {
    final response = await Get.find<NetworkService>()
        .fetch<TeamGroupMemberCommand>(
          NextTeamGroupMemberTarget(teamId),
          decoder: (data) =>
              TeamGroupMemberCommand.fromJson(data as Map<String, dynamic>),
        );
    if (response.code == 0 && response.data != null) return response.data!;
    throw response.message ?? '领取团队成员群邀请失败';
  }

  /// 回写一条成功或失败的 CandyTalk 成员邀请。
  Future<void> finishMemberInvite({
    required TeamGroupMemberCommand command,
    required bool failed,
    String message = '',
  }) async {
    final response = await Get.find<NetworkService>().fetch<void>(
      TeamGroupMemberResultTarget(
        teamId: command.teamId,
        memberId: command.member.id,
        operationId: command.operationId,
        failed: failed,
        message: message,
      ),
    );
    if (response.code != 0) throw response.message ?? '回写团队成员群邀请失败';
  }

  /// 仅在 CandyTalk 明确失败时记录失败状态，供创建人重试。
  Future<TeamItem> failGroup({
    required String teamId,
    required String operationId,
    required String message,
  }) async {
    final response = await Get.find<NetworkService>().fetch<TeamItem>(
      FailTeamGroupTarget(
        teamId: teamId,
        operationId: operationId,
        message: message,
      ),
      decoder: (data) => TeamItem.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) return response.data!;
    throw response.message ?? '记录团队群失败状态失败';
  }

  /// 创建团队并返回包含创建人和首位成员的完整团队信息。
  ///
  /// [name] 是必填团队名称；[description] 是可选说明；[avatarUrl]
  /// 是上传后的图片地址，当前未上传时保持为空。
  Future<TeamItem> createTeam({
    required String name,
    required String description,
    required String avatarUrl,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<TeamItem>(
      CreateTeamTarget(
        name: name,
        description: description,
        avatarUrl: avatarUrl,
      ),
      decoder: (data) => TeamItem.fromJson(data as Map<String, dynamic>),
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '创建团队失败';
  }

  /// 获取当前用户创建或加入的团队列表。
  Future<List<TeamItem>> teams() async {
    final net = Get.find<NetworkService>();

    final response = await net.fetch<List<TeamItem>>(
      TeamsTarget(),
      decoder: (data) {
        if (data is! List) {
          return const [];
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map(TeamItem.fromJson)
            .toList(growable: false);
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取团队列表失败';
  }
}
