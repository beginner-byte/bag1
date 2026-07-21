import 'dart:ui';

import 'package:country_picker/country_picker.dart';

/// 认证账号类型，接口始终使用稳定英文值，避免展示语言影响请求参数。
enum AuthIdentityType {
  /// 国际手机号账号，账号值使用 E.164 格式。
  phone('phone'),

  /// 邮箱账号，账号值统一转换为小写并移除首尾空格。
  email('email');

  /// 创建认证账号类型；[wireValue] 是提交给认证接口的稳定值。
  const AuthIdentityType(this.wireValue);

  /// 认证接口使用的稳定类型值，只允许 phone 或 email。
  final String wireValue;

  /// 从接口或路由值恢复账号类型，未知值安全回退到手机号模式。
  ///
  /// [value] 可以来自 JSON 或 GetX 路由参数；返回值始终有效。
  static AuthIdentityType fromValue(Object? value) {
    return value?.toString() == email.wireValue ? email : phone;
  }
}

/// 标准化后的认证身份，统一承载账号类型、账号值和手机号地区信息。
final class AuthIdentity {
  /// 创建可提交的认证身份。
  ///
  /// [type] 决定 [account] 是邮箱还是 E.164 手机号；手机号必须同时提供
  /// [phoneRegionCode]，用于区分共享同一国际区号的国家或地区。
  const AuthIdentity({
    required this.type,
    required this.account,
    required this.phoneRegionCode,
  });

  /// 当前账号的认证类型。
  final AuthIdentityType type;

  /// 标准化账号；邮箱为小写地址，手机号为 E.164 格式。
  final String account;

  /// 手机号的 ISO 3166-1 alpha-2 地区码；邮箱账号固定为空字符串。
  final String phoneRegionCode;

  /// 标准化邮箱输入，移除首尾空格并统一为小写。
  ///
  /// [value] 是用户输入邮箱；返回值可继续交给邮箱格式校验器判断。
  static String normalizeEmail(String value) => value.trim().toLowerCase();

  /// 把国际区号和本地号码组合为 E.164 账号。
  ///
  /// [phoneCode] 是不带加号的国家区号；[localNumber] 可包含空格、横线和括号。
  /// 返回值只保留数字并以加号开头；无法形成号码时返回空字符串。
  static String normalizePhone({
    required String phoneCode,
    required String localNumber,
  }) {
    final normalizedPhoneCode = phoneCode.replaceAll(RegExp(r'\D'), '');
    final normalizedLocalNumber = localNumber.replaceAll(RegExp(r'\D'), '');

    if (normalizedPhoneCode.isEmpty || normalizedLocalNumber.isEmpty) {
      return '';
    }

    return '+$normalizedPhoneCode$normalizedLocalNumber';
  }

  /// 判断手机号是否满足 E.164 的结构和最多 15 位数字限制。
  ///
  /// [value] 必须是已经标准化的完整国际手机号；本方法不验证号码真实性。
  static bool isValidPhone(String value) {
    return RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(value);
  }

  /// 返回设备地区对应的 ISO 国家码，系统缺失或不受支持时由调用方回退中国。
  static String deviceRegionCode() {
    return PlatformDispatcher.instance.locale.countryCode?.toUpperCase() ?? '';
  }

  /// 根据 ISO 地区码获取国家数据，无法识别时固定回退中国。
  ///
  /// [regionCode] 可以来自设备语言或页面路由；返回值始终包含有效国际区号。
  static Country countryForRegion(String? regionCode) {
    final service = CountryService();
    return service.findByCode(regionCode) ??
        service.findByCode(deviceRegionCode()) ??
        service.findByCode('CN')!;
  }
}

/// 认证页面间传递的账号草稿，切换页面时保留账号类型和用户已输入内容。
final class AuthIdentityDraft {
  /// 创建认证账号草稿。
  ///
  /// [email] 和 [localPhone] 分别保存两种模式的原始输入；[phoneRegionCode]
  /// 用于恢复国家选择，验证码等敏感状态不会跨页面传递。
  const AuthIdentityDraft({
    required this.type,
    required this.email,
    required this.localPhone,
    required this.phoneRegionCode,
  });

  /// 页面打开时应选中的账号类型。
  final AuthIdentityType type;

  /// 用户已经输入的邮箱草稿。
  final String email;

  /// 用户已经输入的本地手机号草稿，不包含国际区号。
  final String localPhone;

  /// 当前选择的 ISO 国家或地区码。
  final String phoneRegionCode;

  /// 转换为 GetX 可安全传递的基础类型映射。
  Map<String, String> toArguments() {
    return {
      'identityType': type.wireValue,
      'email': email,
      'localPhone': localPhone,
      'phoneRegionCode': phoneRegionCode,
    };
  }

  /// 从 GetX 路由参数恢复草稿，缺失或非法参数使用手机号模式和空输入。
  ///
  /// [arguments] 仅接受 Map；返回值不会包含验证码、密码或其他敏感信息。
  factory AuthIdentityDraft.fromArguments(Object? arguments) {
    if (arguments is! Map) {
      return const AuthIdentityDraft(
        type: AuthIdentityType.phone,
        email: '',
        localPhone: '',
        phoneRegionCode: '',
      );
    }

    return AuthIdentityDraft(
      type: AuthIdentityType.fromValue(arguments['identityType']),
      email: arguments['email']?.toString() ?? '',
      localPhone: arguments['localPhone']?.toString() ?? '',
      phoneRegionCode:
          arguments['phoneRegionCode']?.toString().toUpperCase() ?? '',
    );
  }
}
