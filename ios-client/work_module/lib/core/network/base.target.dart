import 'package:get/get.dart';
import 'package:work_module/core/network/core/target.dart';
import 'package:work_module/core/service/work_session_service.dart';

abstract class BaseTarget extends Target {
  /// 默认继承 NetworkService 的环境地址，单个接口不再覆盖无效域名。
  @override
  String? get baseUrl => null;

  @override
  Map<String, dynamic>? get headers {
    final session = Get.find<WorkSessionService>().session;

    /// 未登录接口不附加认证头，避免把空 token 发送给后端。
    if (session.isEmpty) {
      return null;
    }

    return {'Authorization': 'Bearer $session'};
  }
}
