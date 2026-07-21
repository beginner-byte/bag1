import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:worker/features/tabbar/profile/profile.controller.dart';
import 'package:worker/features/tabbar/profile/profile.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

/// “我的”Tab 页面，只负责页面配置和将事件转交给控制器。
class ProfileScreen extends GetView<ProfileController>
    with ScreenMixin, ProfileMixin {
  const ProfileScreen({super.key});

  /// 让页面背景延伸到透明 AppBar 后方，形成连续背景。
  @override
  bool extendBodyBehindAppBar() {
    return true;
  }

  /// 构建当前语言的页面标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).mainTabProfile),
      centerTitle: false,
      titleSpacing: 16.w,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 在 Screen 中组合个人资料、菜单分组和版本信息。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(() {
        return EasyRefresh(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: kToolbarHeight + 50.h,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.r),
                    Skeletonizer(
                      enabled: controller.loading.value,
                      child: profileCard(
                        displayName: controller.displayName,
                        account: controller.account,
                        userId: controller.userId,
                        avatarUrl: controller.avatarUrl,
                        avatarInitial: controller.avatarInitial,
                        editLabel: S.of(context).profileEditTitle,
                        userIdLabel: S.of(context).profileUserId,
                        userIdHelp: S.of(context).profileUserIdHelp,
                        copyUserIdLabel: S.of(context).profileCopyUserId,
                        onEditTap: controller.onOpenEditProfile,
                        onCopyUserId: controller.copyUserId,
                      ),
                    ),
                    SizedBox(height: 20.r),
                    _settingsMenu(context),
                    SizedBox(height: 16.r),
                    _aboutMenu(context),
                    SizedBox(height: 24.r),
                    profileVersion(),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 组合账号安全与应用设置入口，具体配置由对应二级页面承载。
  Widget _settingsMenu(BuildContext context) {
    return profileMenuGroup([
      ProfileMenuData(
        icon: Icons.admin_panel_settings_outlined,
        iconColor: const Color(0xFF2E67C7),
        iconBackground: const Color(0xFFEDF3FF),
        title: S.of(context).profileAccountSecurity,
        onTap: controller.onOpenAccountSecurity,
      ),
      ProfileMenuData(
        icon: Icons.tune_rounded,
        iconColor: const Color(0xFF237A65),
        iconBackground: const Color(0xFFE8F7F2),
        title: S.of(context).profileAppSettings,
        onTap: controller.onOpenAppSettings,
      ),
    ]);
  }

  /// 组合独立的关于我们入口，避免与账号和应用设置混在同一层级。
  Widget _aboutMenu(BuildContext context) {
    return profileMenuGroup([
      ProfileMenuData(
        icon: Icons.info_outline_rounded,
        iconColor: const Color(0xFF747983),
        iconBackground: const Color(0xFFF1F2F5),
        title: S.of(context).profileAbout,
        onTap: controller.onOpenAbout,
      ),
    ]);
  }
}
