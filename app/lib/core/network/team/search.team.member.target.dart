import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 用户搜索接口定义，通过稳定用户 ID 或注册邮箱查询成员摘要。
final class SearchTeamMemberTarget extends BaseTarget {
  /// 创建用户搜索请求。
  SearchTeamMemberTarget({required this.keyword});

  /// 待查询的稳定用户 ID 或注册邮箱。
  final String keyword;

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get path => '/v1/users/search';

  /// 搜索条件放入 URL query，查询本身不会修改成员关系。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'keyword': keyword},
    encoding: ParameterEncoding.query,
  );
}
