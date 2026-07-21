import 'package:worker/core/network/base.target.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

class RegisterTarget extends BaseTarget {
  /// 注册账号类型，用于区分手机号和邮箱的唯一性校验。
  final AuthIdentityType identityType;

  /// 标准化注册账号，可能是 E.164 手机号或小写邮箱。
  final String account;

  /// 手机号 ISO 国家或地区码；邮箱注册时为空字符串。
  final String phoneRegionCode;

  /// 注册密码，当前由调用方完成基础非空和确认密码校验。
  final String password;

  /// 短信或邮箱验证码，用于模拟注册前的账号归属校验。
  final String code;

  /// 当前 App 安装的匿名设备标识，用于创建首个可撤销会话。
  final String deviceId;

  /// 当前平台的用户可读名称，用于设备列表展示。
  final String deviceName;

  /// 当前平台的稳定接口值，用于服务端保存设备类型。
  final String platform;

  /// 创建双账号注册请求；账号必须由页面控制器完成标准化和格式校验。
  RegisterTarget({
    required this.identityType,
    required this.account,
    required this.phoneRegionCode,
    required this.password,
    required this.code,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
  });

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => "/v1/auth/register";

  /// 使用 JSON body 传递统一注册表单，保持和后续真实接口的入参形态一致。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'identityType': identityType.wireValue,
      'account': account,
      'phoneRegionCode': phoneRegionCode,
      'password': password,
      'code': code,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
    },
    encoding: ParameterEncoding.json,
  );
}
