import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/features/register/register.controller.dart';
import 'package:worker/features/register/register.mixin.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

class RegisterScreen extends GetView<RegisterController>
    with ScreenMixin, RegisterMixin {
  /// 创建注册页面，账号类型和表单状态由 [RegisterController] 管理。
  const RegisterScreen({super.key});

  /// 使用标准二级页布局，避免返回按钮覆盖注册页标题。
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

  /// 注册表单字段较多，允许键盘顶起页面以避免遮挡底部操作。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 构建随主题变化的轻量渐变背景，不修改其他页面或全局主题。
  @override
  Widget? screenBackground(BuildContext context) {
    // 当前配色方案提供注册页背景层级，并自动适配深色模式。
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

  /// 构建注册页主体，使用滚动布局兼容小屏和键盘输入场景。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                registerHeader(context),
                SizedBox(height: 32.h),
                registerCard(context, controller),
                SizedBox(height: 28.h),
                Center(child: loginEntry(context, controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
