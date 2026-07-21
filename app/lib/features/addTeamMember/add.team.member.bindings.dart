import 'package:get/get.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/features/addTeamMember/add.team.member.controller.dart';

/// 添加成员路由依赖绑定。
class AddTeamMemberBindings extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;

    Get.lazyPut(
      () => AddTeamMemberController(
        team: arguments is TeamItem ? arguments : null,
      ),
    );
  }
}
