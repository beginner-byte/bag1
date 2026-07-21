import 'package:get/get.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/features/teamDetail/team.detail.controller.dart';

/// 团队详情路由依赖绑定。
class TeamDetailBindings extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;

    Get.lazyPut(
      () =>
          TeamDetailController(team: arguments is TeamItem ? arguments : null),
    );
  }
}
