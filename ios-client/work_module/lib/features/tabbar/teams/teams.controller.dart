import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/core/repository/team.repository.dart';

/// 团队列表控制器，负责加载和刷新当前用户的团队。
class TeamsController extends GetxController {
  /// 团队仓库，统一访问团队列表接口。
  final TeamRepository repository = TeamRepository();

  /// 当前用户可访问的团队列表。
  final RxList<TeamItem> teams = <TeamItem>[].obs;

  /// 是否仍在执行团队页第一次数据加载；完成后不再因后台刷新重新显示骨架。
  final RxBool initialLoading = true.obs;

  /// 团队请求互斥标记；普通刷新不改变页面展示，但仍需阻止重复请求。
  bool _requestingTeams = false;

  final EasyRefreshController easyRefresh = EasyRefreshController();

  /// 页面首帧完成后通过 EasyRefresh 触发首次刷新。
  @override
  void onReady() {
    super.onReady();
    easyRefresh.callRefresh();
  }

  /// 加载团队列表，并忽略请求进行期间的重复刷新。
  Future<void> loadTeams() async {
    if (_requestingTeams) {
      return;
    }

    _requestingTeams = true;

    try {
      final fetchedTeams = await repository.teams();
      teams.assignAll(fetchedTeams);
    } catch (error) {
      EasyLoading.showToast(error.toString());
    } finally {
      initialLoading.value = false;
      _requestingTeams = false;
    }
  }

  /// 打开创建团队页，并将成功返回的团队即时插入当前列表顶部。
  Future<void> onCreateTeam() async {
    // GetX 命名路由返回动态结果，运行时校验可以避免导航阶段的泛型转换异常。
    final result = await Get.toNamed(GetRouter.createTeam);

    if (result is! TeamItem) {
      return;
    }

    final alreadyExists = teams.any((team) => team.id == result.id);

    if (alreadyExists) {
      return;
    }

    teams.insert(0, result);
  }

  /// 打开团队详情页，并传递当前列表中已经加载完成的团队信息。
  void onTeamPressed(TeamItem team) {
    Get.toNamed(GetRouter.teamDetail, arguments: team);
  }

  /// 释放 EasyRefresh 控制器与页面状态的绑定，避免持有已销毁页面。
  @override
  void onClose() {
    easyRefresh.dispose();
    super.onClose();
  }
}
