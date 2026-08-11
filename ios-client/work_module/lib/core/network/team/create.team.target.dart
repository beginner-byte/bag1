import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';
import 'package:work_module/core/network/base.target.dart';

/// 创建团队接口定义，提交团队基础信息并返回完整团队模型。
final class CreateTeamTarget extends BaseTarget {
  /// 创建团队请求。
  ///
  /// [name] 是必填团队名称；[description] 是可选说明；[avatarUrl]
  /// 在图片上传能力接入前保持为空字符串。
  CreateTeamTarget({
    required this.name,
    required this.description,
    required this.avatarUrl,
  });

  /// 团队名称，用于列表和后续团队详情展示。
  final String name;

  /// 团队用途说明，为空表示创建时没有填写。
  final String description;

  /// 团队头像地址，上传能力未接入时为空。
  final String avatarUrl;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/teams';

  /// 使用 JSON 提交创建团队所需的三个基础字段。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
    },
    encoding: ParameterEncoding.json,
  );
}
