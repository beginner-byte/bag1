import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/auth/login.device.model.dart';
import 'package:worker/features/accountSecurity/account.security.controller.dart';
import 'package:worker/features/tabbar/profile/profile.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

/// 账号与安全二级页，将账号管理和退出登录从个人页一级入口中分离。
class AccountSecurityScreen extends GetView<AccountSecurityController>
    with ScreenMixin, ProfileMixin {
  const AccountSecurityScreen({super.key});

  /// 让二级页内容从 AppBar 下方开始，避免菜单被标题栏遮挡。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建带系统返回按钮的账号与安全标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).profileAccountSecurity),
      // 二级页内容不延伸到 AppBar 后方，因此直接使用页面渐变顶部色避免白色导航。
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 组合账号入口和位于页面底部的退出登录操作。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.r, 16.w, 32.r),
        children: [
          _accountMenu(context),
          SizedBox(height: 24.r),
          _logoutMenu(context),
          SizedBox(height: 24.r),
          _accountDeletionSection(context),
        ],
      ),
    );
  }

  /// 构建账号信息、修改密码和登录设备入口，为后续安全功能预留层级。
  Widget _accountMenu(BuildContext context) {
    return profileMenuGroup([
      ProfileMenuData(
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFF2E67C7),
        iconBackground: const Color(0xFFEDF3FF),
        title: S.of(context).profileAccountInfo,
        onTap: () => _showAccountInfo(context),
      ),
      ProfileMenuData(
        icon: Icons.lock_outline_rounded,
        iconColor: const Color(0xFF237A65),
        iconBackground: const Color(0xFFE8F7F2),
        title: S.of(context).profileChangePassword,
        onTap: () => _showChangePassword(context),
      ),
      ProfileMenuData(
        icon: Icons.devices_outlined,
        iconColor: const Color(0xFFF2A044),
        iconBackground: const Color(0xFFFFF4E8),
        title: S.of(context).profileLoginDevices,
        onTap: () => _showLoginDevices(context),
      ),
    ]);
  }

  /// 构建独立的退出登录卡片，避免与普通账号设置产生误触。
  Widget _logoutMenu(BuildContext context) {
    return profileMenuGroup([
      ProfileMenuData(
        icon: Icons.logout_rounded,
        iconColor: AppColors.error,
        iconBackground: const Color(0xFFFFEEEE),
        title: S.of(context).profileLogout,
        destructive: true,
        showChevron: false,
        onTap: () => _confirmLogout(context),
      ),
    ]);
  }

  /// 构建账号删除入口、加载失败重试或已预约状态卡片。
  Widget _accountDeletionSection(BuildContext context) {
    return Obx(() {
      if (controller.loadingDeletionStatus.value &&
          !controller.hasScheduledDeletion) {
        return profileMenuGroup([
          ProfileMenuData(
            icon: Icons.person_remove_outlined,
            iconColor: AppColors.error,
            iconBackground: const Color(0xFFFFEEEE),
            title: S.of(context).profileDeleteAccount,
            trailing: SizedBox.square(
              dimension: 18.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            showChevron: false,
            onTap: () {},
          ),
        ]);
      }

      if (controller.deletionStatusError.value.isNotEmpty &&
          !controller.hasScheduledDeletion) {
        return profileMenuGroup([
          ProfileMenuData(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.error,
            iconBackground: const Color(0xFFFFEEEE),
            title: S.of(context).profileDeletionStatusRetry,
            destructive: true,
            onTap: controller.loadDeletionStatus,
          ),
        ]);
      }

      // scheduledAt 非空时必须持续展示准确期限和两个可用操作。
      final scheduledAt = controller.deletionScheduledAt.value;
      if (scheduledAt != null) {
        return _scheduledDeletionCard(context, scheduledAt);
      }

      return profileMenuGroup([
        ProfileMenuData(
          icon: Icons.person_remove_outlined,
          iconColor: AppColors.error,
          iconBackground: const Color(0xFFFFEEEE),
          title: S.of(context).profileDeleteAccount,
          destructive: true,
          onTap: () => _showDeletionOptions(context),
        ),
      ]);
    });
  }

  /// 构建已预约删除警示卡，提供撤销和立即永久删除操作。
  ///
  /// [scheduledAt] 是服务端 UTC 时间，展示前转换为设备本地时区。
  Widget _scheduledDeletionCard(BuildContext context, DateTime scheduledAt) {
    // localeName 让完整删除日期遵循当前 App 语言和地区格式。
    final localeName = Localizations.localeOf(context).toLanguageTag();
    // scheduledText 向用户展示本地时区下的准确永久删除时间。
    final scheduledText = DateFormat.yMMMMd(
      localeName,
    ).add_Hm().format(scheduledAt.toLocal());
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  S.of(context).profileDeletionScheduledTitle,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.r),
          Text(
            S.of(context).profileDeletionScheduledMessage(scheduledText),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.updatingDeletionSchedule.value
                      ? null
                      : _cancelScheduledDeletion,
                  child: controller.updatingDeletionSchedule.value
                      ? SizedBox.square(
                          dimension: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(S.of(context).profileCancelDeletion),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextButton(
                  onPressed:
                      controller.deletingAccount.value ||
                          controller.updatingDeletionSchedule.value
                      ? null
                      : () => _confirmImmediateDeletion(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(S.of(context).profileDeleteImmediately),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 展示 15 天可撤销删除和立即不可撤销删除两个明确选项。
  Future<void> _showDeletionOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetTitle(
                  icon: Icons.person_remove_outlined,
                  title: S.of(sheetContext).profileDeleteAccount,
                ),
                SizedBox(height: 12.r),
                Text(
                  S.of(sheetContext).profileDeletionChoiceMessage,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20.r),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.updatingDeletionSchedule.value
                          ? null
                          : () async {
                              // scheduled 表示服务端已经固定首次申请后的 15 天期限。
                              final scheduled = await controller
                                  .scheduleAccountDeletion();
                              if (!scheduled || !sheetContext.mounted) {
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                              EasyLoading.showSuccess(
                                S.current.profileDeletionScheduledSuccess,
                              );
                            },
                      icon: controller.updatingDeletionSchedule.value
                          ? SizedBox.square(
                              dimension: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.schedule_rounded),
                      label: Text(
                        S.of(sheetContext).profileDeleteAfterFifteenDays,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  S.of(sheetContext).profileDeleteAfterFifteenDaysDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 18.r),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      unawaited(_confirmImmediateDeletion(context));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.45),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: Text(S.of(sheetContext).profileDeleteImmediately),
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  S.of(sheetContext).profileDeleteImmediatelyDescription,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12.sp,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 撤销当前删除预约，并在成功后保留账号与当前登录状态。
  Future<void> _cancelScheduledDeletion() async {
    // cancelled 表示服务端已清除预约期限，失败反馈由控制器统一显示。
    final cancelled = await controller.cancelAccountDeletion();
    if (cancelled) {
      EasyLoading.showSuccess(S.current.profileDeletionCancelledSuccess);
    }
  }

  /// 二次确认立即删除，明确其不可撤销及团队数据影响。
  Future<void> _confirmImmediateDeletion(BuildContext context) async {
    // confirmed 只有在用户点击红色永久删除按钮时才为 true。
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(
          () => AlertDialog(
            title: Text(S.of(dialogContext).profileDeleteImmediatelyTitle),
            content: Text(
              S.of(dialogContext).profileDeleteImmediatelyConfirmMessage,
            ),
            actions: [
              TextButton(
                onPressed: controller.deletingAccount.value
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: Text(S.of(dialogContext).profileCancel),
              ),
              TextButton(
                onPressed: controller.deletingAccount.value
                    ? null
                    : () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(
                  S.of(dialogContext).profileConfirmPermanentDeletion,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await controller.deleteAccountNow();
  }

  /// 展示当前账号的只读信息，复用认证服务中已经加载的用户资料。
  Future<void> _showAccountInfo(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetTitle(
                  icon: Icons.person_outline_rounded,
                  title: S.of(sheetContext).profileAccountInfo,
                ),
                SizedBox(height: 20.r),
                _detailRow(
                  label: S.of(sheetContext).profileDisplayName,
                  value: controller.displayName,
                ),
                _detailRow(
                  label: controller.isPhoneAccount
                      ? S.of(sheetContext).profilePhone
                      : S.of(sheetContext).profileEmail,
                  value: controller.account,
                ),
                _detailRow(
                  label: S.of(sheetContext).profileTeamStatus,
                  value: controller.hasTeam
                      ? S.of(sheetContext).profileHasTeam
                      : S.of(sheetContext).profileNoTeam,
                ),
                _detailRow(
                  label: S.of(sheetContext).profileAccountStatus,
                  value: S.of(sheetContext).profileAccountActive,
                  showDivider: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 展示修改密码表单，提交成功后结束旧会话并返回登录页。
  Future<void> _showChangePassword(BuildContext context) async {
    controller.resetPasswordForm();

    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(() {
          final submitting = controller.submitting.value;

          return AlertDialog(
            title: Text(S.of(dialogContext).profileChangePassword),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _passwordField(
                      controller: controller.currentPassword,
                      label: S.of(dialogContext).profileCurrentPassword,
                      obscureText: !controller.currentPasswordVisible.value,
                      onToggleVisibility:
                          controller.toggleCurrentPasswordVisibility,
                    ),
                    SizedBox(height: 14.r),
                    _passwordField(
                      controller: controller.newPassword,
                      label: S.of(dialogContext).profileNewPassword,
                      obscureText: !controller.newPasswordVisible.value,
                      onToggleVisibility:
                          controller.toggleNewPasswordVisibility,
                    ),
                    SizedBox(height: 14.r),
                    _passwordField(
                      controller: controller.confirmPassword,
                      label: S.of(dialogContext).profileConfirmNewPassword,
                      obscureText: !controller.confirmPasswordVisible.value,
                      onToggleVisibility:
                          controller.toggleConfirmPasswordVisibility,
                    ),
                    SizedBox(height: 10.r),
                    Text(
                      S.of(dialogContext).profilePasswordRequirement,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () {
                        controller.resetPasswordForm();
                        Navigator.of(dialogContext).pop(false);
                      },
                child: Text(S.of(dialogContext).profileCancel),
              ),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final success = await controller.changePassword();

                        if (!success || !dialogContext.mounted) {
                          return;
                        }

                        Navigator.of(dialogContext).pop(true);
                        EasyLoading.showSuccess(
                          S.current.profilePasswordChanged,
                        );
                        await controller.logout();
                      },
                child: submitting
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(S.of(dialogContext).profileConfirmChangePassword),
              ),
            ],
          );
        });
      },
    );

    // 用户取消或使用系统返回时清除密码；成功后控制器会随退出登录自动销毁。
    if (changed != true) {
      controller.resetPasswordForm();
    }
  }

  /// 展示服务端有效设备会话，并允许撤销当前账号的指定登录设备。
  Future<void> _showLoginDevices(BuildContext context) async {
    // 列表请求与弹层动画并行执行，让加载状态立即可见。
    unawaited(controller.loadLoginDevices());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.r, 20.w, 24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetTitle(
                  icon: Icons.devices_outlined,
                  title: S.of(sheetContext).profileLoginDevices,
                ),
                SizedBox(height: 20.r),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.68,
                  ),
                  child: SingleChildScrollView(
                    child: Obx(
                      () => _loginDevicesContent(context, sheetContext),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 根据设备请求状态构建加载、错误、空列表或真实会话内容。
  Widget _loginDevicesContent(
    BuildContext pageContext,
    BuildContext sheetContext,
  ) {
    if (controller.loadingLoginDevices.value &&
        controller.loginDevices.isEmpty) {
      return SizedBox(
        height: 150.r,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 12.r),
              Text(S.of(sheetContext).profileDeviceLoading),
            ],
          ),
        ),
      );
    }

    if (controller.loginDevicesError.value.isNotEmpty &&
        controller.loginDevices.isEmpty) {
      return _deviceState(
        context: sheetContext,
        icon: Icons.cloud_off_outlined,
        message: S.of(sheetContext).profileDeviceLoadFailed,
        actionLabel: S.of(sheetContext).profileRetry,
        onAction: controller.loadLoginDevices,
      );
    }

    if (controller.loginDevices.isEmpty) {
      return _deviceState(
        context: sheetContext,
        icon: Icons.devices_other_outlined,
        message: S.of(sheetContext).profileDeviceEmpty,
      );
    }

    // deviceCards 保留服务端的最近活跃排序，当前设备通过标签明确标识。
    final deviceCards = controller.loginDevices
        .map((device) => _loginDeviceCard(sheetContext, device))
        .toList(growable: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...deviceCards.expand((card) => [card, SizedBox(height: 10.r)]),
        Text(
          S.of(sheetContext).profileDeviceDescription,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: 20.r),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await _confirmLogout(pageContext);
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(S.of(sheetContext).profileLogoutCurrentDevice),
          ),
        ),
      ],
    );
  }

  /// 构建单条真实设备会话卡片，非当前设备显示独立退出操作。
  Widget _loginDeviceCard(BuildContext context, LoginDevice device) {
    // localeName 让最近活跃时间遵循 App 当前语言格式。
    final localeName = Localizations.localeOf(context).toLanguageTag();
    // lastActiveText 使用本地时区展示服务端 UTC 时间。
    final lastActiveText = DateFormat.yMd(
      localeName,
    ).add_Hm().format(device.lastActiveAt.toLocal());
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _deviceIcon(device.platform),
              color: const Color(0xFFF2A044),
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  '${S.of(context).profileDeviceLastActive}: $lastActiveText',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (device.current)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                S.of(context).profileCurrentDevice,
                style: TextStyle(
                  color: const Color(0xFF237A65),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Obx(() {
              // revoking 只锁定当前这一条设备，其他卡片仍可正常操作。
              final revoking = controller.revokingDeviceIds.contains(device.id);
              return TextButton(
                onPressed: revoking
                    ? null
                    : () => controller.logoutDevice(device),
                child: revoking
                    ? SizedBox.square(
                        dimension: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(S.of(context).profileDeviceLogout),
              );
            }),
        ],
      ),
    );
  }

  /// 构建设备列表的空状态或错误状态，可按需显示重试按钮。
  Widget _deviceState({
    required BuildContext context,
    required IconData icon,
    required String message,
    String? actionLabel,
    Future<void> Function()? onAction,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.r),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 32.r),
            SizedBox(height: 10.r),
            Text(message, style: TextStyle(color: AppColors.textSecondary)),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 8.r),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据服务端平台代码选择设备图标，未知平台回退到通用设备图标。
  IconData _deviceIcon(String platform) {
    return switch (platform.toLowerCase()) {
      'android' || 'ios' || 'fuchsia' => Icons.phone_iphone_rounded,
      'macos' || 'windows' || 'linux' => Icons.computer_rounded,
      'web' => Icons.language_rounded,
      _ => Icons.devices_other_rounded,
    };
  }

  /// 构建底部弹层的标题，统一账号信息和设备页面的视觉层级。
  Widget _sheetTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.r),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  /// 构建账号信息字段行，最后一行可关闭分隔线避免多余边界。
  Widget _detailRow({
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.r),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带显隐按钮的密码输入框，三个密码字段复用相同交互。
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  /// 弹出退出确认对话框，只有用户确认后才清理当前登录态。
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(S.of(context).profileLogoutConfirmTitle),
          content: Text(S.of(context).profileLogoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(S.of(context).profileCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(S.of(context).profileConfirmLogout),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await controller.logout();
  }
}
