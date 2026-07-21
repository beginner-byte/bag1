import 'package:get/get.dart';
import 'package:worker/features/accountSecurity/account.security.controller.dart';

/// 账号与安全页面依赖绑定，让控制器跟随二级页生命周期。
class AccountSecurityBindings extends Bindings {
  /// 延迟创建控制器，只有进入账号与安全页面时才初始化会话能力。
  @override
  void dependencies() {
    Get.lazyPut(() => AccountSecurityController());
  }
}
