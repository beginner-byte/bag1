import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/features/onboarding/onboarding.controller.dart';
import 'package:worker/features/onboarding/onboarding.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

class OnboardingScreen extends GetView<OnboardingController>
    with ScreenMixin, OnboardingMixin {
  const OnboardingScreen({super.key});

  /// 构建轻量品牌栏，减少导航干扰的同时保留当前产品归属感。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 88.h,
      leading: Padding(
        padding: EdgeInsets.only(left: 22.w),
        child: Align(
          // AppBar 高度加大后，显式居中可避免品牌文字贴到顶部。
          alignment: Alignment.centerLeft,
          child: Text(
            S.of(context).appName,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 200.w,
    );
  }

  /// 构建团队引导主体，通过收敛文字和卡片密度保持单屏决策效率。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              teamHero(context),
              SizedBox(height: 28.h),
              teamOptions(context, controller),
            ],
          ),
          SizedBox(height: 24.h),
          teamBottomActions(context, controller),
        ],
      ),
    );
  }
}
