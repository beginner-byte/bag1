import 'package:flutter/material.dart';
import 'package:worker/app/theme/app.color.dart';

mixin ScreenMixin {
  // 编写基础页面的配置

  GlobalKey<ScaffoldState>? scaffoldStateKey() {
    return null;
  }

  Widget? screenBackground(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        // 默认页面背景从顶部的浅灰过渡到底部的近白色，减少纯色背景的生硬感。
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientStart,
            AppColors.backgroundGradientEnd,
          ],
        ),
      ),
    );
  }

  /// 允许 视图到导航下面 默认不允许
  bool extendBodyBehindAppBar() {
    return true;
  }

  bool extendBody() {
    return false;
  }

  /// // 键盘不要影响布局
  bool resizeToAvoidBottomInset() {
    return false;
  }

  Color backgroundColor() {
    return AppColors.white;
  }

  Widget build(BuildContext context) {
    Widget? sb = screenBackground(context);

    return Scaffold(
      key: scaffoldStateKey(),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset(), // 键盘不要影响布局
      extendBodyBehindAppBar: extendBodyBehindAppBar(),
      extendBody: extendBody(),
      appBar: appBar(context),
      drawer: drawer(context),
      backgroundColor: backgroundColor(),
      body: sb == null
          ? body(context)
          : Stack(
              children: [
                Positioned.fill(child: sb),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: body(context),
                ),
              ],
            ),
      bottomNavigationBar: bottomNavigationBar(context),
      floatingActionButton: floatingActionButton(),
      floatingActionButtonLocation: floatingActionButtonLocation(),
    );
  }

  // 构建 AppBar
  PreferredSizeWidget? appBar(BuildContext context) {
    return null;
  }

  // 构建页面主体内容
  Widget body(BuildContext context);

  Widget? drawer(BuildContext context) {
    return null;
  }

  Widget? floatingActionButton() {
    return null;
  }

  FloatingActionButtonLocation? floatingActionButtonLocation() {
    return null;
  }

  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
