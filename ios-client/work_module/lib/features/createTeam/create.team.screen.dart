import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/features/createTeam/create.team.controller.dart';
import 'package:work_module/features/createTeam/create.team.mixin.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/mixins/screen.mixin.dart';

class CreateTeamScreen extends GetView<CreateTeamController>
    with ScreenMixin, CreateTeamMixin {
  const CreateTeamScreen({super.key});

  /// 创建团队页需要跟随键盘调整布局，避免底部按钮被输入法遮挡。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 创建表单必须从 AppBar 下方开始，避免说明文字与导航标题发生重叠。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建带明确标题的导航栏，让返回和当前任务处于同一层级。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).teamCreateTitle),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 构建创建团队页面主体，并允许点击表单外背景释放输入焦点和收起键盘。
  @override
  Widget body(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 112.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  createTeamHeader(context),
                  SizedBox(height: 20.h),
                  createTeamForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部固定创建按钮，让用户填写完成后始终能快速提交。
  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return createTeamBottomNavigationBar(context);
  }

  /// 创建团队事件出口，Screen 统一转交给控制器。
  @override
  void onCreateTeamPressed() {
    controller.onCreateTeam();
  }
}
