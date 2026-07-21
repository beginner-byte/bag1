import 'package:get/get.dart';
import 'package:worker/features/appSettings/app.settings.controller.dart';

/// 应用设置页面依赖绑定，让页面控制器跟随路由生命周期。
class AppSettingsBindings extends Bindings {
  /// 进入设置页时延迟创建控制器，离开后自动释放页面状态。
  @override
  void dependencies() {
    Get.lazyPut(() => AppSettingsController());
  }
}
