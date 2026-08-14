import 'package:get/get.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/repository/team.repository.dart';

/// 串行协调 Worker 状态机和 CandyTalk 原生建群副作用。
final class TeamGroupCoordinator {
  /// 创建共享编排器并使用当前 GetX 宿主桥。
  TeamGroupCoordinator({TeamRepository? repository, WorkHostBridge? bridge})
    : _repository = repository ?? TeamRepository(),
      _bridge = bridge ?? Get.find<WorkHostBridge>();

  /// Worker 团队仓库。
  final TeamRepository _repository;

  /// CandyTalk 原生能力桥。
  final WorkHostBridge _bridge;

  /// 当前正在处理的团队，阻止同一 Engine 重复领取。
  final Set<String> _inFlightTeamIds = <String>{};

  /// 领取并执行一次首次建群；绑定网络失败时保留 creating，禁止误报原生失败。
  Future<String> ensureCreated(String teamId) async {
    if (teamId.isEmpty || !_inFlightTeamIds.add(teamId)) return '';
    try {
      final command = await _repository.startGroup(teamId);
      if (command.action != 'create' || command.operationId.isEmpty) return '';
      late final TeamGroupCreationResult creation;
      try {
        creation = await _bridge.createTeamGroup(
          title: command.title,
          members: command.members
              .map(
                (member) => {
                  'candyUserUid': member.candyUserUid,
                  'name': member.name,
                },
              )
              .toList(growable: false),
        );
        if (creation.groupId.isEmpty) throw StateError('CandyTalk 未返回群标识');
      } catch (error) {
        await _repository.failGroup(
          teamId: teamId,
          operationId: command.operationId,
          message: error.toString(),
        );
        rethrow;
      }
      await _repository.bindGroup(
        teamId: teamId,
        groupId: creation.groupId,
        operationId: command.operationId,
        memberCandyUserUids: creation.memberCandyUserUids,
      );
      await _drainMemberInvites(teamId);
      return creation.groupId;
    } finally {
      _inFlightTeamIds.remove(teamId);
    }
  }

  /// 串行邀请该团队所有待处理新成员，单个失败时保留后续重试状态。
  Future<void> drainMemberInvites(String teamId) async {
    if (teamId.isEmpty || !_inFlightTeamIds.add(teamId)) return;
    try {
      await _drainMemberInvites(teamId);
    } finally {
      _inFlightTeamIds.remove(teamId);
    }
  }

  /// 在已持有团队互斥标记时持续领取并执行成员邀请。
  Future<void> _drainMemberInvites(String teamId) async {
    while (true) {
      final command = await _repository.nextMemberInvite(teamId);
      if (command.action != 'invite_member' || command.operationId.isEmpty) {
        return;
      }
      try {
        await _bridge.inviteTeamGroupMember(
          groupId: command.groupId,
          candyUserUid: command.member.candyUserUid,
          name: command.member.name,
        );
      } catch (error) {
        await _repository.finishMemberInvite(
          command: command,
          failed: true,
          message: error.toString(),
        );
        rethrow;
      }
      await _repository.finishMemberInvite(command: command, failed: false);
    }
  }
}
