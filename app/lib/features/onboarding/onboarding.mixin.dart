import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/features/onboarding/onboarding.controller.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

mixin OnboardingMixin on ScreenMixin {
  /// 构建页面主标题，用最少文字说明团队引导的核心任务。
  Widget teamHero(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).teamStartTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          S.of(context).teamStartSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDisabled,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  /// 构建主动创建入口和被动加入说明，避免用户误解为需要邀请码加入。
  Widget teamOptions(BuildContext context, OnboardingController controller) {
    return Column(
      children: [
        teamOptionCard(
          context: context,
          icon: Icons.group_add_outlined,
          iconColor: const Color(0xFF167C58),
          iconBackground: AppColors.secondary.withValues(alpha: 0.55),
          title: S.of(context).teamCreateTitle,
          subtitle: S.of(context).teamCreateSubtitle,
          description: S.of(context).teamCreateDescription,
          onPressed: controller.onCreateTeam,
        ),
        SizedBox(height: 14.h),
        _passiveJoinNote(context),
      ],
    );
  }

  /// 构建被动加入团队说明，明确管理员添加后无需用户执行额外操作。
  Widget _passiveJoinNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              S.of(context).teamPassiveJoinDescription,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个团队入口卡片，同级入口不保留持久选中态。
  Widget teamOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          decoration: BoxDecoration(
            // 两个入口保持一致样式，避免用户误解为单选列表。
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 26.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建底部跳过操作，弱化团队选择流程对新用户的阻塞感。
  Widget teamBottomActions(
    BuildContext context,
    OnboardingController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: controller.onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.68),
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).teamSkip,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward, size: 22.r),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
