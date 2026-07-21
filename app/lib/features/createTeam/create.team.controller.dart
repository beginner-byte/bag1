import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/core/repository/team.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

class CreateTeamController extends GetxController {
  /// 团队仓库，负责提交创建请求并解析完整团队数据。
  final TeamRepository repository = TeamRepository();

  /// 团队名称输入控制器，用于收集创建团队的必填标识。
  final name = TextEditingController();

  /// 团队描述输入控制器，用于收集团队用途说明。
  final description = TextEditingController();

  /// 团队名称错误文案，空字符串表示当前没有错误。
  final RxString nameError = ''.obs;

  /// 是否允许提交，基于团队名称是否填写来驱动按钮状态。
  final RxBool canSubmit = false.obs;

  /// 是否正在创建团队，用于阻止重复提交并驱动按钮加载状态。
  final RxBool submitting = false.obs;

  /// 初始化输入监听，让按钮状态和错误态跟随名称输入实时变化。
  @override
  void onInit() {
    super.onInit();
    name.addListener(_syncNameState);
  }

  /// 同步团队名称相关状态，用户输入后及时移除旧错误。
  void _syncNameState() {
    final hasName = name.text.trim().isNotEmpty;
    canSubmit.value = hasName && !submitting.value;

    if (hasName && nameError.value.isNotEmpty) {
      nameError.value = '';
    }
  }

  /// 校验并提交创建团队表单，成功后将完整团队模型返回来源页面。
  Future<void> onCreateTeam() async {
    final nameText = name.text.trim();

    /// 团队名称是页面唯一必填字段，缺失时停留在当前页提示用户补充。
    if (nameText.isEmpty) {
      nameError.value = S.current.teamCreateNameRequired;
      return;
    }

    if (submitting.value) {
      return;
    }

    submitting.value = true;
    _syncNameState();
    TeamItem? createdTeam;

    try {
      createdTeam = await repository.createTeam(
        name: nameText,
        description: description.text.trim(),
        // 图片上传尚未接入，不能把本地文件路径误当成服务端可访问地址。
        avatarUrl: '',
      );
      // Profile 是 hasTeam 的权威来源，创建成功后立即刷新避免资料页继续使用旧缓存。
      await Get.find<AuthService>().reloadUser();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
      _syncNameState();
    }

    if (createdTeam == null) {
      return;
    }

    EasyLoading.showSuccess(S.current.teamCreateSuccess);
    Get.back(result: createdTeam);
  }

  /// 释放输入控制器，避免页面销毁后仍持有文本输入资源。
  @override
  void onClose() {
    name.removeListener(_syncNameState);
    name.dispose();
    description.dispose();
    super.onClose();
  }
}
