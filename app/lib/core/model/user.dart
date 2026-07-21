/// 当前登录用户信息，用于承接后端用户资料接口返回的数据。
final class User {
  /// 创建用户模型。
  ///
  /// [id] 是团队和项目添加成员时使用的稳定用户标识；
  /// [displayName]、[avatarUrl]、[gender] 和 [birthday] 用于个人资料展示；
  /// [email] 和 [phone] 只有当前注册方式对应的一项非空；[phoneRegionCode]
  /// 保存手机号注册地区，避免共享国际区号导致地区信息丢失。
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

  /// 服务端生成的稳定用户标识，用于团队和项目成员关系。
  final String id;

  /// 用户展示姓名，用于“我的”页个人资料卡。
  final String displayName;

  /// 用户头像地址，为空或加载失败时由 UI 使用姓名首字兜底。
  final String avatarUrl;

  /// 用户性别代码，使用 male、female 或 unspecified 与接口保持稳定约定。
  final String gender;

  /// 用户生日，使用 YYYY-MM-DD 字符串避免日期时区转换产生偏差。
  final String birthday;

  /// 用户邮箱，手机号账号固定为空字符串。
  final String email;

  /// E.164 格式手机号，邮箱账号固定为空字符串。
  final String phone;

  /// 手机号 ISO 国家或地区码，邮箱账号固定为空字符串。
  final String phoneRegionCode;

  /// 当前账号用于资料展示的主要标识，手机号优先，否则回退邮箱。
  String get primaryAccount => phone.isNotEmpty ? phone : email;

  /// 当前账号是否通过手机号注册，用于选择资料页的展示标签。
  bool get isPhoneAccount => phone.isNotEmpty;

  /// 当前用户是否已经拥有或加入团队，用于登录后的页面分流。
  final bool hasTeam;

  /// 从后端用户信息 JSON 创建用户模型，缺失团队字段时默认按无团队处理。
  factory User.fromJson(dynamic data) {
    return User(
      id: data['id']?.toString() ?? '',
      displayName: data['displayName']?.toString() ?? '',
      avatarUrl: data['avatarUrl']?.toString() ?? '',
      gender: data['gender']?.toString() ?? 'unspecified',
      birthday: data['birthday']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      phoneRegionCode: data['phoneRegionCode']?.toString() ?? '',
      hasTeam: data['hasTeam'] as bool? ?? false,
    );
  }
}
