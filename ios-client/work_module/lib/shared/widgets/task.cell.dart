import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 通用任务卡片，统一展示任务、团队、状态和截止时间。
class TaskCell extends StatelessWidget {
  /// 创建任务卡片。
  ///
  /// [task] 提供卡片展示数据，[onTap] 处理整张卡片的点击事件。
  const TaskCell({required this.task, required this.onTap, super.key});

  /// 创建与真实任务卡片同尺寸的骨架占位内容。
  factory TaskCell.skeleton({Key? key}) {
    return TaskCell(
      key: key,
      task: const TaskItem(
        id: 'skeleton-task',
        teamId: 'skeleton-team',
        teamName: '代码开发团队',
        title: '这是一条任务标题占位内容',
        time: '2026-07-11 18:00',
        statusLabel: '进行中',
      ),
      onTap: _emptyCallback,
    );
  }

  /// 当前需要展示的任务数据。
  final TaskItem task;

  /// 用户点击卡片时执行的回调。
  final VoidCallback onTap;

  /// 骨架占位卡片的空回调，实际交互会由 Skeletonizer 禁用。
  static void _emptyCallback() {}

  /// 构建统一的两行任务卡片。
  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(_toneOf(task));

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: SizedBox(
            height: 52.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_titleRow(colors), _teamRow()],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建第一行的任务标题和右对齐状态。
  Widget _titleRow(_TaskCellColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 126.w,
          child: Align(
            alignment: Alignment.centerRight,
            child: _statusChip(colors),
          ),
        ),
      ],
    );
  }

  /// 构建第二行的团队名称和右对齐截止时间。
  Widget _teamRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: task.teamName.isEmpty
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    Icon(
                      Icons.groups_2_outlined,
                      size: 14.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        task.teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 126.w,
          child: Text(
            task.time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建任务状态标签，颜色由当前状态色调统一提供。
  Widget _statusChip(_TaskCellColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        task.statusLabel,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// 根据任务状态文案选择展示色调，不将 UI 颜色写入接口模型。
  _TaskCellTone _toneOf(TaskItem task) {
    if (task.isCompleted) {
      return _TaskCellTone.completed;
    }

    if (task.statusLabel == S.current.dashboardPriorityHigh) {
      return _TaskCellTone.priority;
    }

    if (task.statusLabel == S.current.dashboardStatusInProgress) {
      return _TaskCellTone.active;
    }

    return _TaskCellTone.urgent;
  }

  /// 将任务状态色调转换为标签的前景色和背景色。
  _TaskCellColors _statusColors(_TaskCellTone tone) {
    switch (tone) {
      case _TaskCellTone.priority:
        return _TaskCellColors(
          foreground: AppColors.primary,
          background: AppColors.primary.withValues(alpha: 0.12),
        );
      case _TaskCellTone.active:
        return _TaskCellColors(
          foreground: const Color(0xFF237A65),
          background: const Color(0xFF237A65).withValues(alpha: 0.12),
        );
      case _TaskCellTone.urgent:
        return _TaskCellColors(
          foreground: const Color(0xFFFF746F),
          background: const Color(0xFFFF746F).withValues(alpha: 0.11),
        );
      case _TaskCellTone.completed:
        return _TaskCellColors(
          foreground: const Color(0xFF19734A),
          background: AppColors.success.withValues(alpha: 0.2),
        );
    }
  }
}

/// 任务状态的 UI 色调，仅用于任务卡片展示。
enum _TaskCellTone { priority, active, urgent, completed }

/// 任务状态标签的颜色组合。
class _TaskCellColors {
  /// 创建状态颜色组合，[foreground] 用于文字，[background] 用于背景。
  const _TaskCellColors({required this.foreground, required this.background});

  /// 状态标签的文字颜色。
  final Color foreground;

  /// 状态标签的浅色背景。
  final Color background;
}
