import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';

/// 查询当前 Bearer 会话对应的 Worker 用户资料。
final class ProfileTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/auth/profile';
}
