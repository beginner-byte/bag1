import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/task/task.item.model.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 任务详情只读页面，展示列表任务快照中的完整信息。
class TaskDetailScreen extends StatelessWidget with ScreenMixin {
  const TaskDetailScreen({super.key});

  /// 详情页使用标准 AppBar 导航层级，不延伸到系统栏下方。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).taskDetailTitle),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 按任务概览、描述、时间和负责人顺序构建可滚动详情内容。
  @override
  Widget body(BuildContext context) {
    final arguments = Get.arguments;

    if (arguments is! TaskItem) {
      return _invalidArguments(context);
    }

    final task = arguments;
    final timeRange = _parseTimeRange(task.time);

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 32.h),
            children: [
              _overviewCard(context, task),
              SizedBox(height: 14.h),
              _sectionCard(
                title: S.of(context).teamDetailTaskDescription,
                icon: Icons.subject_rounded,
                child: Text(
                  task.description.trim().isEmpty
                      ? S.of(context).teamDetailNoTaskDescription
                      : task.description.trim(),
                  style: TextStyle(
                    color: task.description.trim().isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 14.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              _sectionCard(
                title: S.of(context).teamDetailTaskTime,
                icon: Icons.schedule_rounded,
                child: Column(
                  children: [
                    if (timeRange.startTime != null) ...[
                      _informationRow(
                        icon: Icons.play_circle_outline_rounded,
                        label: S.of(context).taskDetailStartTime,
                        value: timeRange.startTime!,
                      ),
                      Divider(height: 1.h, color: AppColors.divider),
                    ],
                    _informationRow(
                      icon: Icons.stop_circle_outlined,
                      label: S.of(context).taskDetailEndTime,
                      value: timeRange.endTime.isEmpty
                          ? '--'
                          : timeRange.endTime,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              _sectionCard(
                title:
                    '${S.of(context).teamDetailAssignees} (${task.assignees.length})',
                icon: Icons.group_outlined,
                child: task.assignees.isEmpty
                    ? Text(
                        S.of(context).taskDetailNoAssignees,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: task.assignees
                            .map(_assigneeChip)
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建任务标题、状态和所属团队的首要信息卡片。
  Widget _overviewCard(BuildContext context, TaskItem task) {
    final statusColors = _statusColors(task);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusColors.background,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  task.statusLabel.isEmpty ? '--' : task.statusLabel,
                  style: TextStyle(
                    color: statusColors.foreground,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (task.teamName.isNotEmpty) ...[
                Icon(
                  Icons.groups_2_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    task.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            task.title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21.sp,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带图标标题的详情分区，保持页面信息层级一致。
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.r, color: AppColors.primary),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  /// 构建开始或结束时间展示行。
  Widget _informationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: AppColors.textSecondary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个负责人头像和姓名标签，多人时允许自动换行。
  Widget _assigneeChip(TeamMemberSummary member) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 5.h, 11.w, 5.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _memberAvatar(member),
          SizedBox(width: 7.w),
          Text(
            member.name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建负责人头像，网络图片失败时回退为姓名首字。
  Widget _memberAvatar(TeamMemberSummary member) {
    final name = member.name.trim();
    final fallback = name.isEmpty ? '' : name.substring(0, 1);

    return Container(
      width: 28.r,
      height: 28.r,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.14),
      ),
      child: AvatarImage(
        source: member.avatarUrl,
        fallback: _avatarFallback(fallback),
      ),
    );
  }

  /// 构建头像加载失败时的文字占位。
  Widget _avatarFallback(String value) {
    return Text(
      value,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// 解析兼容时间字段：包含分隔符时展示开始和结束，否则只展示结束。
  _TaskTimeRange _parseTimeRange(String value) {
    final normalized = value.trim();
    const separator = ' ~ ';
    final separatorIndex = normalized.indexOf(separator);

    if (separatorIndex <= 0) {
      return _TaskTimeRange(endTime: normalized);
    }

    return _TaskTimeRange(
      startTime: normalized.substring(0, separatorIndex).trim(),
      endTime: normalized.substring(separatorIndex + separator.length).trim(),
    );
  }

  /// 根据任务完成状态和状态文案选择与现有任务卡片一致的颜色。
  _TaskStatusColors _statusColors(TaskItem task) {
    if (task.isCompleted) {
      return _TaskStatusColors(
        foreground: const Color(0xFF19734A),
        background: AppColors.success.withValues(alpha: 0.2),
      );
    }

    if (task.statusLabel == S.current.dashboardStatusInProgress) {
      return _TaskStatusColors(
        foreground: const Color(0xFF237A65),
        background: const Color(0xFF237A65).withValues(alpha: 0.12),
      );
    }

    return _TaskStatusColors(
      foreground: AppColors.primary,
      background: AppColors.primary.withValues(alpha: 0.12),
    );
  }

  /// 详情卡片统一使用扁平表面、圆角和轻边框。
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
    );
  }

  /// 路由参数异常时展示安全空状态，避免错误强转导致页面崩溃。
  Widget _invalidArguments(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(
            S.of(context).taskDetailInvalid,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 从兼容字符串解析出的只读任务时间区间。
class _TaskTimeRange {
  const _TaskTimeRange({this.startTime, required this.endTime});

  final String? startTime;
  final String endTime;
}

/// 任务状态标签的前景色和背景色。
class _TaskStatusColors {
  const _TaskStatusColors({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}
