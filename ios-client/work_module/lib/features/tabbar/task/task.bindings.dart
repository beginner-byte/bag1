import 'package:get/get.dart';
import 'package:work_module/features/tabbar/task/task.controller.dart';

/// 任务列表路由依赖绑定，让控制器跟随二级页生命周期。
class TaskBindings extends Bindings {
  /// 延迟创建任务控制器，避免 Dashboard 首屏预先发起列表请求。
  @override
  void dependencies() {
    Get.lazyPut(() => TaskController());
  }
}
