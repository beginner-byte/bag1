import 'package:get/get.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/features/createTask/create.task.controller.dart';

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
