import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/task/task.item.model.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/features/teamDetail/team.detail.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 团队详情页，集中展示团队资料、完成情况、成员和细分任务。
class TeamDetailScreen extends GetView<TeamDetailController> with ScreenMixin {
  const TeamDetailScreen({super.key});

  /// 详情内容从 AppBar 下方开始，避免首张卡片被标题栏遮挡。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 使用团队名称作为页面标题，并保留系统返回入口。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(controller.team?.name ?? S.of(context).mainTabTeams),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 构建团队信息、成员头像叠加区和细分任务列表。
  @override
  Widget body(BuildContext context) {
    final team = controller.team;

    if (team == null) {
      return _invalidArguments(context);
    }

    return SafeArea(
      top: false,
      child: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.loadTasks,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 36.h),
            children: [
              _overviewCard(context, team),
              SizedBox(height: 24.h),
              _memberSectionHeader(context, team),
              SizedBox(height: 10.h),
              _memberCard(context, team),
              SizedBox(height: 24.h),
              _taskSectionHeader(context, team),
              SizedBox(height: 12.h),
              if (controller.loading.value && controller.tasks.isEmpty)
                _taskLoadingCard()
              else if (controller.tasks.isEmpty)
                _emptyTaskCard(context)
              else
                for (
                  var index = 0;
                  index < controller.tasks.length;
                  index++
                ) ...[
                  _taskCard(context, controller.tasks[index]),
                  if (index < controller.tasks.length - 1)
                    SizedBox(height: 12.h),
                ],
            ],
          ),
        );
      }),
    );
  }

  /// 构建团队资料与完成情况一体化主卡片。
  Widget _overviewCard(BuildContext context, TeamItem team) {
    final progress = controller.completionProgress;
    final percentage = (progress * 100).round();

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _teamAvatar(team),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          team.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (controller.isCreator) _creatorBadge(context),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      S.of(context).teamDetailIntroduction,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            team.description.trim().isEmpty
                ? S.of(context).teamDetailNoIntroduction
                : team.description.trim(),
            style: TextStyle(
              color: team.description.trim().isEmpty
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
              fontSize: 14.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          _overviewMetadata(
            icon: Icons.person_outline_rounded,
            label: S.of(context).teamListCreator,
            value: team.creator.name,
          ),
          SizedBox(height: 10.h),
          _overviewMetadata(
            icon: Icons.date_range_outlined,
            label: S.of(context).teamListPeriod,
            value: _dateRange(context, team),
          ),
          SizedBox(height: 18.h),
          Divider(height: 1.h, color: AppColors.divider),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).teamDetailProgress,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              _progressMetric(
                label: S.of(context).teamDetailAllTasks,
                value: controller.totalTaskCount,
              ),
              _progressMetric(
                label: S.of(context).teamDetailCompleted,
                value: controller.completedTaskCount,
              ),
              _progressMetric(
                label: S.of(context).teamDetailPending,
                value: controller.pendingTaskCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建团队头像，图片不可用时使用统一团队图标。
  Widget _teamAvatar(TeamItem team) {
    return Container(
      width: 58.r,
      height: 58.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: AvatarImage(
        source: team.avatarUrl,
        fallback: Icon(
          Icons.groups_2_outlined,
          color: AppColors.primary,
          size: 30.r,
        ),
      ),
    );
  }

  /// 构建当前用户拥有管理权限时显示的创建者标记。
  Widget _creatorBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        S.of(context).teamDetailCreatorBadge,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// 构建主卡片中的创建人或日期信息。
  Widget _overviewMetadata({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Text(
          '$label：',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建完成情况中的单项统计。
  Widget _progressMetric({required String label, required int value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建团队成员标题和查看全部入口。
  Widget _memberSectionHeader(BuildContext context, TeamItem team) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${S.of(context).teamListMembers} (${controller.members.length})',
            style: _sectionTitleStyle(),
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(
            GetRouter.teamMembers,
            arguments: team.copyWith(
              members: controller.members.toList(growable: false),
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: Size(0, 44.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).teamDetailViewAll),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right_rounded, size: 19.r),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建头像叠加成员卡片，创建者额外显示添加成员入口。
  Widget _memberCard(BuildContext context, TeamItem team) {
    return Container(
      constraints: BoxConstraints(minHeight: 82.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _avatarStack(
                controller.members,
                maximumVisible: 4,
                size: 42,
              ),
            ),
          ),
          if (controller.isCreator) ...[
            SizedBox(width: 12.w),
            IconButton.outlined(
              onPressed: () => _openAddMember(team),
              tooltip: S.of(context).teamDetailAddMember,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surface,
                fixedSize: Size.square(48.r),
                iconSize: 26.r,
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppColors.divider, width: 1.2),
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建细分任务标题和创建者专属操作。
  Widget _taskSectionHeader(BuildContext context, TeamItem team) {
    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).teamDetailTasks,
            style: _sectionTitleStyle(),
          ),
        ),
        if (controller.isCreator)
          FilledButton.icon(
            onPressed: () => _openCreateTask(team),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, 44.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.add_rounded, size: 20.r),
            label: Text(S.of(context).teamDetailCreateTask),
          ),
      ],
    );
  }

  /// 构建包含多人负责人头像和姓名的任务卡片。
  Widget _taskCard(BuildContext context, TaskItem task) {
    final statusColors = _statusColors(task);
    final assigneeNames = _assigneeNames(context, task.assignees);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => controller.onTaskPressed(task),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _taskStatusChip(context, task, statusColors),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                task.description.trim().isEmpty
                    ? S.of(context).teamDetailNoTaskDescription
                    : task.description.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.description.trim().isEmpty
                      ? AppColors.textDisabled
                      : AppColors.textSecondary,
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                S.of(context).teamDetailAssignees,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (task.assignees.isNotEmpty)
                    _avatarStack(task.assignees, maximumVisible: 3, size: 32),
                  if (task.assignees.isNotEmpty) SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      assigneeNames,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16.r,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${S.of(context).teamDetailDeadline}：',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      task.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建任务加载反馈，避免接口等待期间出现空白区域。
  Widget _taskLoadingCard() {
    return Container(
      height: 92.h,
      alignment: Alignment.center,
      decoration: _cardDecoration(),
      child: SizedBox(
        width: 26.r,
        height: 26.r,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  /// 构建当前团队没有细分任务时的空状态。
  Widget _emptyTaskCard(BuildContext context) {
    return Container(
      height: 104.h,
      alignment: Alignment.center,
      decoration: _cardDecoration(),
      child: Text(
        S.of(context).teamDetailNoTasks,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建重叠头像，超出可见数量时使用 +N 汇总。
  Widget _avatarStack(
    List<TeamMemberSummary> members, {
    required int maximumVisible,
    required double size,
  }) {
    final visibleCount = math.min(members.length, maximumVisible);
    final remainingCount = members.length - visibleCount;
    final itemCount = visibleCount + (remainingCount > 0 ? 1 : 0);

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    final extent = size.r;
    final overlapOffset = extent * 0.68;

    return SizedBox(
      width: extent + ((itemCount - 1) * overlapOffset),
      height: extent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < visibleCount; index++)
            Positioned(
              left: index * overlapOffset,
              child: _memberAvatar(members[index], size: size),
            ),
          if (remainingCount > 0)
            Positioned(
              left: visibleCount * overlapOffset,
              child: _remainingAvatar(remainingCount, size: size),
            ),
        ],
      ),
    );
  }

  /// 构建成员头像，图片缺失或加载失败时使用姓名首字。
  Widget _memberAvatar(TeamMemberSummary member, {required double size}) {
    final extent = size.r;

    return Semantics(
      label: member.name,
      image: true,
      child: Container(
        width: extent,
        height: extent,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.14),
          border: Border.all(color: AppColors.surface, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: AvatarImage(
          source: member.avatarUrl,
          fallback: _avatarFallback(member.name, size: size),
        ),
      ),
    );
  }

  /// 构建头像姓名首字兜底。
  Widget _avatarFallback(String name, {required double size}) {
    final trimmedName = name.trim();

    return Center(
      child: trimmedName.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              size: (size * 0.48).r,
              color: AppColors.primary,
            )
          : Text(
              trimmedName.substring(0, 1),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: (size * 0.34).sp,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  /// 构建头像叠加末尾的剩余数量。
  Widget _remainingAvatar(int count, {required double size}) {
    final extent = size.r;

    return Semantics(
      label: '+$count',
      child: Container(
        width: extent,
        height: extent,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.neutral,
          border: Border.all(color: AppColors.surface, width: 2),
        ),
        child: Text(
          '+$count',
          style: TextStyle(
            color: AppColors.white,
            fontSize: (size * 0.27).sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  /// 使用 [team] 打开邀请成员页面；对方接受前保持当前成员快照不变。
  Future<void> _openAddMember(TeamItem team) async {
    await Get.toNamed(
      GetRouter.addTeamMember,
      arguments: team.copyWith(
        members: controller.members.toList(growable: false),
      ),
    );
  }

  /// 打开创建任务独立页面，并接收成功创建的任务返回详情列表。
  Future<void> _openCreateTask(TeamItem team) async {
    final result = await Get.toNamed(
      GetRouter.createTask,
      arguments: team.copyWith(
        members: controller.members.toList(growable: false),
      ),
    );

    if (result is TaskItem) {
      controller.addCreatedTask(result);
    }
  }

  /// 构建任务状态标签。
  Widget _taskStatusChip(
    BuildContext context,
    TaskItem task,
    _StatusColors colors,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        task.isCompleted ? S.of(context).teamDetailCompleted : task.statusLabel,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// 根据任务状态返回具有足够对比度的前景色和背景色。
  _StatusColors _statusColors(TaskItem task) {
    if (task.isCompleted) {
      return _StatusColors(
        foreground: const Color(0xFF19734A),
        background: AppColors.success.withValues(alpha: 0.2),
      );
    }

    if (task.statusLabel == S.current.dashboardStatusInProgress) {
      return _StatusColors(
        foreground: const Color(0xFF237A65),
        background: const Color(0xFF237A65).withValues(alpha: 0.12),
      );
    }

    if (task.statusLabel == S.current.dashboardPriorityHigh) {
      return _StatusColors(
        foreground: AppColors.primary,
        background: AppColors.primary.withValues(alpha: 0.12),
      );
    }

    return _StatusColors(
      foreground: const Color(0xFFC9342D),
      background: const Color(0xFFC9342D).withValues(alpha: 0.1),
    );
  }

  /// 将负责人姓名组合为可换行文案，中文使用顿号分隔。
  String _assigneeNames(
    BuildContext context,
    List<TeamMemberSummary> assignees,
  ) {
    if (assignees.isEmpty) {
      return '—';
    }

    final separator = Localizations.localeOf(context).languageCode == 'zh'
        ? '、'
        : ', ';

    return assignees.map((member) => member.name).join(separator);
  }

  /// 格式化日期，缺失时使用短横线保持信息结构稳定。
  String _formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }

    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  /// 组合团队起止日期，没有结束日期时显示长期。
  String _dateRange(BuildContext context, TeamItem team) {
    final startDate = _formatDate(team.startDate);
    final endDate = team.endDate == null
        ? S.of(context).teamListLongTerm
        : _formatDate(team.endDate);

    return '$startDate  ~  $endDate';
  }

  /// 路由参数无效时展示安全空状态。
  Widget _invalidArguments(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: Text(
          S.of(context).teamListEmpty,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 返回页面卡片统一的背景、圆角和边框。
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
    );
  }

  /// 返回详情页一级分区标题样式。
  TextStyle _sectionTitleStyle() {
    return TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16.sp,
      fontWeight: FontWeight.w800,
    );
  }
}

/// 任务状态标签的前景色和背景色组合。
class _StatusColors {
  const _StatusColors({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}
