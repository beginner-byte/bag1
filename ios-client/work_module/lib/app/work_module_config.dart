import 'package:flutter/material.dart';

/// ios-client 启动工作模块时提供的最小运行配置。
final class WorkModuleConfig {
  /// 创建工作模块配置。
  ///
  /// [apiBaseUrl] 是 Worker 服务地址；[session] 是 ios-client 当前用户换取的
  /// Worker 会话；[workerUserId] 是该会话在 Worker 侧对应的用户 ID。
  const WorkModuleConfig({
    required this.apiBaseUrl,
    required this.session,
    required this.workerUserId,
    required this.userUid,
    required this.account,
    required this.displayName,
    required this.avatarUrl,
    this.locale,
    this.themeMode = ThemeMode.system,
  });

  /// Worker API 根地址，不允许为空。
  final String apiBaseUrl;

  /// ios-client 注入的 Worker 会话，不由模块自行登录或持久化。
  final String session;

  /// ios-client 用户在 Worker 服务中的用户 ID，用于工作域权限判断。
  final String workerUserId;

  /// CandyTalk 稳定用户标识，仅用于当前宿主身份展示与后续原生能力跳转。
  final String userUid;

  /// CandyTalk 当前登录账号；允许为空并由“我的”页回退显示用户 UID。
  final String account;

  /// CandyTalk 当前昵称；允许为空。
  final String displayName;

  /// CandyTalk 当前头像地址；允许为空。
  final String avatarUrl;

  /// 宿主指定的语言；为空时跟随系统。
  final Locale? locale;

  /// 宿主指定的明暗主题策略。
  final ThemeMode themeMode;

  /// 将宿主 MethodChannel 参数解析为配置，并拒绝缺少身份信息的启动请求。
  factory WorkModuleConfig.fromMap(Map<Object?, Object?> values) {
    final apiBaseUrl = (values['apiBaseUrl'] as String?)?.trim() ?? '';
    final session = (values['session'] as String?)?.trim() ?? '';
    final workerUserId = (values['workerUserId'] as String?)?.trim() ?? '';
    final userUid = (values['userUid'] as String?)?.trim() ?? '';

    if (apiBaseUrl.isEmpty ||
        session.isEmpty ||
        workerUserId.isEmpty ||
        userUid.isEmpty) {
      throw const FormatException(
        'apiBaseUrl, session, workerUserId and userUid are required',
      );
    }

    return WorkModuleConfig(
      apiBaseUrl: apiBaseUrl,
      session: session,
      workerUserId: workerUserId,
      userUid: userUid,
      account: (values['account'] as String?)?.trim() ?? '',
      displayName: (values['displayName'] as String?)?.trim() ?? '',
      avatarUrl: (values['avatarUrl'] as String?)?.trim() ?? '',
      locale: _parseLocale(values['locale'] as String?),
      themeMode: _parseThemeMode(values['themeMode'] as String?),
    );
  }

  /// 将宿主语言标签转换为 Flutter Locale；空值继续跟随系统。
  static Locale? _parseLocale(String? value) {
    final normalized = value?.trim().replaceAll('-', '_') ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  /// 将宿主主题字符串转换为 ThemeMode，未知值安全回退到跟随系统。
  static ThemeMode _parseThemeMode(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
