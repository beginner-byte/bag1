import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:work_module/features/tabbar/teams/team.cell.dart';
import 'package:work_module/features/tabbar/teams/teams.controller.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/mixins/screen.mixin.dart';
import 'package:work_module/shared/widgets/empty.data.state.dart';

/// 团队 Tab 列表页，展示当前用户创建或加入的所有团队。
class TeamsScreen extends GetView<TeamsController> with ScreenMixin {
  const TeamsScreen({super.key});

  /// 团队 Tab 使用底部导航的页面结构，不让内容延伸到 AppBar 后方。
  @override
  bool extendBodyBehindAppBar() {
    return true;
  }

  /// 构建团队页标题栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).mainTabTeams),
      centerTitle: false,
      titleSpacing: 18.w,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: controller.onCommunicationPressed,
          icon: const Icon(Icons.group_outlined),
        ),
        IconButton(
          tooltip: S.of(context).teamCreateTitle,
          onPressed: controller.onCreateTeam,
          icon: const Icon(Icons.add_rounded),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  /// 使用 [context] 获取本地化文案，构建支持首次加载、下拉刷新和空状态的团队列表。
  ///
  /// 返回值在团队为空时展示统一插图，有数据时展示原有团队卡片列表。
  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        // initialLoading 只在第一次团队请求期间为 true，普通刷新保留当前内容。
        final initialLoading = controller.initialLoading.value;

        return Skeletonizer(
          enabled: initialLoading,
          child: EasyRefresh(
            controller: controller.easyRefresh,
            onRefresh: controller.loadTeams,
            child: !initialLoading && controller.teams.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 120.h, 18.w, 110.h),
                    children: [
                      EmptyDataState(message: S.of(context).teamListEmpty),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 110.h),
                    itemCount: initialLoading ? 3 : controller.teams.length,
                    itemBuilder: (context, index) {
                      if (initialLoading) {
                        return TeamCell.skeleton();
                      }

                      final team = controller.teams[index];

                      return TeamCell(
                        team: team,
                        onTap: () => controller.onTeamPressed(team),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 14.h),
                  ),
          ),
        );
      }),
    );
  }
}
