import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/auth/auth.identity.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/utils/legal.document.launcher.dart';

class RegisterController extends GetxController {
  final repository = AuthRepository();

  /// 注册邮箱输入控制器，是创建新账号的唯一身份凭证。
  final email = TextEditingController();

  /// 注册密码输入控制器，用于收集新账号的登录凭证。
  final password = TextEditingController();

  /// 邮箱验证码输入控制器，生产环境由 Resend 发送随机六位验证码。
  final code = TextEditingController();

  /// 确认密码输入控制器，用于在本地提前发现误输入。
  final confirmPassword = TextEditingController();

  /// 密码是否明文展示，默认隐藏以保护用户输入。
  final RxBool isPasswordVisible = false.obs;

  /// 确认密码是否明文展示，和密码框分开控制避免误触影响两个字段。
  final RxBool isConfirmPasswordVisible = false.obs;

  /// 验证码重新发送倒计时秒数，0 表示当前可以发送。
  final RxInt codeRemainingSeconds = 0.obs;

  /// 是否正在请求短信或邮箱验证码，用于防止接口响应前重复点击。
  final RxBool sendingCode = false.obs;

  /// 是否正在提交注册请求，用于阻止网络响应前的重复注册。
  final RxBool submitting = false.obs;

  /// 用户是否已主动同意用户协议和隐私政策；每次进入注册页默认未同意。
  final RxBool legalDocumentsAccepted = false.obs;

  /// 未同意协议时显示注册页就地校验文案，勾选后立即清除。
  final RxBool legalAcceptanceErrorVisible = false.obs;

  /// 验证码倒计时器，用于在页面存活期间驱动按钮禁用态。
  Timer? _codeTimer;

  /// 从登录页恢复邮箱草稿，密码和验证码始终保持为空。
  @override
  void onInit() {
    super.onInit();
    // draft 保留登录页已输入的邮箱；手机号草稿不再进入注册页。
    final draft = AuthIdentityDraft.fromArguments(Get.arguments);
    email.text = draft.email;
  }

  /// 更新协议同意状态；[value] 为空时按未同意处理，避免三态值绕过注册校验。
  void onLegalAcceptanceChanged(bool? value) {
    legalDocumentsAccepted.value = value ?? false;
    if (legalDocumentsAccepted.value) {
      legalAcceptanceErrorVisible.value = false;
    }
  }

  /// 使用系统浏览器打开 [type] 对应的服务器法律文档。
  Future<void> onOpenLegalDocument(LegalDocumentType type) async {
    await LegalDocumentLauncher.open(type);
  }

  /// 发送邮箱验证码，成功后只提示请求已受理并开始倒计时。
  Future<void> onSendCode() async {
    /// 倒计时期间忽略重复发送，避免用户连续触发验证码请求。
    if (codeRemainingSeconds.value > 0 || sendingCode.value) {
      return;
    }

    final identity = _validatedIdentity();
    if (identity == null) {
      return;
    }

    sendingCode.value = true;

    try {
      // accepted 表示当前后端（真实 Twilio 或 Mock）已经接受验证码发送请求。
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

  /// 启动邮箱验证码倒计时，统一使用 60 秒重发窗口。
  void _startCodeCountdown() {
    _codeTimer?.cancel();
    codeRemainingSeconds.value = 60;

    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextSeconds = codeRemainingSeconds.value - 1;

      /// 倒计时结束后重置按钮状态并释放当前计时器。
      if (nextSeconds <= 0) {
        codeRemainingSeconds.value = 0;
        timer.cancel();
        return;
      }

      codeRemainingSeconds.value = nextSeconds;
    });
  }

  /// 提交邮箱注册表单，先校验协议同意和表单内容再请求认证接口。
  Future<void> onRegister() async {
    if (submitting.value) {
      return;
    }

    if (!legalDocumentsAccepted.value) {
      legalAcceptanceErrorVisible.value = true;
      EasyLoading.showToast(S.current.authLegalAcceptanceRequired);
      return;
    }

    final identity = _validatedIdentity();
    final codeText = code.text.trim();
    final passwordText = password.text;
    final confirmPasswordText = confirmPassword.text;

    if (identity == null) {
      return;
    }

    /// 验证码为空时直接中断，确保注册前已完成账号归属校验。
    if (codeText.isEmpty) {
      EasyLoading.showToast(S.current.registerEmptyEmailCode);
      return;
    }

    /// 注册与重置密码共享至少 6 位规则，避免同一凭证在不同入口标准不一致。
    if (passwordText.length < 6) {
      EasyLoading.showToast(S.current.profilePasswordTooShort);
      return;
    }

    /// 确认密码为空时单独提示，帮助用户定位当前遗漏的字段。
    if (confirmPasswordText.isEmpty) {
      EasyLoading.showToast(S.current.registerEmptyConfirmPassword);
      return;
    }

    /// 两次密码不一致时停止提交，避免用户创建不可预期的登录凭证。
    if (passwordText != confirmPasswordText) {
      EasyLoading.showToast(S.current.registerPasswordMismatch);
      return;
    }

    submitting.value = true;

    try {
      final result = await repository.register(
        identity: identity,
        password: passwordText,
        code: codeText,
      );

      /// 注册结果集中在这里映射文案，避免服务层依赖界面提示。
      switch (result.result) {
        case AuthResult.success:
          EasyLoading.showToast(S.current.registerSuccess);
          // 注册接口已经创建当前设备会话，直接保存并进入初始化路由。
          final auth = Get.find<AuthService>();
          await auth.saveSession(result.token);
          return;
        case AuthResult.invalidCode:
          EasyLoading.showToast(S.current.registerInvalidEmailCode);
          return;
        case AuthResult.accountAlreadyRegistered:
          EasyLoading.showToast(S.current.registerAccountAlreadyRegistered);
          return;
        case AuthResult.accountNotFound:
        case AuthResult.invalidPassword:
          EasyLoading.showToast(S.current.registerPending);
          return;
      }
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
    }
  }

  /// 标准化并校验注册邮箱，返回 null 表示已展示错误提示。
  AuthIdentity? _validatedIdentity() {
    // account is the normalized lowercase email sent to both code and registration APIs.
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

  /// 返回登录页，注册入口来自登录页时保持导航回退语义。
  void onLogin() {
    Get.back();
  }

  /// 释放输入控制器，避免注册页销毁后仍持有文本输入资源。
  @override
  void onClose() {
    _codeTimer?.cancel();
    email.dispose();
    code.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
