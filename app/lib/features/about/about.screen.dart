import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/features/tabbar/profile/profile.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/utils/legal.document.launcher.dart';

/// 关于我们页面，集中展示应用身份、版本和两份法律文档入口。
class AboutScreen extends StatelessWidget with ScreenMixin, ProfileMixin {
  const AboutScreen({super.key});

  /// 让二级页内容从 AppBar 下方开始，避免应用信息被标题栏遮挡。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建带系统返回按钮的关于我们标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).profileAbout),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 组合 Co Here 品牌信息和隐私政策、用户协议入口。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 24.r, 16.w, 32.r),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  _appIdentity(context),
                  SizedBox(height: 24.r),
                  _legalDocuments(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建应用 Logo、名称、产品说明和当前固定版本信息。
  Widget _appIdentity(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 28.r, 24.w, 24.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 5.r),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'images/logo.png',
            width: 88.r,
            height: 88.r,
            fit: BoxFit.contain,
            semanticLabel: S.of(context).appName,
          ),
          SizedBox(height: 14.r),
          Text(
            S.of(context).appName.toUpperCase(),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            S.of(context).aboutDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          SizedBox(height: 10.r),
          Text(
            S.of(context).aboutVersion,
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建两份服务器法律文档的菜单入口，并按稳定枚举选择链接。
  Widget _legalDocuments(BuildContext context) {
    return profileMenuGroup([
      ProfileMenuData(
        icon: Icons.privacy_tip_outlined,
        iconColor: const Color(0xFF2E67C7),
        iconBackground: const Color(0xFFEDF3FF),
        title: S.of(context).profilePrivacy,
        onTap: () => _openLegalDocument(LegalDocumentType.privacy),
      ),
      ProfileMenuData(
        icon: Icons.description_outlined,
        iconColor: const Color(0xFF237A65),
        iconBackground: const Color(0xFFE8F7F2),
        title: S.of(context).profileTerms,
        onTap: () => _openLegalDocument(LegalDocumentType.agreement),
      ),
    ]);
  }

  /// 使用系统浏览器打开 [type] 对应的服务器协议链接。
  Future<void> _openLegalDocument(LegalDocumentType type) async {
    await LegalDocumentLauncher.open(type);
  }
}
