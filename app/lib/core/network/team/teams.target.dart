import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/base.target.dart';

/// 当前用户团队列表接口定义。
class TeamsTarget extends BaseTarget {
  /// 团队列表使用 GET 请求。
  @override
  HttpMethod get method => HttpMethod.get;

  /// 返回当前用户创建或加入的所有团队。
  @override
  String get path => '/v1/teams';
}
