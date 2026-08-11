import 'package:get/get.dart';
import 'package:work_module/features/taskDetail/task.detail.controller.dart';

/// 任务详情依赖注册。
final class TaskDetailBindings extends Bindings {
  @override
  void dependencies() => Get.lazyPut(TaskDetailController.new);
}
