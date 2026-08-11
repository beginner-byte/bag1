import 'package:get/get.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/features/addTeamMember/add.team.member.controller.dart';

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
