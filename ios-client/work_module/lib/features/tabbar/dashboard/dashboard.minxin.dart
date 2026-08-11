import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.controller.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.task.preview.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/widgets/empty.data.state.dart';
import 'package:work_module/shared/widgets/task.cell.dart';

/// Dashboard 页面组件集合，保持 Screen 只负责页面骨架和事件出口。
mixin DashboardMinxin on GetView<DashboardController> {
  /// 查看全部任务事件，由 Screen 暴露并转交给控制器处理。
  void onViewAllTasksPressed();

  /// 任务卡片点击事件，由 Screen 暴露并转交给控制器处理。
  void onTaskPressed(BuildContext context, TaskItem task);

  /// 统计卡片点击事件，三种任务范围共用一个二级页。
  void onTaskFilterPressed(TaskFilter filter);

  /// 构建四宫格统计区，让任务状态可以被快速扫描。
  Widget dashboard(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.46,
      ),
      delegate: SliverChildListDelegate([
        Obx(() {
          return menuCard(
            icon: Icons.assignment_outlined,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primary.withValues(alpha: 0.12),
            value: controller.myTaskCount.value,
            title: S.of(context).dashboardMyTasks,
            onTap: () => onTaskFilterPressed(TaskFilter.all),
          );
        }),
        Obx(() {
          return menuCard(
            icon: Icons.event_busy_outlined,
            iconColor: const Color(0xFFF16F6A),
            iconBackground: const Color(0xFFF16F6A).withValues(alpha: 0.12),
            value: controller.dueTodayCount.value,
            title: S.of(context).dashboardDueToday,
            onTap: () => onTaskFilterPressed(TaskFilter.dueToday),
          );
        }),
        Obx(() {
          return menuCard(
            icon: Icons.more_horiz_rounded,
            iconColor: const Color(0xFF237A65),
            iconBackground: const Color(0xFF237A65).withValues(alpha: 0.12),
            value: controller.inProgressCount.value,
            title: S.of(context).dashboardInProgress,
            onTap: () => onTaskFilterPressed(TaskFilter.inProgress),
          );
        }),
        Obx(() {
          return menuCard(
            icon: Icons.notifications_none_rounded,
            iconColor: const Color(0xFFF5A24E),
            iconBackground: const Color(0xFFF5A24E).withValues(alpha: 0.13),
            value: controller.unreadCount.value,
            title: S.of(context).dashboardUnread,
            onTap: controller.onOpenNotifications,
          );
        }),
      ]),
    );
  }

  Widget taskHeader(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 44.h,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).dashboardTodayTasks,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),

            Obx(() {
              if (controller.tasks.isEmpty) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: onViewAllTasksPressed,
                style: TextButton.styleFrom(
                  minimumSize: Size(44.w, 44.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                child: Text(
                  '${S.of(context).dashboardViewAll} ›',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  /// 构建今日待办区域。
  ///
  /// [context] 用于读取当前语言的空状态文案；[physics] 与首页外层刷新容器
  /// 共享滚动物理效果。返回值会根据请求状态展示骨架、空数据插图或任务列表。
  Widget taskSection(BuildContext context, {required ScrollPhysics physics}) {
    return Obx(() {
      final initialLoading =
          controller.loading.value && controller.tasks.isEmpty;

      if (!initialLoading && controller.tasks.isEmpty) {
        return ListView(
          physics: physics,
          children: [
            SizedBox(height: 36.h),
            EmptyDataState(message: S.of(context).taskEmpty),
          ],
        );
      }

      return ListView.separated(
        physics: physics,
        itemCount: initialLoading ? 3 : controller.tasks.length,
        itemBuilder: (context, index) {
          if (initialLoading) {
            return TaskCell.skeleton();
          }

          final task = controller.tasks[index];

          return Hero(
            tag: dashboardTaskHeroTag(task),
            child: TaskCell(
              task: task,
              onTap: () => onTaskPressed(context, task),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(height: 12.h, color: Colors.transparent);
        },
      );
    });
  }

  /// 构建单个统计卡，统一图标、数字和文案层级。
  Widget menuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required int value,
    required String title,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -8.w,
                top: -8.h,
                child: Icon(
                  icon,
                  color: iconColor.withValues(alpha: 0.055),
                  size: 58.r,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.r),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$value',
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 今日待办吸顶 Header 代理，负责把普通 Widget 转成可吸顶的 Sliver Header。
class DashboardTaskHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// 构建固定高度的吸顶 Header，child 是实际展示的标题内容。
  const DashboardTaskHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  /// Header 内部实际展示的标题和操作入口。
  final Widget child;

  /// Header 固定高度，用于保持滚动吸顶过程稳定。
  final double height;

  /// Header 背景色，用于吸顶时遮住下方滚动内容。
  final Color backgroundColor;

  /// Header 收起后的最小高度，仅保留 1px 收缩空间以识别吸顶状态。
  @override
  double get minExtent => height - 1;

  /// Header 展开时的最大高度，比最小高度多 1px，用于可靠识别吸顶状态。
  @override
  double get maxExtent => height;

  /// 构建吸顶 Header 内容，使用背景色隔离下方滚动列表。
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AnimatedContainer(
      // 固定高度 Header 的 overlapsContent 不稳定，使用 1px 收缩量识别吸顶状态。
      duration: const Duration(milliseconds: 160),
      // 透明态保留背景色的 RGB，避免与透明黑插值时出现闪黑。
      color: shrinkOffset > 0
          ? backgroundColor
          : backgroundColor.withValues(alpha: 0),
      child: Align(alignment: Alignment.center, child: child),
    );
  }

  /// 判断 Header 配置变化时是否需要重建，保证高度和背景更新可以生效。
  @override
  bool shouldRebuild(covariant DashboardTaskHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        height != oldDelegate.height ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
