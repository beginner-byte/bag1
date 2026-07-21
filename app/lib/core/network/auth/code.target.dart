import 'package:worker/core/network/base.target.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

class CodeTarget extends BaseTarget {
  /// 验证码接收账号类型，用于区分 Mock 短信和邮件流程。
  final AuthIdentityType identityType;

  /// 标准化验证码接收账号，可能是 E.164 手机号或小写邮箱。
  final String account;

  /// 手机号 ISO 国家或地区码；邮箱请求时为空字符串。
  final String phoneRegionCode;

  /// 创建验证码请求；调用方必须先完成账号格式校验。
  CodeTarget({
    required this.identityType,
    required this.account,
    required this.phoneRegionCode,
  });

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => "/v1/auth/code";

  /// 使用 JSON body 发送统一账号信息，保持验证码和注册接口参数一致。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'identityType': identityType.wireValue,
      'account': account,
      'phoneRegionCode': phoneRegionCode,
    },
    encoding: ParameterEncoding.json,
  );

  /// Mock 验证码响应，返回固定 code 方便开发阶段完成双账号注册链路。
  @override
  Object? get sampleData => {'code': 0, 'message': 'success'};
}
