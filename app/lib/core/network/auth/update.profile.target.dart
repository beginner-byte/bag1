import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 更新当前用户公开资料的请求目标，提交可编辑的个人资料字段。
final class UpdateProfileTarget extends BaseTarget {
  /// 创建资料更新请求。
  ///
  /// [displayName] 是新的公开昵称；[avatarUrl] 暂时沿用当前头像地址，
  /// 等头像上传能力接入后再由上传结果替换；[gender] 和 [birthday]
  /// 分别使用稳定枚举代码与 YYYY-MM-DD 日期格式。
  UpdateProfileTarget({
    required this.displayName,
    required this.avatarUrl,
    required this.gender,
    required this.birthday,
  });

  /// 用户新的公开昵称。
  final String displayName;

  /// 用户头像地址，当前没有选择新图片时保持原值。
  final String avatarUrl;

  /// 用户性别代码，允许 male、female 或 unspecified。
  final String gender;

  /// 用户生日字符串，为空表示尚未设置。
  final String birthday;

  @override
  HttpMethod get method => HttpMethod.patch;

  @override
  String get path => '/v1/auth/profile/update';

  /// 使用 JSON 提交与 User 模型一致的可编辑资料字段。
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
