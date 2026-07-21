import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/auth/auth.identity.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 找回密码控制器，负责验证码倒计时、表单校验和密码重置请求。
final class ResetPasswordController extends GetxController {
  /// 认证仓库，验证码和密码重置都通过统一网络层提交。
  final AuthRepository repository = AuthRepository();

  /// 注册邮箱输入，邮箱找回模式下用于定位需要重置密码的账号。
  final TextEditingController email = TextEditingController();

  /// 注册本地手机号输入，不包含当前国家选择对应的国际区号。
  final TextEditingController phone = TextEditingController();

  /// 当前找回密码账号类型，默认手机号并可继承登录页模式。
  final Rx<AuthIdentityType> identityType = AuthIdentityType.phone.obs;

  /// 当前手机号国家或地区，优先继承登录页并在缺失时跟随设备地区。
  final Rx<Country> selectedCountry = AuthIdentity.countryForRegion(null).obs;

  /// 短信或邮箱验证码输入，Mock 环境固定使用 123456。
  final TextEditingController code = TextEditingController();

  /// 用户准备启用的新密码。
  final TextEditingController newPassword = TextEditingController();

  /// 新密码确认输入，用于在提交前发现误输入。
  final TextEditingController confirmPassword = TextEditingController();

  /// 新密码是否明文展示，默认隐藏以保护敏感输入。
  final RxBool isNewPasswordVisible = false.obs;

  /// 确认密码是否明文展示，与新密码框独立控制。
  final RxBool isConfirmPasswordVisible = false.obs;

  /// 验证码重新发送剩余秒数，0 表示允许再次发送。
  final RxInt codeRemainingSeconds = 0.obs;

  /// 是否正在请求验证码，用于阻止网络请求期间重复点击。
  final RxBool sendingCode = false.obs;

  /// 是否正在重置密码，用于禁用重复提交并显示加载状态。
  final RxBool submitting = false.obs;

  /// 驱动验证码按钮倒计时的页面级计时器。
  Timer? _codeTimer;

  /// 使用登录页已有账号草稿预填表单，减少用户重复输入。
  @override
  void onInit() {
    super.onInit();
    final draft = AuthIdentityDraft.fromArguments(Get.arguments);
    identityType.value = draft.type;
    email.text = draft.email;
    phone.text = draft.localPhone;
    selectedCountry.value = AuthIdentity.countryForRegion(
      draft.phoneRegionCode,
    );
  }

  /// 切换找回方式并清理验证码状态，防止跨账号复用旧验证码。
  ///
  /// [value] 是用户新选择的手机号或邮箱模式；已输入账号会继续保留。
  void onIdentityTypeChanged(AuthIdentityType value) {
    if (identityType.value == value) {
      return;
    }

    identityType.value = value;
    code.clear();
    _codeTimer?.cancel();
    codeRemainingSeconds.value = 0;
    sendingCode.value = false;
  }

  /// 更新手机号国家或地区，保留本地号码并影响后续标准化结果。
  ///
  /// [country] 来自国家选择器，提交时会携带国际区号和 ISO 码。
  void onCountryChanged(Country country) {
    selectedCountry.value = country;
  }

  /// 校验当前账号并请求验证码，成功后只提示请求已受理。
  Future<void> sendCode() async {
    if (sendingCode.value || codeRemainingSeconds.value > 0) {
      return;
    }

    final identity = _validatedIdentity();
    if (identity == null) {
      return;
    }

    sendingCode.value = true;

    try {
      final accepted = await repository.code(identity);
      if (!accepted) {
        EasyLoading.showError(S.current.registerEmailCodePending);
        return;
      }

      EasyLoading.showToast(S.current.registerCodeSent);
      _startCodeCountdown();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      sendingCode.value = false;
    }
  }

  /// 启动 60 秒验证码重发窗口，并在倒计时结束后恢复按钮。
  void _startCodeCountdown() {
    _codeTimer?.cancel();
    codeRemainingSeconds.value = 60;

    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 下一秒数小于等于零时结束当前计时器生命周期。
      final nextSeconds = codeRemainingSeconds.value - 1;
      if (nextSeconds <= 0) {
        codeRemainingSeconds.value = 0;
        timer.cancel();
        return;
      }

      codeRemainingSeconds.value = nextSeconds;
    });
  }

  /// 校验手机号或邮箱、验证码和两次新密码后提交重置请求。
  Future<void> resetPassword() async {
    // 账号身份和三个敏感字段共同构成一次完整找回密码请求。
    final identity = _validatedIdentity();
    final codeValue = code.text.trim();
    final newPasswordValue = newPassword.text;
    final confirmPasswordValue = confirmPassword.text;

    if (identity == null) {
      return;
    }

    if (codeValue.isEmpty ||
        newPasswordValue.isEmpty ||
        confirmPasswordValue.isEmpty) {
      EasyLoading.showToast(S.current.resetPasswordRequired);
      return;
    }

    if (newPasswordValue.length < 6) {
      EasyLoading.showToast(S.current.profilePasswordTooShort);
      return;
    }

    if (newPasswordValue != confirmPasswordValue) {
      EasyLoading.showToast(S.current.profilePasswordMismatch);
      return;
    }

    if (submitting.value) {
      return;
    }

    submitting.value = true;

    try {
      final result = await repository.resetPassword(
        identity: identity,
        code: codeValue,
        newPassword: newPasswordValue,
      );

      switch (result) {
        case ResetPasswordResult.success:
          EasyLoading.showSuccess(S.current.resetPasswordSuccess);
          Get.back();
        case ResetPasswordResult.invalidCode:
          EasyLoading.showToast(S.current.registerInvalidEmailCode);
        case ResetPasswordResult.accountNotFound:
          EasyLoading.showToast(S.current.resetPasswordAccountNotFound);
      }
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
    }
  }

  /// 根据当前找回方式标准化并校验账号，返回 null 表示已展示错误提示。
  AuthIdentity? _validatedIdentity() {
    if (identityType.value == AuthIdentityType.email) {
      final account = AuthIdentity.normalizeEmail(email.text);
      if (!GetUtils.isEmail(account)) {
        EasyLoading.showToast(S.current.authInvalidEmail);
        return null;
      }

      return AuthIdentity(
        type: AuthIdentityType.email,
        account: account,
        phoneRegionCode: '',
      );
    }

    final country = selectedCountry.value;
    final account = AuthIdentity.normalizePhone(
      phoneCode: country.phoneCode,
      localNumber: phone.text,
    );
    if (!AuthIdentity.isValidPhone(account)) {
      EasyLoading.showToast(S.current.authInvalidPhone);
      return null;
    }

    return AuthIdentity(
      type: AuthIdentityType.phone,
      account: account,
      phoneRegionCode: country.countryCode,
    );
  }

  /// 释放计时器和所有敏感输入，避免页面退出后继续持有资源。
  @override
  void onClose() {
    _codeTimer?.cancel();
    email.dispose();
    phone.dispose();
    code.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
