import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:work_module/app/theme/app.color.dart';

/// 统一展示业务列表无数据时的插图和提示文案。
class EmptyDataState extends StatelessWidget {
  /// 创建通用空数据状态。
  ///
  /// [message] 是当前页面对应的多语言提示；[imageSize] 是插图的设计尺寸，
  /// 会通过 ScreenUtil 按设备尺寸缩放。
  const EmptyDataState({
    super.key,
    required this.message,
    this.imageSize = 156,
  });

  /// 当前业务页面需要展示的本地化空状态文案。
  final String message;

  /// 插图的逻辑宽高，默认值兼顾首页区域和整页列表的展示空间。
  final double imageSize;

  /// 根据 [context] 构建居中的插图与提示文字，并返回可嵌入滚动列表的组件。
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: message,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Image.asset(
              'images/empty_data.png',
              width: imageSize.r,
              height: imageSize.r,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
