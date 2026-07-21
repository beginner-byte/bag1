import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:worker/features/tabbar/task/task.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/empty.data.state.dart';
import 'package:worker/shared/widgets/task.cell.dart';

/// 通用任务列表二级页，由路由筛选参数决定展示内容。
class TaskScreen extends GetView<TaskController> with ScreenMixin {
  const TaskScreen({super.key});

  /// 二级页内容从 AppBar 下方开始，避免首条任务被标题栏遮挡。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建带返回入口的页面标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(title: Text(controller.title));
  }

  /// 使用 [context] 获取本地化文案，构建支持下拉刷新、加载态和空态的任务列表。
  ///
  /// 返回值在筛选结果为空时展示统一插图，其余状态保留原有骨架和任务卡片。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final initialLoading =
            controller.loading.value && controller.tasks.isEmpty;

        if (!initialLoading && controller.tasks.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadTasks,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 140.h),
                EmptyDataState(message: S.of(context).taskEmpty),
              ],
            ),
          );
        }

        return Skeletonizer(
          enabled: initialLoading,
          child: RefreshIndicator(
            onRefresh: controller.loadTasks,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 32.h),
              itemCount: initialLoading ? 4 : controller.tasks.length,
              itemBuilder: (context, index) {
                if (initialLoading) {
                  return TaskCell.skeleton();
                }

                final task = controller.tasks[index];

                return TaskCell(
                  task: task,
                  onTap: () => controller.onTaskPressed(task),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
            ),
          ),
        );
      }),
    );
  }
}
