/// 后端统一响应外壳。
///
/// `T` 表示业务数据类型，具体转换由 `decoder` 回调完成。
final class Response<T> {
  /// 创建统一响应对象。
  const Response({required this.code, this.message, this.data, this.raw});

  /// 业务状态码，由后端响应中的 `code` 字段提供。
  final int code;

  /// 业务提示文案，兼容后端常见的 `msg` 和 `message` 字段。
  final String? message;

  /// 解析后的业务数据。
  final T? data;

  /// 原始响应数据，便于特殊场景兜底处理。
  final dynamic raw;

  /// 根据统一响应 JSON 创建响应对象。
  ///
  /// [json] 是 Dio 返回的原始响应数据。
  /// [decoder] 用于把 `data` 字段转换为业务模型。
  factory Response.fromJson(dynamic json, {T Function(dynamic data)? decoder}) {
    if (json is! Map<String, dynamic>) {
      return Response<T>(code: -1, message: '响应格式错误', raw: json);
    }

    final body = json['data'];

    return Response<T>(
      code: _parseCode(json['code']),
      message: _parseMessage(json),
      data: decoder == null || body == null ? null : decoder(body),
      raw: json,
    );
  }

  /// 兼容 int 和数字字符串两种 code 格式。
  static int _parseCode(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? -1;
    }

    return -1;
  }

  /// 兼容 `msg` 和 `message` 两种后端提示字段。
  static String? _parseMessage(Map<String, dynamic> json) {
    final message = json['msg'] ?? json['message'];

    if (message == null) {
      return null;
    }

    return message.toString();
  }
}
