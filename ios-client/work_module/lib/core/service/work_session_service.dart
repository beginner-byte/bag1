import 'package:get/get.dart';

/// 工作模块会话服务，只保存 ios-client 本次注入的身份，不提供登录注册能力。
final class WorkSessionService extends GetxService {
  /// 使用宿主提供的 [session] 和 [workerUserId] 创建内存会话。
  WorkSessionService({required String session, required String workerUserId})
    // 保留业务参数名，避免把私有字段名暴露给模块装配层。
    : _session = session, // ignore: prefer_initializing_formals
      _workerUserId = workerUserId; // ignore: prefer_initializing_formals

  /// 当前 Worker Bearer 会话；模块不会写入本地安全存储。
  String _session;

  /// 当前 ios-client 用户映射到 Worker 服务的用户 ID。
  String _workerUserId;

  /// 当前 Bearer 会话。
  String get session => _session;

  /// 当前 Worker 用户 ID。
  String get workerUserId => _workerUserId;

  /// 会话是否仍可用于发送受保护请求。
  bool get isValid => _session.isNotEmpty && _workerUserId.isNotEmpty;

  /// 401 后只清理模块内存身份，实际重新认证交由 ios-client 处理。
  void clear() {
    _session = '';
    _workerUserId = '';
  }
}
