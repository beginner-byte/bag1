/// 服务端登记的一条可撤销登录设备会话。
final class LoginDevice {
  /// 创建登录设备模型。
  const LoginDevice({
    required this.id,
    required this.deviceName,
    required this.platform,
    required this.lastActiveAt,
    required this.current,
  });

  /// 服务端公开会话标识，用于撤销指定设备但不能直接用于认证。
  final String id;

  /// 登录时由客户端提交的用户可读平台名称。
  final String deviceName;

  /// 稳定平台代码，用于选择对应设备图标。
  final String platform;

  /// 服务端记录的最近活跃时间，统一按 UTC 解析。
  final DateTime lastActiveAt;

  /// 是否为发起本次列表请求的当前会话。
  final bool current;

  /// 从设备会话接口 JSON 创建模型；时间无效时回退到 Unix 起点。
  factory LoginDevice.fromJson(dynamic json) {
    // data 不是对象时按空对象解析，让上层统一处理缺失字段。
    final data = json is Map<String, dynamic> ? json : <String, dynamic>{};
    // parsedLastActiveAt 接受服务端 RFC3339 时间并转换为 UTC。
    final parsedLastActiveAt = DateTime.tryParse(
      data['lastActiveAt']?.toString() ?? '',
    );
    return LoginDevice(
      id: data['id']?.toString() ?? '',
      deviceName: data['deviceName']?.toString() ?? '',
      platform: data['platform']?.toString() ?? '',
      lastActiveAt:
          parsedLastActiveAt?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      current: data['current'] == true,
    );
  }
}
