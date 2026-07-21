import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/features/auth/auth.controller.dart';
import 'package:worker/features/auth/auth.mixin.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

class AuthScreen extends GetView<AuthController> with ScreenMixin, AuthMixin {
  /// 创建登录页面，认证状态和输入生命周期由 [AuthController] 管理。
  const AuthScreen({super.key});

  /// 登录页不显示空导航栏，品牌区直接承担页面顶部识别作用。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return null;
  }

  /// 允许键盘调整页面高度，配合滚动容器保证按钮始终可访问。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 构建随主题变化的轻量渐变背景，不改变应用全局主题配置。
  @override
  Widget? screenBackground(BuildContext context) {
    // 当前配色方案提供页面表面层级，并自动适配深色模式。
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

  /// 构建文字品牌、表单卡片、协议确认及登录和注册操作组成的滚动布局。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                brandHeader(context),
                SizedBox(height: 24.h),
                loginCard(context, controller),
                SizedBox(height: 14.h),
                legalAcceptance(context, controller),
                SizedBox(height: 24.h),
                signInButton(context, controller),
                SizedBox(height: 12.h),
                Center(child: registerEntry(context, controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
