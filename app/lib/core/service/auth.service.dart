import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/user.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/app.service.dart';

final class AuthService extends GetxService {
  /// 当前已登录用户；未登录或资料刷新失败时为空。
  User? user;

  AuthService._();

  /// 保存后端 session 的安全存储 key，集中定义避免字符串散落。
  static const _sessionKey = 'auth.session';

  /// 团队引导跳过标记前缀，实际 key 会附加当前用户 ID 以隔离不同账号。
  static const _teamOnboardingSkippedKeyPrefix = 'onboarding.team.skipped';

  /// 保存安装级设备标识的安全存储 key；该值不使用系统硬件标识。
  static const _deviceIdKey = 'auth.device.id';

  /// 平台安全存储，用于保存真实客户端登录态而不是 mock 后端数据。
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 当前内存中的 session，初始化时从安全存储恢复。
  String? _session;

  /// 当前 App 安装的随机设备标识，登录和注册时用于关联服务端会话。
  late String _deviceId;

  /// 创建认证服务并恢复安全存储中的 session。
  ///
  /// 安全存储不可用或内容读取失败时回退为未登录状态，避免启动页永久等待。
  static Future<AuthService> initialization() async {
    final service = AuthService._();

    try {
      await service._restoreSession();
    } catch (_) {
      // 只清理内存状态，避免存储本身异常时再次执行删除导致初始化失败。
      service._session = null;
      service.user = null;
    }

    try {
      await service._restoreOrCreateDeviceId();
    } catch (_) {
      // 安全存储异常时使用本次进程内标识，保证用户仍可登录但不会冒充其他设备。
      service._deviceId = service._newDeviceId();
    }

    return service;
  }

  /// 是否已经登录
  bool get hasLogin {
    final session = _session;

    return session != null && session.isNotEmpty;
  }

  /// 当前 session，供后续真实接口统一附加认证信息时使用。
  String? get session {
    return _session;
  }

  /// 当前 App 安装的匿名设备标识，不包含硬件序列号或用户信息。
  String get deviceId => _deviceId;

  /// 当前运行平台的用户可读名称，用于登录设备卡片。
  String get deviceName {
    if (kIsWeb) {
      return 'Web';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iPhone / iPad',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  /// 当前运行平台的稳定接口值，用于服务端和客户端选择设备图标。
  String get devicePlatform {
    if (kIsWeb) {
      return 'web';
    }
    return defaultTargetPlatform.name;
  }

  /// 当前用户是否已经在此设备跳过团队引导。
  ///
  /// 安全存储不可用时回退为未跳过，避免读取偏好导致启动流程中断。
  Future<bool> hasSkippedTeamOnboarding() async {
    final storageKey = _teamOnboardingSkippedKey;
    if (storageKey == null) {
      return false;
    }

    try {
      return await _storage.read(key: storageKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// 为当前登录用户保存团队引导跳过状态。
  ///
  /// 当前用户尚未加载时抛出状态错误，避免写入无法归属账号的全局标记。
  Future<void> markTeamOnboardingSkipped() async {
    final storageKey = _teamOnboardingSkippedKey;
    if (storageKey == null) {
      throw StateError('当前用户尚未加载');
    }

    await _storage.write(key: storageKey, value: 'true');
  }

  /// 当前账号专属的团队引导存储 key；用户为空时不允许读写标记。
  String? get _teamOnboardingSkippedKey {
    final userId = user?.id.trim() ?? '';
    if (userId.isEmpty) {
      return null;
    }

    return '$_teamOnboardingSkippedKeyPrefix.$userId';
  }

  /// 保存登录接口返回的 session，并同步写入平台安全存储。
  Future<void> saveSession(String session) async {
    _session = session;
    await _storage.write(key: _sessionKey, value: session);

    final app = Get.find<AppService>();

    // AppService 是登录成功后的唯一资料刷新和路由入口，避免重复请求 Profile。
    await app.initializationAuthService(this);
  }

  /// 清除当前 session，用于后续退出登录时移除客户端登录态。
  Future<void> clearSession() async {
    _session = null;
    await _storage.delete(key: _sessionKey);
    user = null;
  }

  /// 永久删除账号后清除会话及当前用户专属的本地偏好。
  ///
  /// 必须在 [user] 仍存在时调用，以便定位账号隔离的团队引导标记。
  /// 安装级匿名设备标识不包含账号信息，因此保留供后续注册或登录使用。
  Future<void> clearDeletedAccountData() async {
    // onboardingKey 在 user 清空前计算，确保被删除账号不会留下本地偏好。
    final onboardingKey = _teamOnboardingSkippedKey;
    _session = null;
    user = null;
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // 服务端账号已经永久删除，本地安全存储异常不能阻止返回登录页。
    }
    if (onboardingKey != null) {
      try {
        await _storage.delete(key: onboardingKey);
      } catch (_) {
        // 账号专属偏好不再可达，后续存储恢复时仍不会恢复已删除服务端账号。
      }
    }
  }

  /// 初始化时从安全存储恢复 session，让 App 重启后能识别登录态。
  Future<void> _restoreSession() async {
    _session = await _storage.read(key: _sessionKey);
  }

  /// 恢复安装级设备标识；首次运行时生成随机值并写入安全存储。
  Future<void> _restoreOrCreateDeviceId() async {
    // storedDeviceId 在 App 重启后保持不变，但卸载或清除存储后会重新生成。
    final storedDeviceId = await _storage.read(key: _deviceIdKey);
    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      _deviceId = storedDeviceId;
      return;
    }

    // newDeviceId 只标识本次 App 安装，不读取设备硬件或广告标识。
    final newDeviceId = _newDeviceId();
    await _storage.write(key: _deviceIdKey, value: newDeviceId);
    _deviceId = newDeviceId;
  }

  /// 生成 128 位随机安装标识，返回固定 32 位十六进制字符串。
  String _newDeviceId() {
    // secureRandom 使用系统安全随机源，避免不同安装生成可预测标识。
    final secureRandom = Random.secure();
    // bytes 构成 128 位随机值，足以避免安装标识碰撞。
    final bytes = List<int>.generate(16, (_) => secureRandom.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 刷新用户信息
  Future<void> reloadUser() async {
    final auth = AuthRepository();
    try {
      user = await auth.profile();
    } catch (_) {
      await clearSession();
    }
  }
}
