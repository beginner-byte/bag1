import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/model/auth/login.device.model.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 账号与安全控制器，负责账号展示、密码修改和本地会话操作。
class AccountSecurityController extends GetxController {
  /// 认证服务，用于安全清理当前用户的本地登录状态。
  final AuthService authService = Get.find<AuthService>();

  /// 认证仓库，复用统一网络层提交修改密码请求。
  final AuthRepository authRepository = AuthRepository();

  /// 当前密码输入框，用于在修改前验证账号所有权。
  final TextEditingController currentPassword = TextEditingController();

  /// 新密码输入框，用于收集用户准备启用的登录凭证。
  final TextEditingController newPassword = TextEditingController();

  /// 确认密码输入框，用于提前发现新密码误输入。
  final TextEditingController confirmPassword = TextEditingController();

  /// 当前密码是否明文展示，默认隐藏以保护敏感输入。
  final RxBool currentPasswordVisible = false.obs;

  /// 新密码是否明文展示。
  final RxBool newPasswordVisible = false.obs;

  /// 确认密码是否明文展示。
  final RxBool confirmPasswordVisible = false.obs;

  /// 是否正在提交修改密码请求，用于阻止重复操作。
  final RxBool submitting = false.obs;

  /// 服务端返回的有效登录设备列表，当前设备由 JWT 会话标记。
  final RxList<LoginDevice> loginDevices = <LoginDevice>[].obs;

  /// 是否正在首次加载或刷新登录设备列表。
  final RxBool loadingLoginDevices = false.obs;

  /// 登录设备加载错误；空字符串表示当前没有错误。
  final RxString loginDevicesError = ''.obs;

  /// 正在执行远程退出的会话 ID 集合，用于阻止重复点击。
  final RxSet<String> revokingDeviceIds = <String>{}.obs;

  /// 服务端返回的预约删除时间；为空表示账号没有待执行删除请求。
  final Rxn<DateTime> deletionScheduledAt = Rxn<DateTime>();

  /// 是否正在首次加载或刷新账号删除状态。
  final RxBool loadingDeletionStatus = false.obs;

  /// 账号删除状态加载错误；空字符串表示当前没有错误。
  final RxString deletionStatusError = ''.obs;

  /// 是否正在提交 15 天后删除或撤销预约请求。
  final RxBool updatingDeletionSchedule = false.obs;

  /// 是否正在执行不可撤销的立即删除请求。
  final RxBool deletingAccount = false.obs;

  /// 控制器初始化时读取服务端预约状态，确保重新登录后仍可撤销。
  @override
  void onInit() {
    super.onInit();
    unawaited(loadDeletionStatus());
  }

  /// 当前登录主要账号，资料未加载完成时安全回退为空字符串。
  String get account => authService.user?.primaryAccount ?? '';

  /// 当前账号是否为手机号，用于账号信息弹层选择本地化标签。
  bool get isPhoneAccount => authService.user?.isPhoneAccount ?? false;

  /// 当前账号昵称，昵称为空时回退为主要账号。
  String get displayName {
    final name = authService.user?.displayName.trim() ?? '';

    if (name.isNotEmpty) {
      return name;
    }

    return isPhoneAccount ? account : account.split('@').first;
  }

  /// 当前账号是否已经加入团队，供账号信息弹层展示状态。
  bool get hasTeam => authService.user?.hasTeam ?? false;

  /// 当前 JWT 对应的设备会话；列表尚未加载或异常时返回 null。
  LoginDevice? get currentLoginDevice {
    for (final device in loginDevices) {
      if (device.current) {
        return device;
      }
    }
    return null;
  }

  /// 当前账号是否存在仍可撤销的永久删除预约。
  bool get hasScheduledDeletion => deletionScheduledAt.value != null;

  /// 从服务端刷新账号删除状态并保留错误供页面重试。
  Future<void> loadDeletionStatus() async {
    if (loadingDeletionStatus.value) {
      return;
    }
    loadingDeletionStatus.value = true;
    deletionStatusError.value = '';
    try {
      // status 是服务端唯一可信状态，避免仅依赖本地时间判断删除是否仍有效。
      final status = await authRepository.accountDeletionStatus();
      deletionScheduledAt.value = status.scheduled ? status.scheduledAt : null;
    } catch (error) {
      deletionStatusError.value = error.toString();
    } finally {
      loadingDeletionStatus.value = false;
    }
  }

  /// 预约账号在固定 15 天冷静期结束后永久删除。
  ///
  /// 返回 true 表示服务端已保存准确期限；失败时保留当前账号状态并显示错误。
  Future<bool> scheduleAccountDeletion() async {
    if (updatingDeletionSchedule.value || deletingAccount.value) {
      return false;
    }
    updatingDeletionSchedule.value = true;
    try {
      // status 返回首次预约的期限，重复提交不会延长冷静期。
      final status = await authRepository.scheduleAccountDeletion();
      deletionScheduledAt.value = status.scheduledAt;
      deletionStatusError.value = '';
      return status.scheduled && status.scheduledAt != null;
    } catch (error) {
      EasyLoading.showError(error.toString());
      return false;
    } finally {
      updatingDeletionSchedule.value = false;
    }
  }

