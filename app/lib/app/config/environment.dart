/// App 编译期环境配置，统一控制 Mock 开关和真实 API 地址。
abstract final class Environment {
  /// 是否启用本地 Mock 后端；默认关闭以直接使用线上 Co Here 服务。
  static const bool enableMock = bool.fromEnvironment(
    'ENABLE_MOCK',
    defaultValue: false,
  );

  /// 真实服务端基础地址；默认连接线上 API，开发时可通过 --dart-define 覆盖。
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://web.cohereweb.xyz',
  );

  /// 独立配置法律文档服务器；未配置时与 API 使用同一服务地址。
  static const String _configuredLegalBaseUrl = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: '',
  );

  /// 返回不带末尾斜杠的法律文档基础地址，避免拼接出重复分隔符。
  static String get legalBaseUrl {
    // configuredBaseUrl 允许生产环境将法律页面独立部署到 HTTPS 域名。
    final configuredBaseUrl = _configuredLegalBaseUrl.trim();
    // selectedBaseUrl 在未独立配置时回退到当前 API 服务地址。
    final selectedBaseUrl = configuredBaseUrl.isEmpty
        ? apiBaseUrl.trim()
        : configuredBaseUrl;

    return selectedBaseUrl.endsWith('/')
        ? selectedBaseUrl.substring(0, selectedBaseUrl.length - 1)
        : selectedBaseUrl;
  }
}
