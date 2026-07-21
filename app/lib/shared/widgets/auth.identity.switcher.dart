import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

/// 认证页面共用的手机号与邮箱纯文字切换器。
final class AuthIdentitySwitcher extends StatelessWidget {
  /// 创建账号类型切换器。
  ///
  /// [selected] 是当前选中类型；[onChanged] 在用户选择另一类型时回调；
  /// [phoneLabel] 和 [emailLabel] 来自应用本地化资源。组件只改变选择状态，
  /// [underlined] 决定是否使用下划线标签样式。组件不清理输入或发起认证请求。
  const AuthIdentitySwitcher({
    required this.selected,
    required this.onChanged,
    required this.phoneLabel,
    required this.emailLabel,
    this.underlined = false,
    super.key,
  });

  /// 当前选中的认证账号类型。
  final AuthIdentityType selected;

  /// 用户选择手机号或邮箱后的状态回调。
  final ValueChanged<AuthIdentityType> onChanged;

  /// 手机号选项的本地化文案。
  final String phoneLabel;

  /// 邮箱选项的本地化文案。
  final String emailLabel;

  /// 是否使用无胶囊背景的下划线标签样式，默认保持现有分段样式。
  final bool underlined;

  /// 构建具有明确选中状态、触控反馈和 48pt 高度的双选项控件。
  ///
  /// [context] 用于读取当前明暗主题；返回横向等宽的认证类型切换器。
  @override
  Widget build(BuildContext context) {
    // 当前主题色用于保证切换器在浅色和深色模式下都有明确层级。
    final colorScheme = Theme.of(context).colorScheme;
    // 系统关闭动画时立即切换，否则使用短时长动效提示选中状态变化。
    final animationDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return Container(
      height: 48.h,
      padding: underlined ? EdgeInsets.zero : EdgeInsets.all(4.r),
      decoration: underlined
          ? null
          : BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14.r),
            ),
      child: Row(
        children: [
          Expanded(
            child: _option(
              context: context,
              type: AuthIdentityType.phone,
              label: phoneLabel,
              animationDuration: animationDuration,
              underlined: underlined,
            ),
          ),
          Expanded(
            child: _option(
              context: context,
              type: AuthIdentityType.email,
              label: emailLabel,
              animationDuration: animationDuration,
              underlined: underlined,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个等宽选项，使用背景、字重和边框共同表达选中状态。
  ///
  /// [context] 提供主题；[type] 是该选项的稳定认证类型；[label] 是显示文案；
  /// [animationDuration] 遵循系统动画偏好；[underlined] 决定选中状态使用下划线
  /// 或胶囊表面。点击未选项会触发 [onChanged]，点击当前选项不会重复回调。
  Widget _option({
    required BuildContext context,
    required AuthIdentityType type,
    required String label,
    required Duration animationDuration,
    required bool underlined,
  }) {
    // 当前主题色决定选项的文字、背景和边框反馈。
    final colorScheme = Theme.of(context).colorScheme;
    // 当前选中状态同时用于语义标记、点击控制和视觉强调。
    final isSelected = selected == type;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(11.r),
          onTap: isSelected ? null : () => onChanged(type),
          child: underlined
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: animationDuration,
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 28.w : 0,
                        height: 2.5.h,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ],
                )
              : AnimatedContainer(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11.r),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.outlineVariant
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
