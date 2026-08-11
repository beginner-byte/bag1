import 'package:get/get.dart';
import 'package:work_module/features/notifications/notifications.controller.dart';

/// 通知中心依赖绑定，让页面状态跟随路由生命周期创建和释放。
class NotificationsBindings extends Bindings {
  /// 延迟注册通知控制器，只有进入页面时才发起列表请求。
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController());
  }
}
