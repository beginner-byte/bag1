import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 团队邀请接口定义，通过稳定用户 ID 创建待处理邀请。
final class InviteTeamMemberTarget extends BaseTarget {
  /// 创建团队邀请请求；[teamId] 标识团队，[userId] 标识接收人。
  InviteTeamMemberTarget({required this.teamId, required this.userId});

  /// 目标团队标识。
  final String teamId;

  /// 待邀请用户的稳定用户 ID。
  final String userId;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/teams/members';

  /// 使用 JSON 提交团队和接收人标识，服务端不会在此阶段建立成员关系。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'teamId': teamId, 'userId': userId},
    encoding: ParameterEncoding.json,
  );
}
