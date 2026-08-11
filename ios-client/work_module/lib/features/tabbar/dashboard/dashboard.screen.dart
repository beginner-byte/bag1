import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.controller.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.minxin.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.task.preview.dart';
import 'package:work_module/shared/mixins/screen.mixin.dart';

class DashboardScreen extends GetView<DashboardController>
    with ScreenMixin, DashboardMinxin {
  const DashboardScreen({super.key});

  /// 工作模块根标题栏；右上角消息入口打开 ios-client 原生会话列表。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final bridge = Get.find<WorkHostBridge>();

    return AppBar(
      title: Text(isChinese ? '工作' : 'Work'),
      centerTitle: false,
      titleSpacing: 18.w,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: bridge.messageUnreadCount,
          builder: (context, unreadCount, child) {
            return IconButton(
              onPressed: bridge.openMessages,
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  /// 使用 [context] 构建 Dashboard 页面主体，并返回支持首次骨架和静默刷新的滚动结构。
  @override
  Widget body(BuildContext context) {
    return Obx(() {
      return Skeletonizer(
        enabled: controller.initialLoading,
        child: SafeArea(
          bottom: false,
          child: EasyRefresh.builder(
            isNested: true,
            onRefresh: controller.refreshDashboard,
            header: ClassicHeader(position: IndicatorPosition.locator),
            childBuilder: (context, physics) {
              return NestedScrollView(
                // 与刷新控制器共享外层滚动位置，支持程序化触发下拉刷新。
                physics: physics,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // 顶部 Dashboard
                    SliverSafeArea(
                      bottom: false,
                      minimum: EdgeInsets.symmetric(horizontal: 18.w),
                      sliver: dashboard(context),
                    ),

                    // 吸顶区域
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: DashboardTaskHeaderDelegate(
                        height: 64.h,
                        // 吸顶后使用页面顶部渐变色，避免任务内容从标题区域透出。
                        backgroundColor: AppColors.backgroundGradientStart,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: taskHeader(context),
                        ),
                      ),
                    ),
                    // locator 模式要求定位器位于首个 Sliver，供程序化刷新定位指示器。
                    const HeaderLocator.sliver(clearExtent: false),
                  ];
                },
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: taskSection(context, physics: physics),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  /// 查看全部任务事件出口，Screen 统一转交给控制器。
  @override
  void onViewAllTasksPressed() {
    controller.onViewAllTasks();
  }

  /// 任务卡片事件出口，先使用苹果照片风格放大预览，再处理用户选择的动作。
  @override
  Future<void> onTaskPressed(BuildContext context, TaskItem task) async {
    final result = await Navigator.of(context).push<DashboardTaskResult>(
      PageRouteBuilder<DashboardTaskResult>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) {
          return DashboardTaskPreview(task: task);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
            child: child,
          );
        },
      ),
    );

    if (result == null) {
      return;
    }

    switch (result.action) {
      case DashboardTaskAction.viewDetails:
        controller.onOpenTask(task);
      case DashboardTaskAction.complete:
        await controller.onCompleteTask(task, note: result.note);
      case DashboardTaskAction.postpone:
        await controller.onPostponeTask(task, note: result.note);
    }
  }

  /// 统计卡片事件出口，将对应筛选条件转交给控制器。
  @override
  void onTaskFilterPressed(TaskFilter filter) {
    controller.onOpenTasks(filter);
  }
}
