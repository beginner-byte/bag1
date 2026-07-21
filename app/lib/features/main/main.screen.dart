import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_bar/liquid_glass_bar.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/features/tabbar/dashboard/dashboard.screen.dart';
import 'package:worker/features/main/main.controller.dart';
import 'package:worker/features/tabbar/profile/profile.screen.dart';
import 'package:worker/features/tabbar/teams/teams.screen.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

class MainScreen extends GetView<MainController> with ScreenMixin {
  MainScreen({super.key});

  final screens = [DashboardScreen(), TeamsScreen(), ProfileScreen()];

  /// 让页面内容延伸到底部导航后方，保证玻璃底栏可以透出后方内容。
  @override
  bool extendBody() {
    return true;
  }

  /// 构建临时彩色内容背景，用来验证玻璃底栏的亮度、折射和模糊效果。
  @override
  Widget body(BuildContext context) {
    return Obx(() {
      return IndexedStack(index: controller.index.value, children: screens);
    });
  }

  /// 构建 glass_bottom_navigation 官方结构的底部导航。
  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return Obx(() {
      return LiquidGlassBar(
        items: [
          LiquidGlassBarItem(
            iconData: Icons.home_outlined,
            label: S.of(context).mainTabHome,
          ),
          LiquidGlassBarItem(
            iconData: Icons.folder_outlined,
            label: S.of(context).mainTabTeams,
          ),
          LiquidGlassBarItem(
            iconData: Icons.person_outline_rounded,
            label: S.of(context).mainTabProfile,
          ),
        ],
        currentIndex: controller.index.value,
        onTap: controller.onTabChanged,
        style: const LiquidGlassBarStyle(
          // 使用项目主色承载选中状态，保持 Worker 品牌一致。
          activeColor: AppColors.primary,
          inactiveColor: AppColors.textSecondary,
          // 单独压低图标尺寸，避免底部栏显得笨重。
          iconSize: 20,
          selectedIconScale: 1.08,
          height: 54,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 28),
        ),
      );
    });
  }
}
