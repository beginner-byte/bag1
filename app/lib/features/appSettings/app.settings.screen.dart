import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/settings/notification.preferences.model.dart';
import 'package:worker/core/service/settings.service.dart';
import 'package:worker/features/appSettings/app.settings.controller.dart';
import 'package:worker/features/tabbar/profile/profile.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

/// 应用设置二级页，使用与账号与安全一致的卡片菜单承载四类设置。
class AppSettingsScreen extends GetView<AppSettingsController>
    with ScreenMixin, ProfileMixin {
  const AppSettingsScreen({super.key});

  /// 设置页内容从 AppBar 下方开始，保持与账号与安全页面一致。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建与账号与安全页面相同背景色的标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).profileAppSettings),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 构建三项常规设置卡片和独立缓存操作卡片。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      top: false,
      child: Obx(() {
        final preferences = controller.notificationPreferences.value;

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.r, 16.w, 32.r),
          children: [
            profileMenuGroup([
              ProfileMenuData(
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xFF2E67C7),
                iconBackground: const Color(0xFFEDF3FF),
                title: S.of(context).appSettingsNotificationSection,
                trailing: controller.notificationLoading.value
                    ? _loadingValue()
                    : _menuValue(
                        preferences.enabled
                            ? S.of(context).appSettingsStatusOn
                            : S.of(context).appSettingsStatusOff,
                      ),
                onTap: () {
                  if (!controller.notificationLoading.value) {
                    _showNotificationSettings(context);
                  }
                },
              ),
              ProfileMenuData(
                icon: Icons.translate_rounded,
                iconColor: const Color(0xFF237A65),
                iconBackground: const Color(0xFFE8F7F2),
                title: S.of(context).appSettingsLanguageSection,
                trailing: _menuValue(
                  _languageLabel(context, controller.language),
                ),
                onTap: () => _showLanguageSettings(context),
              ),
              ProfileMenuData(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF7A5AC8),
                iconBackground: const Color(0xFFF2EDFF),
                title: S.of(context).appSettingsThemeSection,
                trailing: _menuValue(_themeLabel(context, controller.theme)),
                onTap: () => _showThemeSettings(context),
              ),
            ]),
            SizedBox(height: 24.r),
            profileMenuGroup([
              ProfileMenuData(
                icon: Icons.cleaning_services_outlined,
                iconColor: const Color(0xFFF2A044),
                iconBackground: const Color(0xFFFFF4E8),
                title: S.of(context).appSettingsClearCache,
                trailing:
                    controller.cacheLoading.value ||
                        controller.cacheClearing.value
                    ? _loadingValue()
                    : _menuValue(controller.cacheSizeLabel),
                onTap: () {
                  if (!controller.cacheLoading.value &&
                      !controller.cacheClearing.value) {
                    _confirmClearCache(context);
                  }
                },
              ),
            ]),
          ],
        );
      }),
    );
  }

  /// 打开通知设置弹层，主开关关闭时禁用三个细分通知选项。
  Future<void> _showNotificationSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Obx(() {
              final preferences = controller.notificationPreferences.value;
              final canUpdate = !controller.notificationSaving.value;
              final childEnabled = preferences.enabled && canUpdate;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader(
                    icon: Icons.notifications_none_rounded,
                    iconColor: const Color(0xFF2E67C7),
                    iconBackground: const Color(0xFFEDF3FF),
                    title: S.of(sheetContext).appSettingsNotificationSection,
                  ),
                  SizedBox(height: 16.r),
                  _notificationSwitch(
                    title: S.of(sheetContext).appSettingsNotificationsEnabled,
                    subtitle: S
                        .of(sheetContext)
                        .appSettingsNotificationsEnabledDescription,
                    value: preferences.enabled,
                    onChanged: canUpdate
                        ? (value) => _updateNotifications(
                            preferences.copyWith(enabled: value),
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  _notificationSwitch(
                    title: S.of(sheetContext).appSettingsTaskAssigned,
                    value: preferences.taskAssigned,
                    onChanged: childEnabled
                        ? (value) => _updateNotifications(
                            preferences.copyWith(taskAssigned: value),
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  _notificationSwitch(
                    title: S.of(sheetContext).appSettingsDueReminder,
                    value: preferences.dueReminder,
                    onChanged: childEnabled
                        ? (value) => _updateNotifications(
                            preferences.copyWith(dueReminder: value),
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  _notificationSwitch(
                    title: S.of(sheetContext).appSettingsCollaborationMessages,
                    value: preferences.collaborationMessages,
                    onChanged: childEnabled
                        ? (value) => _updateNotifications(
                            preferences.copyWith(collaborationMessages: value),
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// 打开语言选择弹层，选中后立即应用并关闭弹层。
  Future<void> _showLanguageSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Obx(() {
              final language = controller.language;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader(
                    icon: Icons.translate_rounded,
                    iconColor: const Color(0xFF237A65),
                    iconBackground: const Color(0xFFE8F7F2),
                    title: S.of(sheetContext).appSettingsLanguageSection,
                  ),
                  SizedBox(height: 12.r),
                  _choiceTile(
                    title: S.of(sheetContext).appSettingsFollowSystem,
                    selected: language == AppLanguage.system,
                    onTap: () async {
                      await controller.selectLanguage(AppLanguage.system);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  _choiceTile(
                    title: S.of(sheetContext).appSettingsSimplifiedChinese,
                    selected: language == AppLanguage.simplifiedChinese,
                    onTap: () async {
                      await controller.selectLanguage(
                        AppLanguage.simplifiedChinese,
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  _choiceTile(
                    title: 'English',
                    selected: language == AppLanguage.english,
                    onTap: () async {
                      await controller.selectLanguage(AppLanguage.english);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// 打开主题选择弹层，选中后立即应用并关闭弹层。
  Future<void> _showThemeSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Obx(() {
              final theme = controller.theme;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF7A5AC8),
                    iconBackground: const Color(0xFFF2EDFF),
                    title: S.of(sheetContext).appSettingsThemeSection,
                  ),
                  SizedBox(height: 12.r),
                  _choiceTile(
                    title: S.of(sheetContext).appSettingsThemeSystem,
                    selected: theme == AppThemePreference.system,
                    onTap: () async {
                      await controller.selectTheme(AppThemePreference.system);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  _choiceTile(
                    title: S.of(sheetContext).appSettingsThemeLight,
                    selected: theme == AppThemePreference.light,
                    onTap: () async {
                      await controller.selectTheme(AppThemePreference.light);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  _choiceTile(
                    title: S.of(sheetContext).appSettingsThemeDark,
                    selected: theme == AppThemePreference.dark,
                    onTap: () async {
                      await controller.selectTheme(AppThemePreference.dark);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// 将通知弹层中的变更交给控制器统一保存和失败回滚。
  void _updateNotifications(NotificationPreferences preferences) {
    controller.updateNotificationPreferences(preferences);
  }

  /// 构建底部弹层标题，图标底板沿用一级菜单的颜色和圆角。
  Widget _sheetHeader({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: iconColor, size: 22.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  /// 构建通知弹层的自适应开关，整行均可点击并具备语义标签。
  Widget _notificationSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      activeTrackColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  /// 构建语言和主题弹层的单选行。
  Widget _choiceTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? AppColors.primary : AppColors.textDisabled,
      ),
      onTap: onTap,
    );
  }

  /// 构建一级菜单右侧的当前值，限制宽度避免长文案挤压标题。
  Widget _menuValue(String value) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 92.w),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建菜单行内的轻量加载反馈，尺寸与右侧当前值保持一致。
  Widget _loadingValue() {
    return SizedBox(
      width: 16.r,
      height: 16.r,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  /// 返回当前语言的本地化显示名称。
  String _languageLabel(BuildContext context, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => S.of(context).appSettingsFollowSystem,
      AppLanguage.simplifiedChinese =>
        S.of(context).appSettingsSimplifiedChinese,
      AppLanguage.english => 'English',
    };
  }

  /// 返回当前主题模式的本地化显示名称。
  String _themeLabel(BuildContext context, AppThemePreference theme) {
    return switch (theme) {
      AppThemePreference.system => S.of(context).appSettingsThemeSystem,
      AppThemePreference.light => S.of(context).appSettingsThemeLight,
      AppThemePreference.dark => S.of(context).appSettingsThemeDark,
    };
  }

  /// 二次确认清理临时缓存，明确说明不会删除账号和个人设置。
  Future<void> _confirmClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(S.of(dialogContext).appSettingsClearCacheConfirmTitle),
          content: Text(
            S.of(dialogContext).appSettingsClearCacheConfirmMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(S.of(dialogContext).profileCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(S.of(dialogContext).appSettingsClearCacheAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await controller.clearCache();
  }
}
