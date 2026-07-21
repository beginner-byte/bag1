import 'package:flutter_test/flutter_test.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

/// 验证认证入口默认手机号，并保留显式邮箱选择和账号标准化规则。
void main() {
  group('AuthIdentityType', () {
    test('falls back to phone for missing route value', () {
      expect(AuthIdentityType.fromValue(null), AuthIdentityType.phone);
    });

    test('keeps explicit email route value', () {
      expect(AuthIdentityType.fromValue('email'), AuthIdentityType.email);
    });
  });

  group('AuthIdentityDraft', () {
    test('defaults direct auth pages to phone', () {
      final draft = AuthIdentityDraft.fromArguments(null);

      expect(draft.type, AuthIdentityType.phone);
      expect(draft.email, isEmpty);
      expect(draft.localPhone, isEmpty);
    });
  });

  group('AuthIdentity normalization', () {
    test('builds E.164 phone from local formatted input', () {
      final account = AuthIdentity.normalizePhone(
        phoneCode: '86',
        localNumber: '138 0013-8000',
      );

      expect(account, '+8613800138000');
      expect(AuthIdentity.isValidPhone(account), isTrue);
    });
  });
}
