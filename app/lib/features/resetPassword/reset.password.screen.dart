import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/auth/auth.identity.dart';
import 'package:worker/features/resetPassword/reset.password.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/auth.identity.switcher.dart';
import 'package:worker/shared/widgets/international.phone.field.dart';

/// 找回密码页面，通过手机号或邮箱验证码完成账号恢复。
final class ResetPasswordScreen extends GetView<ResetPasswordController>
    with ScreenMixin {
  /// 创建无状态找回密码页面，表单生命周期由 GetX 控制器负责。
  const ResetPasswordScreen({super.key});

  /// 使用标准二级页层级，避免表单内容延伸到导航栏下方。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建只保留返回入口的透明导航栏，让正文标题承担页面识别作用。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    );
  }

  /// 允许键盘顶起页面，保证小屏设备仍可访问底部提交按钮。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 构建随主题变化的轻量渐变背景，不影响其他页面的全局主题。
  @override
  Widget? screenBackground(BuildContext context) {
    // 当前配色方案提供找回密码页背景层级，并自动适配深色模式。
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surfaceContainerLowest, colorScheme.surface],
        ),
      ),
    );
  }

  /// 构建可滚动的标题和密码恢复表单。
  @override
  Widget body(BuildContext context) {
    // 当前主题色用于正文标题和说明文字的明暗模式适配。
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).resetPasswordTitle,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  S.of(context).resetPasswordSubtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 32.h),
                _formCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建包含账号验证和新密码输入的连续单列表单。
  Widget _formCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _identityTypeSwitch(context),
        SizedBox(height: 24.h),
        Obx(
          () => controller.identityType.value == AuthIdentityType.phone
              ? InternationalPhoneField(
                  controller: controller.phone,
                  country: controller.selectedCountry.value,
                  onCountryChanged: controller.onCountryChanged,
                  label: S.of(context).authPhoneLabel,
                  hintText: S.of(context).authPhoneHint,
                )
              : _emailField(context),
        ),
        SizedBox(height: 18.h),
        _fieldLabel(context, S.of(context).registerEmailCodeLabel),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.code,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            context: context,
            hintText: S.of(context).registerEmailCodeHint,
            suffix: _codeAction(context),
          ),
        ),
        SizedBox(height: 18.h),
        _fieldLabel(context, S.of(context).profileNewPassword),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller.newPassword,
            obscureText: !controller.isNewPasswordVisible.value,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              context: context,
              hintText: S.of(context).authPasswordHint,
              suffix: _visibilityAction(
                visible: controller.isNewPasswordVisible.value,
                onPressed: controller.isNewPasswordVisible.toggle,
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        _fieldLabel(context, S.of(context).profileConfirmNewPassword),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller.confirmPassword,
            obscureText: !controller.isConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (submittedPassword) {
              // submittedPassword 已由控制器持有，此处只把键盘提交映射到重置动作。
              controller.resetPassword();
            },
            decoration: _inputDecoration(
              context: context,
              hintText: S.of(context).registerConfirmPasswordHint,
              suffix: _visibilityAction(
                visible: controller.isConfirmPasswordVisible.value,
                onPressed: controller.isConfirmPasswordVisible.toggle,
              ),
            ),
          ),
        ),
        SizedBox(height: 28.h),
        _submitButton(context),
      ],
    );
  }

  /// 构建与登录页一致的下划线账号切换器，选中项由控制器统一管理。
  ///
  /// [context] 提供登录方式本地化文案；切换操作只更新当前找回方式。
  Widget _identityTypeSwitch(BuildContext context) {
    return Obx(
      () => AuthIdentitySwitcher(
        selected: controller.identityType.value,
        onChanged: controller.onIdentityTypeChanged,
        phoneLabel: S.of(context).authPhoneLogin,
        emailLabel: S.of(context).authEmailLogin,
        underlined: true,
      ),
    );
  }

  /// 构建邮箱找回输入框，切换到手机号模式时保留当前邮箱草稿。
  Widget _emailField(BuildContext context) {
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

  /// 构建验证码发送按钮，并根据请求和倒计时状态控制可用性。
  Widget _codeAction(BuildContext context) {
    // 当前主题色用于验证码按钮的启用与禁用视觉反馈。
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 96.w,
      child: Obx(() {
        // 剩余秒数和请求状态共同决定按钮文案及点击能力。
        final remainingSeconds = controller.codeRemainingSeconds.value;
        // busy 表示验证码请求正在进行，期间禁止再次触发发送。
        final busy = controller.sendingCode.value;
        // canSend 仅在无请求且倒计时结束后恢复为 true。
        final canSend = remainingSeconds == 0 && !busy;

        return TextButton(
          onPressed: canSend ? controller.sendCode : null,
          style: TextButton.styleFrom(
            minimumSize: Size(72.w, 36.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          child: Text(
            remainingSeconds > 0
                ? '${remainingSeconds}s'
                : S.of(context).registerSendCode,
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

  /// 构建密码显隐按钮，仅改变对应字段的本地展示状态。
  Widget _visibilityAction({
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20.r,
      ),
    );
  }

  /// 构建重置密码主按钮，并在提交期间显示进度反馈。
  Widget _submitButton(BuildContext context) {
    // 当前主题色确保加载指示器在主按钮上保持足够对比度。
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Obx(() {
        // submitting 为 true 时禁用按钮，防止连续写入密码。
        final submitting = controller.submitting.value;

        return ElevatedButton(
          onPressed: submitting ? null : controller.resetPassword,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: submitting
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  S.of(context).resetPasswordAction,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        );
      }),
    );
  }

  /// 构建表单字段标题，统一找回密码页的信息层级。
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

  /// 构建找回密码输入框装饰，保持与登录注册表单一致的触控尺寸。
  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    Widget? suffix,
  }) {
    // 当前主题色统一找回密码输入框的表面、描边和聚焦反馈。
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffix,
      suffixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 52.h),
      filled: true,
      fillColor: colorScheme.surface,
      constraints: BoxConstraints(minHeight: 52.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: _inputBorder(colorScheme.outlineVariant),
      enabledBorder: _inputBorder(colorScheme.outlineVariant),
      focusedBorder: _inputBorder(colorScheme.primary, width: 1.5),
    );
  }

  /// 构建输入框圆角边框，聚焦时仅切换颜色而不改变布局。
  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
