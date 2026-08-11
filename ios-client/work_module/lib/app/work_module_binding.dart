import 'package:get/get.dart';
import 'package:work_module/app/work_module_config.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/network/core/network.service.dart';
import 'package:work_module/core/service/work_session_service.dart';

/// 工作模块根依赖，只注册工作域和宿主会话相关对象。
final class WorkModuleBinding extends Bindings {
  /// 使用宿主 [config] 和通信 [bridge] 创建根依赖。
  WorkModuleBinding({required this.config, required this.bridge});

  /// ios-client 提供的本次启动配置。
  final WorkModuleConfig config;

  /// 模块向 ios-client 报告会话失效等事件的桥。
  final WorkHostBridge bridge;

  /// 注册宿主会话和网络基础设施；页面控制器由对应路由 Binding 管理。
  @override
  void dependencies() {
    Get.put<WorkHostBridge>(bridge, permanent: true);
    Get.put(
      WorkSessionService(
        session: config.session,
        workerUserId: config.workerUserId,
      ),
      permanent: true,
    );
    Get.put(
      NetworkService(
        baseUrl: config.apiBaseUrl,
        onUnauthorized: bridge.notifySessionExpired,
      ),
      permanent: true,
    );
  }
}
