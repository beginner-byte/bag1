import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 编辑个人资料页的纯 UI 组件集合，不依赖 Screen、GetX 或业务控制器。
mixin EditProfileMixin {
  /// 构建微信式圆角资料分组，并在相邻资料项之间添加轻量分隔线。
  ///
  /// [children] 按页面业务顺序传入，分组组件只负责统一外观与间距。
  Widget editProfileGroup(List<Widget> children) {
    // 分组必须直接提供 Material 表面，否则 ListTile 的水波纹会被背景装饰层遮挡。
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

  /// 构建头像资料项，图片不可用时使用昵称首字兜底。
  ///
  /// [label] 是资料项标题；[avatarUrl] 是当前头像地址；[localAvatarPath]
  /// 是尚未保存的优先预览；[statusText] 与 [errorText] 显示选择和上传状态；
  /// [loading] 控制头像遮罩；[onTap] 为空时临时禁用相册入口。
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
    // fallback 使用昵称首字，在网络、本地文件或图片解码失败时保持页面可识别。
    final fallback = Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        avatarInitial,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
                              child: Center(
                                child: SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                ),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建内嵌昵称输入资料项，让用户无需进入额外页面即可完成修改。
  ///
  /// [label] 和 [hint] 提供当前语言文案；[controller] 持有昵称输入状态；
  /// [errorText] 仅在昵称无效时显示，避免正常状态占用额外高度。
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
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                errorText: errorText,
                counterText: '',
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通用资料项，可用于可选字段、只读字段和复制操作。
  ///
  /// [label] 是左侧字段名称；[value] 是右侧当前值；[onTap] 为空时表示只读；
  /// [trailingIcon] 用于区分复制和继续编辑操作。
  Widget editValueRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                    color: value.isEmpty
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }

  /// 构建性别选择面板，用稳定代码作为返回值并高亮当前选择。
  ///
  /// [context] 用于关闭当前面板；[title] 是面板标题；[selectedValue] 是当前代码；
  /// [options] 的 key 是接口代码，value 是当前语言下的展示文案。
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 6.r),
            editProfileGroup(
              options.entries.map((entry) {
                final selected = entry.key == selectedValue;

                return ListTile(
                  onTap: () => Navigator.of(context).pop(entry.key),
                  title: Text(entry.value),
                  trailing: selected
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 21.r,
                        )
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建固定底部保存按钮，并在请求期间显示轻量进度指示器。
  ///
  /// [label] 是按钮文案；[enabled] 控制可点击状态；[loading] 控制进度状态；
  /// [onPressed] 由业务层提供实际保存操作。
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
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  /// 构建资料项左侧统一标签，确保分组内文字基线和字重一致。
  Widget _rowLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 构建低强调的右箭头，表达当前资料项可以继续进入选择操作。
  Widget _chevron() {
    return Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textDisabled,
      size: 21.r,
    );
  }
}
