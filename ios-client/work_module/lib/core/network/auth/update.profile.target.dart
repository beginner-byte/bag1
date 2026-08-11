import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 更新当前 Worker 用户可编辑的公开资料。
final class UpdateProfileTarget extends BaseTarget {
  /// 使用页面校验后的资料字段创建更新请求。
  UpdateProfileTarget({
    required this.displayName,
    required this.avatarUrl,
    required this.gender,
    required this.birthday,
  });

  /// 新的展示昵称。
  final String displayName;

  /// 新头像地址；未换头像时沿用原值。
  final String avatarUrl;

  /// 性别稳定代码。
  final String gender;

  /// YYYY-MM-DD 格式生日，允许为空。
  final String birthday;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/auth/profile/update';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'birthday': birthday,
    },
    encoding: ParameterEncoding.json,
  );
}
