import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 个人页的纯 UI 组件集合，不依赖 Screen、GetX 或业务控制器。
mixin ProfileMixin {
  /// 构建横向身份信息和可复制用户 ID 组成的个人资料卡。
  ///
  /// [userId] 是团队和项目添加成员使用的稳定标识；[onCopyUserId] 负责复制反馈。
  Widget profileCard({
    required String displayName,
    required String account,
    required String userId,
    required String avatarUrl,
    required String avatarInitial,
    required String editLabel,
    required String userIdLabel,
    required String userIdHelp,
    required String copyUserIdLabel,
    required VoidCallback onEditTap,
    required VoidCallback onCopyUserId,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: _cardDecoration(radius: 20.r),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 72.r,
                height: 72.r,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: _avatar(
                        size: 72.r,
                        avatarUrl: avatarUrl,
                        avatarInitial: avatarInitial,
                        bordered: true,
                      ),
                    ),
                    Positioned(
                      right: -2.r,
                      bottom: 1.r,
                      child: Container(
                        width: 25.r,
                        height: 25.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF237A65),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          color: AppColors.white,
                          size: 13.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6.r),
                    Text(
                      account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: editLabel,
                onPressed: onEditTap,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  foregroundColor: AppColors.primary,
                ),
                icon: Icon(Icons.edit_outlined, size: 19.r),
              ),
            ],
          ),
          SizedBox(height: 14.r),
          // 用户 ID 属于辅助信息，因此使用紧凑卡片降低视觉权重，同时保留整块点击复制。
          Tooltip(
            message: copyUserIdLabel,
            child: Semantics(
              button: true,
              label: copyUserIdLabel,
              child: Material(
                color: AppColors.primary.withValues(alpha: 0.035),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onCopyUserId,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.r,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userIdLabel,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.r),
                              Text(
                                userId.isEmpty ? '—' : userId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 32.r,
                          height: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            color: AppColors.primary,
                            size: 16.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建一组圆角菜单，并在相邻项之间添加轻量分隔线。
  Widget profileMenuGroup(List<ProfileMenuData> items) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(radius: 20.r),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _menuTile(items[index]),
            if (index < items.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 64.w),
                child: const Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  /// 构建带当前语言标题、图标底板和可选角标的单个菜单。
  Widget _menuTile(ProfileMenuData item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: SizedBox(
          height: 58.r,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.iconBackground,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.destructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (item.badge != null && item.badge! > 0)
                  Container(
                    height: 24.r,
                    constraints: BoxConstraints(minWidth: 24.r),
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF07171),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${item.badge}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (item.trailing != null) ...[
                  SizedBox(width: 8.w),
                  item.trailing!,
                ],
                if (item.showChevron) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFFC2C7D2),
                    size: 20.r,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建大小可配的用户头像，图片不可用时显示姓名首字。
  Widget _avatar({
    required double size,
    required String avatarUrl,
    required String avatarInitial,
    bool bordered = false,
  }) {
    final fallback = Container(
      color: AppColors.primary.withValues(alpha: 0.13),
      alignment: Alignment.center,
      child: Text(
        avatarInitial,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: (size * 0.34).sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: bordered ? EdgeInsets.all(4.r) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: bordered
            ? Border.all(color: const Color(0xFF5B8FF9), width: 3)
            : null,
      ),
      child: ClipOval(
        child: AvatarImage(source: avatarUrl, fallback: fallback),
      ),
    );
  }

  /// 构建底部版本信息，与 pubspec 中的 1.0.0+1 保持一致。
  Widget profileVersion() {
    return Center(
      child: Text(
        'CO HERE V1.0.0 BUILD 1',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// 返回个人页卡片共用的白色表面、圆角和轻阴影。
  BoxDecoration _cardDecoration({required double radius}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.035),
          blurRadius: 14.r,
          offset: Offset(0, 5.r),
        ),
      ],
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.55)),
    );
  }
}

/// 个人页菜单展示配置，避免每个入口重复组装布局。
class ProfileMenuData {
  /// 创建菜单配置，颜色只用于当前页面的视觉层级。
  const ProfileMenuData({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.onTap,
    this.badge,
    this.trailing,
    this.destructive = false,
    this.showChevron = true,
  });

  /// 菜单图标。
  final IconData icon;

  /// 菜单图标颜色。
  final Color iconColor;

  /// 菜单图标底板颜色。
  final Color iconBackground;

  /// 菜单主标题。
  final String title;

  /// 菜单点击回调。
  final VoidCallback onTap;

  /// 可选数量角标，响应式更新由 Screen 负责。
  final int? badge;

  /// 可选右侧状态组件，用于展示当前设置值或轻量加载反馈。
  final Widget? trailing;

  /// 是否使用危险操作的红色文字。
  final bool destructive;

  /// 是否显示右侧导航箭头。
  final bool showChevron;
}
