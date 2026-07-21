/// HTTP 请求方法枚举，避免在业务代码中直接散落字符串。
enum HttpMethod { get, post, put, patch, delete }

extension HttpMethodValue on HttpMethod {
  /// 转换为 Dio 需要的请求方法字符串。
  String get value => name.toUpperCase();
}
