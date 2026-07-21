import 'package:get/get.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/features/createTask/create.task.controller.dart';

/// 创建任务路由依赖绑定。
class CreateTaskBindings extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;

    Get.lazyPut(
      () =>
          CreateTaskController(team: arguments is TeamItem ? arguments : null),
    );
  }
}
