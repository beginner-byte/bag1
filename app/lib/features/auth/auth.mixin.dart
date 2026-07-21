import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/features/auth/auth.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/utils/legal.document.launcher.dart';

mixin AuthMixin {
  /// 构建方形品牌 Logo，保持开放圆环和成员节点的完整留白。
  Widget logo() {
    return SizedBox(
      width: 64.r,
      height: 64.r,
      child: Image.asset('images/logo.png', fit: BoxFit.contain),
    );
  }

  /// 构建页面顶部标题，标识当前认证页面的主要动作。
  Widget pageTitle(BuildContext context) {
    // 当前主题文字色保证标题在浅色和深色背景上都具有足够对比度。
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        S.of(context).authLoginTitle,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 构建居中的 Logo、文字品牌和辅助文案，不重复显示登录标题。
  Widget brandHeader(BuildContext context) {
    // 主题色用于统一文字品牌和辅助说明在明暗模式下的层级。
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo(),
        SizedBox(height: 10.h),
        Text(
          S.of(context).appName,
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          S.of(context).description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  /// 构建只收纳邮箱和密码输入字段的实体登录卡片。
  ///
  /// [context] 提供主题和本地化资源；[controller] 提供登录表单状态与交互。
  Widget loginCard(BuildContext context, AuthController controller) {
    // 当前主题用于根据明暗模式调整卡片阴影强度。
    final theme = Theme.of(context);
    // 当前配色方案统一卡片表面、边框和阴影颜色。
    final colorScheme = theme.colorScheme;
    // 深色模式使用更明显的阴影，确保卡片与背景仍有清楚层级。
    final shadowOpacity = theme.brightness == Brightness.dark ? 0.24 : 0.08;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowOpacity),
            blurRadius: 28.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          emailField(context, controller),
          SizedBox(height: 18.h),
          passwordField(context, controller),
        ],
      ),
    );
  }

  /// 构建邮箱登录输入框，邮箱是登录页唯一支持的账号类型。
  Widget emailField(BuildContext context, AuthController controller) {
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

  /// 构建密码输入框，后续可以接入密码显隐和校验逻辑。
  Widget passwordField(BuildContext context, AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _fieldLabel(context, S.of(context).authPasswordLabel),
            ),
            TextButton(
              onPressed: controller.onForgot,
              style: TextButton.styleFrom(
                // 文案视觉保持轻量，但触控区域仍满足移动端最小点击尺寸。
                minimumSize: Size(44.w, 40.h),
                padding: EdgeInsets.only(left: 8.w),
              ),
              child: Text(
                S.of(context).authForgotPassword,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller.password,
            obscureText: !controller.isEye.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (submittedPassword) {
              // submittedPassword 已由控制器持有，此处只把键盘提交映射到登录动作。
              controller.onLogin();
            },
            decoration: _inputDecoration(
              context: context,
              hintText: S.of(context).authPasswordHint,
              suffixIcon: controller.isEye.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixPressed: controller.isEye.toggle,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建协议勾选和两个服务器文档链接，未同意时显示就地校验说明。
  Widget legalAcceptance(BuildContext context, AuthController controller) {
    return Obx(() {
      // colorScheme 统一协议链接、说明文字和错误状态的主题颜色。
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

  /// 构建一个紧凑但保留最小触控高度的法律文档链接按钮。
  ///
  /// [label] 是当前语言的协议名称；[onPressed] 负责打开服务器链接。
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

  /// 构建登录按钮，仅在用户已同意两份法律文档后允许提交。
  Widget signInButton(BuildContext context, AuthController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: controller.legalDocumentsAccepted.value
              ? controller.onLogin
              : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Text(
            S.of(context).authSignIn,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  /// 构建注册入口，引导未开户用户进入注册流程。
  Widget registerEntry(BuildContext context, AuthController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).authNoAccount,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        TextButton(
          onPressed: controller.onRegister,
          style: TextButton.styleFrom(
            // 注册入口视觉更轻，但仍保留足够点击高度。
            minimumSize: Size(44.w, 44.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          child: Text(
            S.of(context).authRegister,
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

  /// 构建输入项标题，统一账号和密码标签的字重与颜色。
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

  /// 构建认证输入框装饰，统一边框、图标和提示文字样式。
  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
  }) {
    // 当前主题色统一输入框表面、描边和聚焦反馈，避免深色模式出现白色硬块。
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon == null
          ? null
          : IconButton(
              // 密码显隐属于输入框内部行为，保持点击区域和后缀图标约束一致。
              onPressed: onSuffixPressed,
              icon: Icon(suffixIcon, size: 20.r),
            ),
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

  /// 构建认证输入框边框，保持输入区域与设计稿的圆角视觉一致。
  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
