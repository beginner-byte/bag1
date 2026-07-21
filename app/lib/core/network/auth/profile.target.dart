import 'package:worker/core/network/base.target.dart';
import 'package:worker/core/network/auth/core/http.method.dart';

class ProfileTarget extends BaseTarget {
  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => "/v1/auth/profile";
}
