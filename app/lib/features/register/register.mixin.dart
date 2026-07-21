import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/features/register/register.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/utils/legal.document.launcher.dart';

mixin RegisterMixin on ScreenMixin {
  /// 构建注册页顶部信息，先建立页面目标和品牌信任感。
  Widget registerHeader(BuildContext context) {
    // 当前主题色保证标题和说明在明暗主题下保持正确的信息层级。
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).registerTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 30.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          S.of(context).registerSubtitle,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  /// 构建邮箱注册表单，并在确认密码后要求用户主动同意法律文档。
  Widget registerCard(BuildContext context, RegisterController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        emailField(context, controller),
        SizedBox(height: 18.h),
        codeField(context, controller),
        SizedBox(height: 18.h),
        passwordField(context, controller),
        SizedBox(height: 18.h),
        confirmPasswordField(context, controller),
        SizedBox(height: 18.h),
        legalAcceptance(context, controller),
        SizedBox(height: 20.h),
        registerButton(context, controller),
      ],
    );
  }

  /// 构建邮箱输入框，注册账号以邮箱作为后续登录和找回凭证。
  Widget emailField(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, S.of(context).authEmailLabel),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            context: context,
            hintText: S.of(context).authEmailHint,
          ),
        ),
      ],
    );
  }

  /// 构建邮箱验证码输入框，先验证邮箱归属再允许创建账号。
  Widget codeField(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, S.of(context).registerEmailCodeLabel),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.code,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            context: context,
            hintText: S.of(context).registerEmailCodeHint,
            suffixIconWidget: codeAction(context, controller),
          ),
        ),
      ],
    );
  }

  /// 构建验证码发送按钮，发送后用倒计时禁用重复请求入口。
  Widget codeAction(BuildContext context, RegisterController controller) {
    // 当前主题色用于验证码操作的启用与禁用反馈。
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 96.w,
      child: Obx(() {
        // 剩余秒数决定倒计时文案，并在归零前禁止重复发送。
        final remainingSeconds = controller.codeRemainingSeconds.value;
        // 发送能力同时受倒计时和当前网络请求状态约束。
        final canSend = remainingSeconds == 0 && !controller.sendingCode.value;

        return TextButton(
          onPressed: canSend ? controller.onSendCode : null,
          style: TextButton.styleFrom(
            // 验证码按钮嵌在输入框右侧，固定宽度避免文案和输入内容互相挤压。
            minimumSize: Size(72.w, 36.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          child: Text(
            canSend ? S.of(context).registerSendCode : "${remainingSeconds}s",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: canSend
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }),
    );
  }

  /// 构建密码输入框，提供独立显隐控制以兼顾安全和纠错效率。
  Widget passwordField(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, S.of(context).authPasswordLabel),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller.password,
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              context: context,
              hintText: S.of(context).authPasswordHint,
              suffixIcon: controller.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixPressed: controller.isPasswordVisible.toggle,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建确认密码输入框，本地确认能减少注册后无法登录的风险。
  Widget confirmPasswordField(
    BuildContext context,
    RegisterController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, S.of(context).registerConfirmPasswordLabel),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller.confirmPassword,
            obscureText: !controller.isConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (submittedPassword) {
              // submittedPassword 已由控制器持有，此处只把键盘提交映射到注册动作。
              controller.onRegister();
            },
            decoration: _inputDecoration(
              context: context,
              hintText: S.of(context).registerConfirmPasswordHint,
              suffixIcon: controller.isConfirmPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixPressed: controller.isConfirmPasswordVisible.toggle,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建位于确认密码和创建按钮之间的协议勾选区，文档名称可分别点击查看。
  Widget legalAcceptance(BuildContext context, RegisterController controller) {
    return Obx(() {
      // 当前主题色统一协议说明、链接和错误文案在明暗模式下的显示效果。
      final colorScheme = Theme.of(context).colorScheme;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: controller.legalDocumentsAccepted.value,
                onChanged: controller.onLegalAcceptanceChanged,
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      S.of(context).authLegalAcceptancePrefix,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _legalDocumentButton(
                      context: context,
                      label: '《${S.of(context).profileTerms}》',
                      onPressed: () => controller.onOpenLegalDocument(
                        LegalDocumentType.agreement,
                      ),
                    ),
                    Text(
                      S.of(context).authLegalAcceptanceAnd,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _legalDocumentButton(
                      context: context,
                      label: '《${S.of(context).profilePrivacy}》',
                      onPressed: () => controller.onOpenLegalDocument(
                        LegalDocumentType.privacy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (controller.legalAcceptanceErrorVisible.value)
            Padding(
              padding: EdgeInsets.only(left: 48.w, top: 2.h),
              child: Text(
                S.of(context).authLegalAcceptanceRequired,
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    });
  }

  /// 构建注册页法律文档链接；[label] 是文档名称，[onPressed] 负责打开服务器链接。
  Widget _legalDocumentButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(44.w, 40.h),
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  /// 构建主注册按钮，点击后由控制器先校验协议同意状态再提交表单。
  Widget registerButton(BuildContext context, RegisterController controller) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: controller.onRegister,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          S.of(context).registerCreateAccount,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// 构建返回登录入口，让已有账号用户可以快速回到登录流程。
  Widget loginEntry(BuildContext context, RegisterController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).registerHaveAccount,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        TextButton(
          onPressed: controller.onLogin,
          style: TextButton.styleFrom(
            // 文字按钮视觉轻量，但触控区域仍满足移动端最小点击尺寸。
            minimumSize: Size(44.w, 44.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          child: Text(
            S.of(context).registerBackToLogin,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建输入项标题，统一注册表单中各字段的层级和可读性。
  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 构建注册输入框装饰，统一边框、图标和提示文字样式。
  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    IconData? suffixIcon,
    Widget? suffixIconWidget,
    VoidCallback? onSuffixPressed,
  }) {
    // 当前主题色统一注册输入框的表面、描边和聚焦反馈。
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      suffixIcon:
          suffixIconWidget ??
          (suffixIcon == null
              ? null
              : IconButton(
                  // 后缀按钮只负责字段内部显隐，不改变表单布局尺寸。
                  onPressed: onSuffixPressed,
                  icon: Icon(suffixIcon, size: 20.r),
                )),
      suffixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 52.h),
      filled: true,
      fillColor: colorScheme.surface,
      // 输入框保持 52pt 高度，兼顾可点性和清晰的字段节奏。
      constraints: BoxConstraints(minHeight: 52.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: _inputBorder(colorScheme.outlineVariant),
      enabledBorder: _inputBorder(colorScheme.outlineVariant),
      focusedBorder: _inputBorder(colorScheme.primary, width: 1.5),
    );
  }

  /// 构建注册输入框边框，保持表单控件圆角和登录页一致。
  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
