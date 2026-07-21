import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 登录、注册和找回密码共用的国际手机号输入框。
final class InternationalPhoneField extends StatelessWidget {
  /// 创建国际手机号输入框。
  ///
  /// [controller] 保存不含国际区号的本地号码；[country] 决定区号和地区码；
  /// [onCountryChanged] 在用户选择国家后同步页面状态；[label] 和 [hintText]
  /// 提供明确字段语义。组件只修改输入和国家选择，不主动提交认证请求。
  const InternationalPhoneField({
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    required this.label,
    required this.hintText,
    super.key,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  /// 本地手机号输入控制器，内容不包含国家国际区号。
  final TextEditingController controller;

  /// 当前选中的国家或地区，用于显示国旗、国际区号和 ISO 码。
  final Country country;

  /// 国家选择完成后的状态回调。
  final ValueChanged<Country> onCountryChanged;

  /// 输入框上方的可见标签，不能只依赖占位符表达字段用途。
  final String label;

  /// 本地手机号输入提示，不包含国家国际区号。
  final String hintText;

  /// 键盘下一步动作，默认移动到下一个表单字段。
  final TextInputAction textInputAction;

  /// 键盘提交回调，仅在页面需要从手机号字段直接触发动作时设置。
  final ValueChanged<String>? onSubmitted;

  /// 构建带国家选择入口和本地号码输入区的组合控件。
  ///
  /// [context] 用于读取主题、本地化和展示国家选择弹层；返回完整表单字段。
  @override
  Widget build(BuildContext context) {
    // 当前主题提供输入框文字和表面的完整颜色上下文。
    final theme = Theme.of(context);
    // 当前配色方案用于适配浅色与深色认证页面。
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 52.h,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: _countryButton(context),
              prefixIconConstraints: BoxConstraints(minHeight: 52.h),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: _inputBorder(colorScheme.outlineVariant),
              enabledBorder: _inputBorder(colorScheme.outlineVariant),
              focusedBorder: _inputBorder(colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建国旗和国际区号入口，并保证至少 48pt 的可点击高度。
  ///
  /// [context] 用于打开本地化国家列表；返回只影响当前字段的触控区域。
  Widget _countryButton(BuildContext context) {
    // 当前主题色用于区分国家入口、分隔线和输入内容。
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '${country.name} +${country.phoneCode}',
      child: InkWell(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
        onTap: () => _showCountryPicker(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 108.w, minHeight: 52.h),
          child: Padding(
            padding: EdgeInsets.only(left: 14.w, right: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${country.flagEmoji}  +${country.phoneCode}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.r,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 1,
                  height: 22.h,
                  color: colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 展示可搜索的本地化国家列表，并把用户选择传回所属页面控制器。
  ///
  /// [context] 必须位于已注册 CountryLocalizations 的应用组件树内；关闭弹层
  /// 不会改变当前国家，选择国家时触发 [onCountryChanged]。
  void _showCountryPicker(BuildContext context) {
    // 当前主题色同步到国家列表及搜索框，避免弹层与认证页面割裂。
    final colorScheme = Theme.of(context).colorScheme;

    showCountryPicker(
      context: context,
      showPhoneCode: true,
      useSafeArea: true,
      countryListTheme: CountryListThemeData(
        backgroundColor: colorScheme.surface,
        textStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.72,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      onSelect: onCountryChanged,
    );
  }

  /// 构建与认证页面一致的输入框边框。
  ///
  /// [color] 是当前状态边框色；[width] 是描边宽度，聚焦状态使用更明显描边。
  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
