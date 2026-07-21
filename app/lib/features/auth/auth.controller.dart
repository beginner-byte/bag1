import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/model/auth/auth.identity.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/utils/legal.document.launcher.dart';

class AuthController extends GetxController {
  final repository = AuthRepository();

  /// 邮箱登录输入，是登录页唯一支持的账号凭证。
  final email = TextEditingController();

  /// 密码
  final password = TextEditingController();

  /// 密码是否展开
  final RxBool isEye = false.obs;

  /// 用户是否已主动勾选同意用户协议和隐私政策；每次进入登录页默认未同意。
  final RxBool legalDocumentsAccepted = false.obs;

  /// 键盘提交在未同意时显示的就地校验状态，勾选后立即清除。
  final RxBool legalAcceptanceErrorVisible = false.obs;

  /// 更新协议同意状态；[value] 为空时按未同意处理，避免三态值绕过校验。
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

  /// 先校验用户已同意法律文档，再校验邮箱登录表单并提交认证请求。
  Future<void> onLogin() async {
    if (!legalDocumentsAccepted.value) {
      legalAcceptanceErrorVisible.value = true;
      EasyLoading.showToast(S.current.authLegalAcceptanceRequired);
      return;
    }

    final passwordText = password.text;
    final identity = _validatedIdentity();

    if (identity == null) {
      return;
    }

    /// 密码为空时直接提示，后续接入接口前先保证基础入参完整。
    if (passwordText.isEmpty) {
      return EasyLoading.showToast(S.current.authEmptyPassword);
    }
    EasyLoading.show();

    try {
      final result = await repository.login(
        identity: identity,
        password: passwordText,
      );

      final auth = Get.find<AuthService>();
      await auth.saveSession(result);

      /// 查看是否有team
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 打开注册页，并传递当前邮箱草稿以减少重复输入。
  void onRegister() {
    Get.toNamed(GetRouter.register, arguments: _identityDraft().toArguments());
  }

  /// 打开找回密码页，并传递当前邮箱草稿但不传递密码。
  void onForgot() {
    Get.toNamed(
      GetRouter.resetPassword,
      arguments: _identityDraft().toArguments(),
    );
  }

  /// 标准化并校验登录邮箱，返回 null 表示已向用户提示格式错误。
  AuthIdentity? _validatedIdentity() {
    // account is the normalized lower-case email sent to the login API.
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

  /// 构建页面跳转使用的非敏感邮箱草稿，不包含密码或 session。
  AuthIdentityDraft _identityDraft() {
    return AuthIdentityDraft(
      type: AuthIdentityType.email,
      email: email.text.trim(),
      localPhone: '',
      phoneRegionCode: '',
    );
  }

  /// 释放输入控制器，避免认证页销毁后仍持有文本输入资源。
  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
