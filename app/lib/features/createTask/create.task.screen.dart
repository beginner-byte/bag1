import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/features/createTask/create.task.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 创建任务独立页面，承载任务资料和多人负责人选择。
class CreateTaskScreen extends GetView<CreateTaskController> with ScreenMixin {
  const CreateTaskScreen({super.key});

  /// 页面需要跟随键盘调整布局，避免底部提交按钮遮挡输入区域。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 表单从 AppBar 下方开始，保持标准返回导航层级。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).teamDetailCreateTask),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 构建可滚动任务表单，路由参数无效时展示安全空状态。
  @override
  Widget body(BuildContext context) {
    final team = controller.team;

    if (team == null) {
      return _invalidArguments(context);
    }

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 112.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: S.of(context).teamDetailTaskInfo,
                  icon: Icons.edit_note_rounded,
                  child: Column(
                    children: [
                      _field(
                        label: S.of(context).teamDetailTaskTitle,
                        child: TextField(
                          controller: controller.title,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            hintText: S.of(context).teamDetailTaskTitleHint,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _field(
                        label: S.of(context).teamDetailTaskDescription,
                        child: TextField(
                          controller: controller.description,
                          minLines: 3,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          decoration: _inputDecoration(
                            hintText: S
                                .of(context)
                                .teamDetailTaskDescriptionHint,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                _sectionCard(
                  title: S.of(context).teamDetailTaskTime,
                  icon: Icons.event_rounded,
                  child: Obx(() {
                    final startTime = controller.selectedStartTime.value;
                    final endTime = controller.selectedEndTime.value;

                    return Column(
                      children: [
                        _pickerTile(
                          icon: Icons.play_circle_outline_rounded,
                          label: S.of(context).teamDetailTaskStartTime,
                          value: startTime == null
                              ? S.of(context).teamDetailTaskSelectStartTime
                              : _formatDateTime(startTime),
                          selected: startTime != null,
                          trailing: startTime == null
                              ? null
                              : IconButton(
                                  tooltip: S
                                      .of(context)
                                      .teamDetailTaskClearStartTime,
                                  onPressed: controller.clearStartTime,
                                  icon: const Icon(Icons.close_rounded),
                                  color: AppColors.textSecondary,
                                ),
                          onTap: () => _pickDateTime(context, isStart: true),
                        ),
                        Divider(height: 1.h, color: AppColors.divider),
                        _pickerTile(
                          icon: Icons.stop_circle_outlined,
                          label: S.of(context).teamDetailTaskEndTime,
                          value: endTime == null
                              ? S.of(context).teamDetailTaskSelectEndTime
                              : _formatDateTime(endTime),
                          selected: endTime != null,
                          onTap: () => _pickDateTime(context, isStart: false),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 14.h),
                _sectionCard(
                  title: S.of(context).teamDetailSelectAssignees,
                  icon: Icons.group_outlined,
                  child: Obx(() {
                    return Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: team.members
                          .map((member) {
                            final selected = controller.selectedAssigneeIds
                                .contains(member.id);

                            return FilterChip(
                              selected: selected,
                              showCheckmark: true,
                              checkmarkColor: AppColors.primary,
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              backgroundColor: AppColors.background,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.55)
                                    : AppColors.divider,
                              ),
                              shape: const StadiumBorder(),
                              avatar: _memberAvatar(member),
                              label: Text(member.name),
                              onSelected: (value) {
                                controller.toggleAssignee(member.id, value);
                              },
                            );
                          })
                          .toList(growable: false),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建固定底部创建按钮，返回操作由标准导航按钮和系统手势承担。
  @override
  Widget? bottomNavigationBar(BuildContext context) {
    if (controller.team == null) {
      return null;
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: Obx(() {
                final submitting = controller.submitting.value;

                return ElevatedButton(
                  onPressed: !controller.isCreator || submitting
                      ? null
                      : controller.onCreateTask,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    disabledForegroundColor: AppColors.textDisabled,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: submitting
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          S.of(context).teamDetailCreateTask,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建带图标标题的表单分区，保持任务信息层级清晰。
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
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
                  child: Icon(icon, size: 19.r, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }

  /// 构建不可输入的日期或时间选择行，点击后打开系统选择器。
  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 66.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    icon,
                    size: 19.r,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
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
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 21.r,
                      color: AppColors.textDisabled,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 打开年月日时分一体式滚轮，并按开始或结束类型保存选择结果。
  Future<void> _pickDateTime(
    BuildContext context, {
    required bool isStart,
  }) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final minimumTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final startTime = controller.selectedStartTime.value;
    final selectedTime = isStart ? startTime : controller.selectedEndTime.value;
    final earliestTime = isStart || startTime == null
        ? minimumTime
        : startTime.add(const Duration(minutes: 1));
    final preferredTime =
        selectedTime ?? earliestTime.add(const Duration(hours: 1));
    final initialTime = preferredTime.isBefore(earliestTime)
        ? earliestTime
        : preferredTime;
    final locale = Localizations.localeOf(context).languageCode == 'zh'
        ? picker.LocaleType.zh
        : picker.LocaleType.en;
    final title = isStart
        ? S.of(context).teamDetailTaskSelectStartTime
        : S.of(context).teamDetailTaskSelectEndTime;
    final time = await picker.DatePicker.showDateTimePicker(
      context,
      minTime: earliestTime,
      maxTime: DateTime(now.year + 5, 12, 31, 23, 59),
      currentTime: initialTime,
      locale: locale,
      theme: picker.DatePickerTheme(
        backgroundColor: AppColors.surface,
        headerColor: AppColors.surface,
        containerHeight: 250.h,
        titleHeight: 52.h,
        itemHeight: 44.h,
        itemStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      titleActionsBuilder: (context, onCancel, onConfirm, currentTime) {
        return _pickerTitleActions(
          context: context,
          title: title,
          onCancel: onCancel,
          onConfirm: onConfirm,
        );
      },
    );

    if (time != null) {
      if (isStart) {
        controller.updateStartTime(time);
        return;
      }

      controller.updateEndTime(time);
    }
  }

  /// 构建滚轮 Picker 的标题以及取消、确定操作区。
  Widget _pickerTitleActions({
    required BuildContext context,
    required String title,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        TextButton(
          onPressed: onCancel,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }

  /// 将页面上的任务时间固定显示到分钟精度。
  String _formatDateTime(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }

  /// 构建带可见标签的表单项。
  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 9.h),
        child,
      ],
    );
  }

  /// 构建任务输入框样式，保持触控高度和当前表单视觉一致。
  InputDecoration _inputDecoration({
    required String hintText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: AppColors.background,
      constraints: BoxConstraints(minHeight: 48.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: _inputBorder(AppColors.border),
      enabledBorder: _inputBorder(AppColors.border),
      focusedBorder: _inputBorder(AppColors.primary),
    );
  }

  /// 构建柔和圆角输入边框。
  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  /// 构建负责人头像，网络图片不可用时使用姓名首字兜底。
  Widget _memberAvatar(TeamMemberSummary member) {
    final name = member.name.trim();

    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.14),
      ),
      clipBehavior: Clip.antiAlias,
      child: AvatarImage(
        source: member.avatarUrl,
        fallback: Text(
          name.isEmpty ? '' : name.substring(0, 1),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  /// 路由参数无效时展示安全空状态。
  Widget _invalidArguments(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).teamListEmpty,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
