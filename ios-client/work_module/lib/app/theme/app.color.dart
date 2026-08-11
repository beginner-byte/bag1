import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主品牌色，用于主要按钮、选中状态和关键操作。
  static const primary = Color(0xFF5B8FF9);

  // 辅助品牌色，用于次级强调和成功倾向的视觉反馈。
  static const secondary = Color(0xFF63DDB4);

  // 浅色背景色，用于页面背景和大面积容器背景。
  static const tertiary = Color(0xFFFAFAFA);

  // 深色中性色，用于主要文字、深色按钮和高强调元素。
  static const neutral = Color(0xFF1A1C1E);

  // 纯白色，用于卡片、反色文字和浅色表面。
  static const white = Color(0xFFFFFFFF);

  // 纯黑色，用于极高对比度场景。
  static const black = Color(0xFF000000);

  // 页面默认背景色，保持应用整体的柔和浅色风格。
  static const background = tertiary;

  // 页面默认渐变背景顶部色，用于基础页面背景的纵向过渡起点。
  static const backgroundGradientStart = Color(0xFFF3F3F6);

  // 页面默认渐变背景底部色，用于基础页面背景的纵向过渡终点。
  static const backgroundGradientEnd = tertiary;

  // 卡片和输入框等组件的默认表面色。
  static const surface = white;

  // 主要文字颜色，保证正文和标题具有足够对比度。
  static const textPrimary = neutral;

  // 次要文字颜色，用于提示、说明和弱化信息。
  static const textSecondary = Color(0xFF6B7280);

  // 禁用文字颜色，用于不可交互状态。
  static const textDisabled = Color(0xFF9CA3AF);

  // 默认边框颜色，用于输入框、分割线和描边按钮。
  static const border = Color(0xFFD1D5DB);

  // 轻量分割线颜色，用于页面内部弱分隔。
  static const divider = Color(0xFFE5E7EB);

  // 错误色，用于删除、失败和危险操作。
  static const error = Color(0xFFC9342D);

  // 成功色，沿用辅助品牌色来保持视觉系统一致。
  static const success = secondary;
}
