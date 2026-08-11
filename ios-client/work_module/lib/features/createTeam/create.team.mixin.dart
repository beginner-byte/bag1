import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/features/createTeam/create.team.controller.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 创建团队页面的组件构建集合，保持 Screen 只负责页面配置和事件出口。
mixin CreateTeamMixin on GetView<CreateTeamController> {
  /// 创建按钮点击事件，由 Screen 暴露并转交给控制器处理。
  void onCreateTeamPressed();

  /// 构建底部固定创建按钮，让用户填写完成后始终能快速提交。
  Widget createTeamBottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // 底部操作栏只占用按钮所需高度，避免挤压页面主体内容。
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: Obx(() {
                final canSubmit = controller.canSubmit.value;
                final submitting = controller.submitting.value;

                return ElevatedButton(
                  onPressed: canSubmit ? onCreateTeamPressed : null,
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
                          S.of(context).teamCreateSubmit,
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

  /// 构建简短页面说明，避免和 AppBar 标题重复争夺视觉层级。
  Widget createTeamHeader(BuildContext context) {
    return Text(
      S.of(context).teamCreateScreenSubtitle,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }

  /// 构建单张扁平资料卡片，集中团队名称和描述以缩短浏览路径。
  Widget createTeamForm(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
          side: BorderSide(color: AppColors.divider.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _nameField(context),
                  SizedBox(height: 16.h),
                  _descriptionField(context),
                  SizedBox(height: 12.h),
                  _helperNote(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建团队名称输入框，作为创建团队的唯一必填字段。
  Widget _nameField(BuildContext context) {
    return _field(
      label: S.of(context).teamCreateNameLabel,
      child: Obx(() {
        final errorText = controller.nameError.value;

        return TextField(
          controller: controller.name,
          textInputAction: TextInputAction.next,
          maxLength: 30,
          decoration: _inputDecoration(
            hintText: S.of(context).teamCreateNameHint,
            errorText: errorText.isEmpty ? null : errorText,
            counterText: '',
          ),
        );
      }),
    );
  }

  /// 构建团队描述输入框，用较高输入区域承载简短团队说明。
  Widget _descriptionField(BuildContext context) {
    return _field(
      label: S.of(context).teamCreateDescriptionLabel,
      child: TextField(
        controller: controller.description,
        minLines: 3,
        maxLines: 5,
        maxLength: 200,
        textInputAction: TextInputAction.newline,
        decoration: _inputDecoration(
          hintText: S.of(context).teamCreateDescriptionHint,
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  /// 构建辅助说明，降低用户对一次性填完整资料的压力。
  Widget _helperNote(BuildContext context) {
    return Text(
      S.of(context).teamCreatePageNote,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }

  /// 构建带标签的表单项，统一标签和输入框之间的空间关系。
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

  /// 构建创建团队页输入框样式，保证触控高度和可读性。
  InputDecoration _inputDecoration({
    String? hintText,
    String? errorText,
    String? counterText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      counterText: counterText,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: AppColors.background,
      constraints: BoxConstraints(minHeight: 48.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: _inputBorder(AppColors.border),
      enabledBorder: _inputBorder(AppColors.border),
      focusedBorder: _inputBorder(AppColors.primary),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error),
    );
  }

  /// 构建输入框边框，使用柔和圆角匹配当前移动端表单风格。
  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}
