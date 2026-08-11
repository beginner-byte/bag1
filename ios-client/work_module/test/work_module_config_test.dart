import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/app/work_module_config.dart';

void main() {
  test('bootstrap map parses host identity and presentation preferences', () {
    final config = WorkModuleConfig.fromMap(const {
      'apiBaseUrl': 'https://worker.example.com',
      'session': 'ios-session',
      'workerUserId': 'worker-user-1',
      'userUid': 'candy-user-1',
      'account': 'candy-account',
      'displayName': 'Candy User',
      'avatarUrl': 'https://example.com/avatar.png',
      'locale': 'zh-CN',
      'themeMode': 'dark',
    });

    expect(config.apiBaseUrl, 'https://worker.example.com');
    expect(config.session, 'ios-session');
    expect(config.workerUserId, 'worker-user-1');
    expect(config.userUid, 'candy-user-1');
    expect(config.account, 'candy-account');
    expect(config.displayName, 'Candy User');
    expect(config.avatarUrl, 'https://example.com/avatar.png');
    expect(config.locale, const Locale('zh', 'CN'));
    expect(config.themeMode, ThemeMode.dark);
  });

  test('bootstrap rejects missing ios-client identity mapping', () {
    expect(
      () => WorkModuleConfig.fromMap(const {
        'apiBaseUrl': 'https://worker.example.com',
        'session': '',
        'workerUserId': 'worker-user-1',
        'userUid': '',
      }),
      throwsFormatException,
    );
  });
}
