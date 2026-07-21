import 'package:get/get.dart';
import 'package:worker/features/resetPassword/reset.password.controller.dart';

/// 找回密码页面依赖绑定，确保输入状态只在当前路由生命周期内存在。
final class ResetPasswordBindings extends Bindings {
  /// 延迟创建控制器，页面真正进入时才分配输入资源。
  @override
  void dependencies() {
    Get.lazyPut(() => ResetPasswordController());
  }
}
