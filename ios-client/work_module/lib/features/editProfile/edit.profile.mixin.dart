import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/shared/widgets/avatar.image.dart';

/// 编辑资料页面的无状态 UI 组件集合。
mixin EditProfileMixin {
  /// 构建统一圆角资料分组，并在项目之间添加分隔线。
  Widget editProfileGroup(List<Widget> children) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: const Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  /// 构建头像选择行，优先展示尚未保存的本地预览。
  Widget editAvatarRow({
    required String label,
    required String avatarUrl,
    required String localAvatarPath,
    required String avatarInitial,
    required String? statusText,
    required String? errorText,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    final fallback = ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          avatarInitial,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _rowLabel(label)),
                Container(
                  width: 54.r,
                  height: 54.r,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AvatarImage(
                        source: avatarUrl,
                        localPath: localAvatarPath,
                        fallback: fallback,
                      ),
                      if (loading)
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.28),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                _chevron(),
              ],
            ),
            if (errorText != null || statusText != null) ...[
              SizedBox(height: 7.r),
              Text(
                errorText ?? statusText!,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: errorText == null
                      ? AppColors.textSecondary
                      : AppColors.error,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建昵称输入行并在输入无效时展示错误。
  Widget editNameRow({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? errorText,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.r, 12.w, 8.r),
      child: Row(
        crossAxisAlignment: errorText == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SizedBox(width: 82.w, child: _rowLabel(label)),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              textInputAction: TextInputAction.done,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: hint,
                errorText: errorText,
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建可编辑、可复制或只读的通用资料行。
  Widget editValueRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.r),
        child: Row(
          children: [
            SizedBox(width: 82.w, child: _rowLabel(label)),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 10.w),
              trailingIcon == null
                  ? _chevron()
                  : Icon(
                      trailingIcon,
                      size: 17.r,
                      color: AppColors.textDisabled,
                    ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建性别选项面板并返回稳定接口代码。
  Widget genderPicker({
    required BuildContext context,
    required String title,
    required String selectedValue,
    required Map<String, String> options,
  }) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.r, 20.w, 18.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.r),
            editProfileGroup(
              options.entries
                  .map(
                    (entry) => ListTile(
                      onTap: () => Navigator.of(context).pop(entry.key),
                      title: Text(entry.value),
                      trailing: entry.key == selectedValue
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建固定底部保存按钮。
  Widget editSaveButton({
    required String label,
    required bool enabled,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.r,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  /// 构建资料行左侧标签。
  Widget _rowLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
    );
  }

  /// 构建表示可继续操作的右箭头。
  Widget _chevron() {
    return Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textDisabled,
      size: 21.r,
    );
  }
}
