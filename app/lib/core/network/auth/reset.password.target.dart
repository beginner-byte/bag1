import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

/// 未登录场景通过短信或邮箱验证码重置账号密码的请求目标。
final class ResetPasswordTarget extends BaseTarget {
  /// 创建重置密码请求。
  ///
  /// [identityType] 和 [account] 定位账号；[phoneRegionCode] 仅用于手机号；
  /// [code] 验证账号归属；[newPassword] 是新的登录凭证。
  ResetPasswordTarget({
    required this.identityType,
    required this.account,
    required this.phoneRegionCode,
    required this.code,
    required this.newPassword,
  });

  /// 需要重置密码的账号类型。
  final AuthIdentityType identityType;

  /// 需要重置密码的标准化账号。
  final String account;

  /// 手机号 ISO 国家或地区码；邮箱账号为空字符串。
  final String phoneRegionCode;

  /// 短信或邮箱收到的验证码，Mock 环境固定为 123456。
  final String code;

  /// 验证成功后保存的新密码。
  final String newPassword;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/auth/password/reset';

  /// 使用 JSON 提交统一重置凭证，保持与后续真实认证接口相同的请求边界。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'identityType': identityType.wireValue,
      'account': account,
      'phoneRegionCode': phoneRegionCode,
      'code': code,
      'newPassword': newPassword,
    },
    encoding: ParameterEncoding.json,
  );
}
