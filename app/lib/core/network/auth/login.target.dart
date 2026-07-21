import 'package:worker/core/network/base.target.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

class LoginTarget extends BaseTarget {
  /// 登录账号类型，用于区分国际手机号和邮箱的标准化规则。
  final AuthIdentityType identityType;

  /// 标准化登录账号，可能是 E.164 手机号或小写邮箱。
  final String account;

  /// 手机号 ISO 国家或地区码；邮箱登录时为空字符串。
  final String phoneRegionCode;

  /// 登录密码，用于后端校验账号凭证。
  final String password;

  /// 当前 App 安装的匿名设备标识，用于替换同一安装的旧会话。
  final String deviceId;

  /// 当前平台的用户可读名称，用于设备列表展示。
  final String deviceName;

  /// 当前平台的稳定接口值，用于服务端保存设备类型。
  final String platform;

  /// 创建登录请求；账号字段必须由页面控制器在提交前完成格式校验。
  LoginTarget({
    required this.identityType,
    required this.account,
    required this.phoneRegionCode,
    required this.password,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
  });

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => "/v1/auth/login";

  /// 使用 JSON body 提交统一账号凭证，手机号额外携带地区码避免共享区号歧义。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'identityType': identityType.wireValue,
      'account': account,
      'phoneRegionCode': phoneRegionCode,
      'password': password,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
    },
    encoding: ParameterEncoding.json,
  );
}
