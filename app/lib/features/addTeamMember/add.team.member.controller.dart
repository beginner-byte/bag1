import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/core/repository/team.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 邀请成员页面控制器，负责用户搜索、成员状态判断和提交邀请请求。
class AddTeamMemberController extends GetxController {
  /// 创建添加成员页面状态；[team] 为空表示路由参数无效。
  AddTeamMemberController({required this.team});

  /// 当前操作对应的团队，包含进入页面时的成员快照。
  final TeamItem? team;

  /// 团队仓库，提供用户搜索和团队邀请能力。
  final TeamRepository repository = TeamRepository();

  /// 当前登录用户服务，用于限制创建者专属操作。
  final AuthService authService = Get.find<AuthService>();

  /// 用户 ID、邮箱或完整国际手机号输入控制器，生命周期跟随独立页面。
  final query = TextEditingController();

  /// 当前搜索结果，null 表示尚无可展示用户。
  final Rxn<TeamMemberSummary> result = Rxn<TeamMemberSummary>();

  /// 是否已经完成一次有效搜索，用于区分引导态和无结果态。
  final RxBool hasSearched = false.obs;

  /// 是否正在搜索用户。
  final RxBool searching = false.obs;

  /// 是否正在提交团队邀请请求。
  final RxBool inviting = false.obs;

  /// 输入校验文案，空字符串表示没有输入错误。
  final RxString inputError = ''.obs;

  /// 当前用户是否为团队创建者。
  bool get isCreator {
    final currentTeam = team;
    final userId = authService.user?.id ?? '';

    return currentTeam != null &&
        userId.isNotEmpty &&
        currentTeam.creator.id == userId;
  }

  /// 搜索结果是否已经存在于团队成员快照中。
  bool get isAlreadyMember {
    final member = result.value;
    final currentTeam = team;

    if (member == null || currentTeam == null) {
      return false;
    }

    return currentTeam.members.any((item) => item.id == member.id);
  }

  /// 输入变化后清除旧结果，避免把上一位用户误认为当前搜索内容。
  void onQueryChanged(String value) {
    inputError.value = '';
    hasSearched.value = false;
    result.value = null;
  }

  /// 按用户 ID、注册邮箱或完整国际手机号搜索，并驱动页面结果状态。
  Future<void> search() async {
    final normalizedKeyword = query.text.trim();

    if (!isCreator || searching.value || inviting.value) {
      return;
    }

    if (normalizedKeyword.isEmpty) {
      inputError.value = S.current.teamDetailMemberUserIdRequired;
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    inputError.value = '';
    searching.value = true;
    hasSearched.value = false;
    result.value = null;

    try {
      final member = await repository.searchMember(normalizedKeyword);

      // 输入已变化时丢弃旧请求结果，防止异步返回覆盖新的搜索内容。
      if (query.text.trim() != normalizedKeyword) {
        return;
      }

      result.value = member;
      hasSearched.value = true;
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      searching.value = false;
    }
  }

  /// 向当前搜索结果发送团队邀请，成功后返回上一页但不提前追加成员。
  Future<void> inviteMember() async {
    final currentTeam = team;
    final member = result.value;

    if (!isCreator ||
        currentTeam == null ||
        member == null ||
        isAlreadyMember ||
        inviting.value) {
      return;
    }

    inviting.value = true;

    try {
      await repository.inviteMember(teamId: currentTeam.id, userId: member.id);
      EasyLoading.showSuccess(S.current.teamDetailMemberAdded);
      Get.back();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      inviting.value = false;
    }
  }

  /// 页面路由销毁后释放输入资源。
  @override
  void onClose() {
    query.dispose();
    super.onClose();
  }
}
