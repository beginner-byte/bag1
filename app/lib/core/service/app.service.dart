import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/service/auth.service.dart';

final class AppService extends GetxService {
  AppService._();

  /// 创建 App 路由服务并基于显式传入的认证状态完成首次分流。
  ///
  /// [authService] 必须已经完成安全存储恢复，避免异步 Get.find 初始化竞争。
  static Future<AppService> initialization(AuthService authService) async {
    final service = AppService._();

    await service.initializationAuthService(authService);

    return service;
  }

  /// 刷新登录用户并进入团队、主页面或认证页。
  ///
  /// [service] 是当前唯一认证服务；该方法会触发 Profile 请求和全局路由替换。
  Future<void> initializationAuthService(AuthService service) async {
    if (service.hasLogin) {
      await service.reloadUser();
      // reloadUser 失败时会清理失效 session，不能继续进入已登录页面。
      final user = service.user;

      if (user == null) {
        GetRouter.onAuth();
        return;
      }

      // 有团队或当前账号已主动跳过引导时，都应直接进入主页面。
      final hasCompletedTeamEntry =
          user.hasTeam || await service.hasSkippedTeamOnboarding();
      if (hasCompletedTeamEntry) {
        // GetX 返回的 Future 会等待目标页面退出，登录流程不能等待该页面生命周期。
        Get.offAllNamed(GetRouter.main);
        return;
      }

      // 发起路由替换后立即返回，让登录页 finally 能及时关闭全局 Loading。
      Get.offAllNamed(GetRouter.team);
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    GetRouter.onAuth();
  }
}
