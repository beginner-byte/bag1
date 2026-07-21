import 'package:get/get.dart';
import 'package:worker/app/config/environment.dart';
import 'package:worker/core/network/auth/core/network.service.dart';
import 'package:worker/core/service/app.service.dart';
import 'package:worker/core/service/auth.service.dart';

/// 注册 App 启动阶段所需的网络、认证和路由服务。
class AppBinding extends Bindings {
  /// 按依赖顺序初始化服务，避免 AppService 在 AuthService 注册前读取登录态。
  @override
  void dependencies() {
    // 网络服务必须最先注册，认证恢复阶段的 Profile 请求依赖该实例。
    Get.put(
      NetworkService(
        baseUrl: Environment.apiBaseUrl,
        enableMock: Environment.enableMock,
      ),
    );

    // AuthService 内部会把安全存储异常降级为未登录，因此初始化链始终可继续。
    Get.putAsync<AuthService>(() async {
      return await AuthService.initialization();
    }).then((authService) {
      Get.putAsync<AppService>(() async {
        return AppService.initialization(authService);
      });
    });
  }
}
