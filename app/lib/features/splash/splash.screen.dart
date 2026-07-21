import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/features/splash/splash.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

class SplashScreen extends GetView<SplashController> with ScreenMixin {
  const SplashScreen({super.key});

  /// 启动页与原生启动屏共用的顶部近白色。
  static const Color _backgroundTop = Color(0xFFF8FAFE);

  /// 启动页底部极浅蓝色，用于建立轻微纵向层次。
  static const Color _backgroundBottom = Color(0xFFF1F5FF);

  /// 新 Logo 的蓝色节点色，用于启动页的主强调。
  static const Color _brandBlue = Color(0xFF5264F5);

  /// 新 Logo 的薄荷绿节点色，用于背景辅助形状。
  static const Color _brandMint = Color(0xFF35D0AE);

  /// 品牌标题的深色，在浅色启动背景上保持足够对比度。
  static const Color _brandText = Color(0xFF16213E);

  /// 构建与新 Logo 同色的浅色渐变和低透明度成员节点。
  @override
  Widget? screenBackground(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_backgroundTop, _backgroundBottom],
              ),
            ),
          ),
        ),
        Positioned(
          top: -92.r,
          right: -78.r,
          child: _decorativeNode(
            size: 252.r,
            color: _brandMint.withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: 96.r,
          left: -76.r,
          child: _decorativeNode(
            size: 208.r,
            color: _brandBlue.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  /// 构建居中的新 Logo、本地化品牌文案和初始化加载反馈。
  @override
  Widget body(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 30.h),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'images/logo.png',
                width: 112.r,
                height: 112.r,
                fit: BoxFit.contain,
                semanticLabel: S.of(context).appName,
              ),
              SizedBox(height: 22.h),
              Text(
                S.of(context).appName,
                style: TextStyle(
                  color: _brandText,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                S.of(context).description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _brandText.withValues(alpha: 0.58),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(
                  color: _brandBlue,
                  strokeWidth: 2.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建只承担品牌氛围的圆形节点，不参与页面交互。
  ///
  /// [size] 是节点在当前屏幕适配后的边长；[color] 已包含当前层级所需的透明度。
  Widget _decorativeNode({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
