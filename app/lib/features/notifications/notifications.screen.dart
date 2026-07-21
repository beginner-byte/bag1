import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/notification/notification.item.model.dart';
import 'package:worker/features/notifications/notifications.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/empty.data.state.dart';

/// 通知中心页面，集中处理团队邀请和任务完成确认。
class NotificationsScreen extends GetView<NotificationsController>
    with ScreenMixin {
  const NotificationsScreen({super.key});

  /// 让列表从标题栏下方开始，避免首条通知被遮挡。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 使用 [context] 构建带系统返回入口的通知中心标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(title: Text(S.of(context).notificationCenterTitle));
  }

  /// 使用 [context] 构建首次加载、空状态和可下拉刷新的通知列表。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.loading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 140.h),
              children: [
                EmptyDataState(message: S.of(context).notificationEmpty),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              return _notificationCard(
                context,
                controller.notifications[index],
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
          ),
        );
      }),
    );
  }

  /// 使用 [context] 和 [notification] 构建一张带决策按钮或结果标签的通知卡片。
  Widget _notificationCard(
    BuildContext context,
    WorkerNotificationItem notification,
  ) {
    // pending 决定是否展示业务操作，处理完成后卡片只保留结果标签。
    final pending = notification.status == WorkerNotificationStatus.pending;
    // acting 只禁用当前卡片，其他通知仍可独立操作。
    final acting = controller.actingIds.contains(notification.id);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeIcon(notification.type),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _typeTitle(context, notification.type),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _statusChip(context, notification.status),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _message(context, notification),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (notification.taskNote.trim().isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGradientStart,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          S
                              .of(context)
                              .notificationTaskNote(notification.taskNote),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(context, notification.createdAt),
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pending) ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: acting
                      ? null
                      : () => controller.handle(notification, 'reject'),
                  child: Text(S.of(context).notificationReject),
                ),
                SizedBox(width: 10.w),
                FilledButton(
                  onPressed: acting
                      ? null
                      : () => controller.handle(
                          notification,
                          notification.type ==
                                  WorkerNotificationType.teamInvitation
                              ? 'accept'
                              : 'confirm',
                        ),
                  child: acting
                      ? SizedBox.square(
                          dimension: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          notification.type ==
                                  WorkerNotificationType.teamInvitation
                              ? S.of(context).notificationAcceptInvitation
                              : S.of(context).notificationConfirmTask,
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 根据 [type] 构建可快速区分邀请与任务确认的图标底座。
  Widget _typeIcon(WorkerNotificationType type) {
    // invitation 控制两类通知各自的图标与语义颜色。
    final invitation = type == WorkerNotificationType.teamInvitation;
    // color 使用项目主色或任务绿色，保证两类卡片可以快速识别。
    final color = invitation ? AppColors.primary : const Color(0xFF237A65);

    return Container(
      width: 46.r,
      height: 46.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        invitation ? Icons.group_add_outlined : Icons.task_alt_rounded,
        color: color,
        size: 24.r,
      ),
    );
  }

  /// 根据 [type] 返回当前语言的通知类型标题。
  String _typeTitle(BuildContext context, WorkerNotificationType type) {
    return type == WorkerNotificationType.teamInvitation
        ? S.of(context).notificationTeamInvitation
        : S.of(context).notificationTaskCompletion;
  }

  /// 根据 [notification] 的结构化字段生成符合 [context] 当前语言的正文。
  String _message(BuildContext context, WorkerNotificationItem notification) {
    if (notification.type == WorkerNotificationType.teamInvitation) {
      return S
          .of(context)
          .notificationInvitationMessage(
            notification.actor.name,
            notification.teamName,
          );
    }

    return S
        .of(context)
        .notificationTaskMessage(
          notification.actor.name,
          notification.taskTitle,
        );
  }

  /// 使用 [context] 的语言格式化 [createdAt]，避免展示服务端 UTC 字符串。
  String _formatTime(BuildContext context, DateTime createdAt) {
    // locale 使用应用当前语言，而不是设备可能不同的系统默认值。
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).add_Hm().format(createdAt);
  }

  /// 根据 [status] 构建最终处理结果；待处理状态使用强调色提醒用户操作。
  Widget _statusChip(BuildContext context, WorkerNotificationStatus status) {
    // pending 使用橙色强调仍需操作，最终状态统一降级为次级文字色。
    final pending = status == WorkerNotificationStatus.pending;
    // color 同时应用到文字与浅色背景，保持状态胶囊对比度。
    final color = pending ? const Color(0xFFF2A044) : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        _statusText(context, status),
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 将 [status] 映射为当前 [context] 对应的本地化状态文案。
  String _statusText(BuildContext context, WorkerNotificationStatus status) {
    return switch (status) {
      WorkerNotificationStatus.pending => S.of(context).notificationPending,
      WorkerNotificationStatus.accepted => S.of(context).notificationAccepted,
      WorkerNotificationStatus.rejected => S.of(context).notificationRejected,
      WorkerNotificationStatus.confirmed => S.of(context).notificationConfirmed,
      WorkerNotificationStatus.unknown => S.of(context).notificationProcessed,
    };
  }
}
