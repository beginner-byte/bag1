import 'package:get/get.dart';
import 'package:worker/core/network/auth/core/target.dart';
import 'package:worker/core/service/auth.service.dart';

abstract class BaseTarget extends Target {
  /// 默认继承 NetworkService 的环境地址，单个接口不再覆盖无效域名。
  @override
  String? get baseUrl => null;

  @override
  Duration get sampleDelay => const Duration(milliseconds: 300);

  @override
  Map<String, dynamic>? get headers {
    final auth = Get.find<AuthService>();
    final session = auth.session;

    /// 未登录接口不附加认证头，避免把空 token 发送给后端。
    if (session == null || session.isEmpty) {
      return null;
    }

    return {'Authorization': 'Bearer $session'};
  }
}
