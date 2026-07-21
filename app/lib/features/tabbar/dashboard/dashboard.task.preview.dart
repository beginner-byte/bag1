import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/task/task.item.model.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 首页任务预览底部操作结果，由页面退场后交给 DashboardController 处理。
enum DashboardTaskAction { viewDetails, complete, postpone }

/// 预览页关闭时返回的操作和可选情况说明。
class DashboardTaskResult {
  const DashboardTaskResult({required this.action, this.note = ''});

  final DashboardTaskAction action;
  final String note;
}

/// 生成首页任务 Hero 标识，源卡片和预览卡片必须使用相同值。
String dashboardTaskHeroTag(TaskItem task) => 'dashboard-task-${task.id}';

/// 苹果照片查看风格的任务放大预览，背景和底部操作栏使用毛玻璃效果。
class DashboardTaskPreview extends StatefulWidget {
  const DashboardTaskPreview({required this.task, super.key});

  final TaskItem task;

  @override
  State<DashboardTaskPreview> createState() => _DashboardTaskPreviewState();
}

class _DashboardTaskPreviewState extends State<DashboardTaskPreview> {
  final TextEditingController _noteController = TextEditingController();

  TaskItem get task => widget.task;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: ColoredBox(
                  color: AppColors.black.withValues(alpha: 0.34),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(top: 8.h, right: 16.w, child: _closeButton(context)),
                Align(
                  alignment: const Alignment(0, -0.12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Hero(
                      tag: dashboardTaskHeroTag(task),
                      child: _previewCard(),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  left: 18.w,
                  right: 18.w,
                  bottom: keyboardInset + 14.h,
                  child: _frostedActionBar(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建右上角毛玻璃关闭按钮，保留明确的无障碍标签和点击范围。
  Widget _closeButton(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: AppColors.white.withValues(alpha: 0.2),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// 构建放大后的任务概览卡片，不承载点击操作以避免与背景关闭手势冲突。
  Widget _previewCard() {
    final statusColors = _statusColors();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.65),
            width: 1.2,
          ),
        ),
        // Hero 飞行初期沿用首页小卡片高度，使用不可滚动视口裁切暂时
        // 放不下的内容，避免目标卡片的完整布局在过渡帧中产生溢出。
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
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
              SizedBox(height: 20.h),
              Text(
                task.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (task.description.trim().isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  task.description.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18.r,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      task.time.isEmpty ? '--' : task.time,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
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

  /// 构建底部半透明毛玻璃操作栏，三个动作均使用不小于 48dp 的触控区域。
  Widget _frostedActionBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
                child: TextField(
                  controller: _noteController,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 200,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: S.of(context).taskActionNoteLabel,
                    hintText: S.of(context).taskActionNoteHint,
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.white.withValues(alpha: 0.9),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _actionItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    label: S.of(context).taskActionViewDetails,
                    action: DashboardTaskAction.viewDetails,
                  ),
                  _actionDivider(),
                  _actionItem(
                    context: context,
                    icon: Icons.check_circle_outline_rounded,
                    label: S.of(context).taskActionComplete,
                    action: DashboardTaskAction.complete,
                  ),
                  _actionDivider(),
                  _actionItem(
                    context: context,
                    icon: Icons.schedule_send_outlined,
                    label: S.of(context).taskActionPostpone,
                    action: DashboardTaskAction.postpone,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建单个毛玻璃操作按钮，点击后先关闭预览再由首页处理业务事件。
  Widget _actionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required DashboardTaskAction action,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(
            DashboardTaskResult(
              action: action,
              note: action == DashboardTaskAction.viewDetails
                  ? ''
                  : _noteController.text.trim(),
            ),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 72.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22.r, color: AppColors.white),
              SizedBox(height: 6.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionDivider() {
    return Container(
      width: 1,
      height: 32.h,
      color: AppColors.white.withValues(alpha: 0.24),
    );
  }

  _PreviewStatusColors _statusColors() {
    if (task.isCompleted) {
      return _PreviewStatusColors(
        foreground: const Color(0xFF19734A),
        background: AppColors.success.withValues(alpha: 0.2),
      );
    }

    if (task.statusLabel == S.current.dashboardPriorityHigh) {
      return _PreviewStatusColors(
        foreground: AppColors.primary,
        background: AppColors.primary.withValues(alpha: 0.12),
      );
    }

    return _PreviewStatusColors(
      foreground: const Color(0xFF237A65),
      background: const Color(0xFF237A65).withValues(alpha: 0.12),
    );
  }
}

class _PreviewStatusColors {
  const _PreviewStatusColors({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
