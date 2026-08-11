/// 当前登录用户的 Worker 资料，由资料查询和更新接口返回。
final class User {
  /// 创建完整用户资料。
  const User({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.phone,
    required this.phoneRegionCode,
    required this.hasTeam,
  });

  /// Worker 稳定公开用户 ID。
  final String id;

  /// Worker 业务页面使用的展示昵称。
  final String displayName;

  /// Worker 头像公开地址，允许为空。
  final String avatarUrl;

  /// 性别代码：male、female 或 unspecified。
  final String gender;

  /// YYYY-MM-DD 格式生日，允许为空。
  final String birthday;

  /// 邮箱登录账号，手机号账号时为空。
  final String email;

  /// E.164 手机号登录账号，邮箱账号时为空。
  final String phone;

  /// 手机号 ISO 国家或地区码，邮箱账号时为空。
  final String phoneRegionCode;

  /// 当前账号是否已经加入团队。
  final bool hasTeam;

  /// 当前账号用于只读展示的主要登录标识。
  String get primaryAccount => phone.isNotEmpty ? phone : email;

  /// 当前 Worker 账号是否使用手机号登录标识。
  bool get isPhoneAccount => phone.isNotEmpty;

  /// 将后端资料响应转换为用户模型，兼容未设置的可选字段。
  factory User.fromJson(dynamic data) {
    final values = data is Map ? data : const <Object?, Object?>{};
    return User(
      id: values['id']?.toString() ?? '',
      displayName: values['displayName']?.toString() ?? '',
      avatarUrl: values['avatarUrl']?.toString() ?? '',
      gender: values['gender']?.toString() ?? 'unspecified',
      birthday: values['birthday']?.toString() ?? '',
      email: values['email']?.toString() ?? '',
      phone: values['phone']?.toString() ?? '',
      phoneRegionCode: values['phoneRegionCode']?.toString() ?? '',
      hasTeam: values['hasTeam'] as bool? ?? false,
    );
  }
}
