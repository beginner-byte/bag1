/// 请求参数编码方式，决定同一份参数应该放在 URL 还是请求体中。
enum ParameterEncoding {
  /// 把参数放到 URL query 中。
  query,

  /// 把参数作为 JSON 请求体发送。
  json,

  /// 把参数作为 form-urlencoded 请求体发送。
  form,

  /// 把参数编码为 multipart/form-data，用于包含二进制文件的请求。
  multipart,
}

/// 请求任务，作用类似 Moya 的 Task。
///
/// 普通接口只需要一份 parameters，再通过 encoding 决定参数位置。
final class RequestTask {
  /// 无参数请求。
  const RequestTask.plain() : parameters = null, encoding = null;

  /// 带参数请求。
  const RequestTask.parameters({
    required this.parameters,
    required this.encoding,
  });

  /// 请求参数，具体位置由 encoding 决定；multipart 值可包含 Dio MultipartFile。
  final Map<String, dynamic>? parameters;

  /// 参数编码方式。
  final ParameterEncoding? encoding;
}
