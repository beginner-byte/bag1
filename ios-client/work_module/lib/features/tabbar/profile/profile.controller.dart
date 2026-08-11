import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/model/user.dart';
import 'package:work_module/core/repository/profile.repository.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// “我的”页控制器，展示 CandyTalk 身份并把认证相关操作交回原生宿主。
final class ProfileController extends GetxController {
  /// CandyTalk 与 Worker 之间的宿主通信边界。
  final WorkHostBridge bridge = Get.find<WorkHostBridge>();

  /// Worker 资料仓库，用于加载服务端资料并接收编辑结果。
  final ProfileRepository repository = ProfileRepository();

  /// 当前服务端 Worker 用户资料；加载失败时页面回退宿主身份。
  final Rxn<User> profile = Rxn<User>();

  /// CandyTalk 当前用户的登录账号；宿主未提供时回退到用户 UID。
  String get account {
    final workerAccount = profile.value?.primaryAccount ?? '';
    if (workerAccount.isNotEmpty) {
      return workerAccount;
    }
    final config = bridge.config;
    if (config == null) {
      return '';
    }
    return config.account.isNotEmpty ? config.account : config.userUid;
  }

  /// Worker 为当前 CandyTalk 用户生成的稳定公开 ID。
  String get userId => profile.value?.id ?? bridge.config?.workerUserId ?? '';

  /// CandyTalk 当前用户昵称；为空时回退到登录账号。
  String get displayName {
    final workerName = profile.value?.displayName ?? '';
    if (workerName.isNotEmpty) {
      return workerName;
    }
    final config = bridge.config;
    if (config == null) {
      return '';
    }
    return config.displayName.isNotEmpty ? config.displayName : account;
  }

  /// CandyTalk 当前用户头像地址。
  String get avatarUrl =>
      profile.value?.avatarUrl ?? bridge.config?.avatarUrl ?? '';

  /// 根据展示名生成头像兜底首字。
  String get avatarInitial {
    final normalizedName = displayName.trim();
    return normalizedName.isEmpty
        ? '?'
        : normalizedName.substring(0, 1).toUpperCase();
  }

  /// 宿主身份已经随 bootstrap 到达，不再重复请求 Worker 个人资料。
  final RxBool loading = true.obs;

  /// 页面首次创建时从 Worker 服务加载完整资料。
  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  /// 从 Worker 服务刷新资料；失败时保留最近成功数据或宿主身份兜底。
  Future<void> refreshProfile() async {
    loading.value = true;
    try {
      profile.value = await repository.profile();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      loading.value = false;
    }
  }

  /// 复制 Worker 公共用户 ID，供团队成员精确搜索。
  Future<void> copyUserId() async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      EasyLoading.showToast(S.current.profileUserIdUnavailable);
      return;
    }
    await Clipboard.setData(ClipboardData(text: normalizedUserId));
    EasyLoading.showToast(S.current.profileUserIdCopied);
  }

  /// 打开 Worker 原编辑资料页，并用保存结果立即刷新当前资料卡。
  Future<void> onOpenEditProfile() async {
    var currentProfile = profile.value;
    if (currentProfile == null) {
      await refreshProfile();
      currentProfile = profile.value;
    }
    if (currentProfile == null) {
      return;
    }
    final result = await Get.toNamed(
      GetRouter.editProfile,
      arguments: <String, Object>{'user': currentProfile, 'account': account},
    );
    if (result is User) {
      profile.value = result;
    }
  }

  /// 账号安全后续接 CandyTalk 原生安全页，本阶段不打开 Worker 密码页面。
  void onOpenAccountSecurity() => _showNativeIntegrationPending();

  /// 应用设置后续按 Worker 主体逐项恢复，本阶段避免引用 Worker 独立认证服务。
  void onOpenAppSettings() => _showNativeIntegrationPending();

  /// 关于页面后续从完整 Worker 同步，本阶段保持入口可见。
  void onOpenAbout() => _showNativeIntegrationPending();

  /// 请求 CandyTalk 原生宿主执行完整退出流程并返回原生登录页。
  Future<void> logout() => bridge.logout();

  /// 对尚未接入的原生二级页提供可见反馈，避免无响应。
  void _showNativeIntegrationPending() {
    EasyLoading.showToast(S.current.profileSearchPending);
  }
}
