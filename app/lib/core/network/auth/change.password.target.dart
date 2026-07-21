import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 修改当前登录账号密码的请求目标。
final class ChangePasswordTarget extends BaseTarget {
  /// 创建修改密码请求。
  ///
  /// [currentPassword] 用于验证账号所有权；[newPassword] 是校验通过后保存的新密码。
  ChangePasswordTarget({
    required this.currentPassword,
    required this.newPassword,
  });

  /// 用户当前使用的密码，避免已登录设备在未知原密码时直接修改凭证。
  final String currentPassword;

  /// 用户准备启用的新密码。
  final String newPassword;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/auth/password';

  /// 使用 JSON 提交密码字段，保持与其他认证写操作一致的编码方式。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
    encoding: ParameterEncoding.json,
  );
}