  /// 撤销尚未到期的删除预约并恢复普通账号状态。
  ///
  /// 返回 true 表示服务器已清除期限；账号数据和当前登录状态保持不变。
  Future<bool> cancelAccountDeletion() async {
    if (updatingDeletionSchedule.value || deletingAccount.value) {
      return false;
    }
    updatingDeletionSchedule.value = true;
    try {
      await authRepository.cancelAccountDeletion();
      deletionScheduledAt.value = null;
      deletionStatusError.value = '';
      return true;
    } catch (error) {
      EasyLoading.showError(error.toString());
      return false;
    } finally {
      updatingDeletionSchedule.value = false;
    }
  }

  /// 立即永久删除账号、清理本地账号数据并返回登录页。
  ///
  /// 返回 true 表示服务端删除已完成；请求失败时不会清除本地会话。
  Future<bool> deleteAccountNow() async {
    if (deletingAccount.value || updatingDeletionSchedule.value) {
      return false;
    }
    deletingAccount.value = true;
    EasyLoading.show(status: S.current.profileDeleteImmediately);
    try {
      await authRepository.deleteAccountNow();
      await authService.clearDeletedAccountData();
      GetRouter.onAuth();
      return true;
    } catch (error) {
      EasyLoading.showError(error.toString());
      return false;
    } finally {
      EasyLoading.dismiss();
      deletingAccount.value = false;
    }
  }

  /// 切换当前密码可见性，让用户按需核对输入。
  void toggleCurrentPasswordVisibility() {
    currentPasswordVisible.toggle();
  }

  /// 切换新密码可见性。
  void toggleNewPasswordVisibility() {
    newPasswordVisible.toggle();
  }

  /// 切换确认密码可见性。
  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.toggle();
  }

  /// 清理修改密码表单，避免关闭弹窗后残留敏感信息。
  void resetPasswordForm() {
    currentPassword.clear();
    newPassword.clear();
    confirmPassword.clear();
    currentPasswordVisible.value = false;
    newPasswordVisible.value = false;
    confirmPasswordVisible.value = false;
  }

  /// 校验并提交密码修改，成功时由界面关闭弹窗并结束当前会话。
  Future<bool> changePassword() async {
    final currentValue = currentPassword.text;
    final newValue = newPassword.text;
    final confirmValue = confirmPassword.text;

    if (currentValue.isEmpty || newValue.isEmpty || confirmValue.isEmpty) {
      EasyLoading.showToast(S.current.profilePasswordRequired);
      return false;
    }

    if (newValue.length < 6) {
      EasyLoading.showToast(S.current.profilePasswordTooShort);
      return false;
    }

    if (newValue != confirmValue) {
      EasyLoading.showToast(S.current.profilePasswordMismatch);
      return false;
    }

    if (currentValue == newValue) {
      EasyLoading.showToast(S.current.profilePasswordUnchanged);
      return false;
    }

    if (submitting.value) {
      return false;
    }

    submitting.value = true;

    try {
      final result = await authRepository.changePassword(
        currentPassword: currentValue,
        newPassword: newValue,
      );

      if (result == ChangePasswordResult.invalidCurrentPassword) {
        EasyLoading.showToast(S.current.profileCurrentPasswordIncorrect);
        return false;
      }

      return true;
    } catch (error) {
      EasyLoading.showError(error.toString());
      return false;
    } finally {
      submitting.value = false;
    }
  }

  /// 从服务器加载当前账号的有效设备会话，失败信息保留给弹层展示。
  Future<void> loadLoginDevices() async {
    if (loadingLoginDevices.value) {
      return;
    }

    loadingLoginDevices.value = true;
    loginDevicesError.value = '';
    try {
      loginDevices.assignAll(await authRepository.loginDevices());
    } catch (error) {
      loginDevicesError.value = error.toString();
    } finally {
      loadingLoginDevices.value = false;
    }
  }

  /// 撤销非当前设备并从本地列表移除；当前设备会执行完整退出流程。
  ///
  /// [device] 必须来自最近一次设备列表响应。
  Future<void> logoutDevice(LoginDevice device) async {
    if (device.current) {
      await logout();
      return;
    }
    if (revokingDeviceIds.contains(device.id)) {
      return;
    }

    revokingDeviceIds.add(device.id);
    try {
      await authRepository.logoutDevice(device.id);
      loginDevices.removeWhere((item) => item.id == device.id);
      EasyLoading.showSuccess(S.current.profileDeviceLoggedOut);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      revokingDeviceIds.remove(device.id);
    }
  }

  /// 尽量撤销服务端当前会话，再清除安全存储并返回登录页。
  ///
  /// 网络失败不阻止本地退出，避免用户被无效或离线会话困在应用内。
  Future<void> logout() async {
    try {
      if (currentLoginDevice == null) {
        await loadLoginDevices();
      }
      // currentDevice 可能因网络失败为空，此时仍继续清除本地登录态。
      final currentDevice = currentLoginDevice;
      if (currentDevice != null) {
        await authRepository.logoutDevice(currentDevice.id);
      }
    } catch (_) {
      // 远程撤销失败时本地退出仍必须完成，服务器会话最终由过期时间兜底。
    } finally {
      await authService.clearSession();
      GetRouter.onAuth();
    }
  }

  /// 释放密码输入资源，并在页面销毁时清除内存中的敏感内容。
  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
