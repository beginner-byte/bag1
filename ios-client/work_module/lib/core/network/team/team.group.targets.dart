import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 团队群创建领取接口。
final class StartTeamGroupTarget extends BaseTarget {
  /// 创建指定团队的领取请求。
  StartTeamGroupTarget(this.teamId);

  /// Worker 团队公开标识。
  final String teamId;
  @override
  HttpMethod get method => HttpMethod.post;
  @override
  String get path => '/v1/teams/group/start';
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'teamId': teamId},
    encoding: ParameterEncoding.json,
  );
}

/// 团队群绑定接口。
final class BindTeamGroupTarget extends BaseTarget {
  /// 创建绑定请求；三个标识必须与 Worker 当前操作一致。
  BindTeamGroupTarget({
    required this.teamId,
    required this.groupId,
    required this.operationId,
    required this.memberCandyUserUids,
  });

  /// Worker 团队公开标识。
  final String teamId;

  /// CandyTalk 返回的群标识。
  final String groupId;

  /// Worker 领取操作 UUID。
  final String operationId;

  /// CandyTalk 实际建群成员 UID。
  final List<String> memberCandyUserUids;
  @override
  HttpMethod get method => HttpMethod.post;
  @override
  String get path => '/v1/teams/group/bind';
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'teamId': teamId,
      'groupId': groupId,
      'operationId': operationId,
      'memberCandyUserUids': memberCandyUserUids,
    },
    encoding: ParameterEncoding.json,
  );
}

/// 领取下一条团队群成员邀请。
final class NextTeamGroupMemberTarget extends BaseTarget {
  /// 创建指定团队的领取请求。
  NextTeamGroupMemberTarget(this.teamId);

  /// Worker 团队公开标识。
  final String teamId;
  @override
  HttpMethod get method => HttpMethod.post;
  @override
  String get path => '/v1/teams/group/member/next';
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'teamId': teamId},
    encoding: ParameterEncoding.json,
  );
}

/// 完成或失败一条团队群成员邀请。
final class TeamGroupMemberResultTarget extends BaseTarget {
  /// 创建成员邀请结果请求。
  TeamGroupMemberResultTarget({
    required this.teamId,
    required this.memberId,
    required this.operationId,
    required this.failed,
    this.message = '',
  });

  /// Worker 团队公开标识。
  final String teamId;

  /// Worker 成员公开标识。
  final String memberId;

  /// 领取操作 UUID。
  final String operationId;

  /// 是否记录为可重试失败。
  final bool failed;

  /// 有界 SDK 错误。
  final String message;
  @override
  HttpMethod get method => HttpMethod.post;
  @override
  String get path => failed
      ? '/v1/teams/group/member/failure'
      : '/v1/teams/group/member/complete';
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'teamId': teamId,
      'memberId': memberId,
      'operationId': operationId,
      if (failed) 'message': message,
    },
    encoding: ParameterEncoding.json,
  );
}

/// 团队群原生失败回写接口。
final class FailTeamGroupTarget extends BaseTarget {
  /// 创建明确 SDK 失败回写请求。
  FailTeamGroupTarget({
    required this.teamId,
    required this.operationId,
    required this.message,
  });

  /// Worker 团队公开标识。
  final String teamId;

  /// Worker 领取操作 UUID。
  final String operationId;

  /// 有界展示错误，服务端会再次裁剪。
  final String message;
  @override
  HttpMethod get method => HttpMethod.post;
  @override
  String get path => '/v1/teams/group/failure';
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {
      'teamId': teamId,
      'operationId': operationId,
      'message': message,
    },
    encoding: ParameterEncoding.json,
  );
}
