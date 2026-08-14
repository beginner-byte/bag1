import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/app/work_module_config.dart';

/// 工作模块与 ios-client 的单一通信入口。
final class WorkHostBridge extends ChangeNotifier {
  /// 创建宿主桥并监听 `bootstrap` 与 `clearSession` 指令。
  WorkHostBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_handleMethodCall);
    unawaited(_notifyModuleReady());
  }

  /// iOS 与 Flutter 双方约定的 MethodChannel 名称。
  static const String channelName = 'com.cohere.work/bridge';

  /// 底层 MethodChannel，仅用于宿主输入和模块事件通知。
  final MethodChannel _channel;

  /// 最近一次有效启动配置；为空时模块保持等待宿主状态。
  WorkModuleConfig? _config;

  /// 宿主身份或会话每次变化时递增，用于重建 Flutter 路由与依赖容器。
  int _revision = 0;

  /// 最近一次有效启动配置。
  WorkModuleConfig? get config => _config;

  /// 当前宿主会话版本；数值本身不包含用户标识或 Worker token。
  int get revision => _revision;

  /// 原生会话列表的未读总数，仅驱动工作页右上角消息角标。
  final ValueNotifier<int> messageUnreadCount = ValueNotifier<int>(0);

  /// 测试或宿主启动路径共用的配置入口，成功后通知根组件装载工作页面。
  void applyBootstrap(WorkModuleConfig config) {
    _config = config;
    _revision += 1;
    notifyListeners();
  }

  /// 接收 ios-client 发来的启动或会话清理指令。
  Future<Object?> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'bootstrap':
        final arguments = call.arguments;
        if (arguments is! Map) {
          throw const FormatException('bootstrap arguments must be a map');
        }
        applyBootstrap(WorkModuleConfig.fromMap(arguments));
        return true;
      case 'clearSession':
        _config = null;
        _revision += 1;
        messageUnreadCount.value = 0;
        notifyListeners();
        return true;
      case 'showWorkRoot':
        await _showRoot(GetRouter.work);
        return true;
      case 'showTeamsRoot':
        await _showRoot(GetRouter.teams);
        return true;
      case 'setMessageUnreadCount':
        final arguments = call.arguments;
        final count = arguments is Map ? arguments['count'] : null;
        messageUnreadCount.value = count is int && count > 0 ? count : 0;
        return true;
      default:
        throw MissingPluginException(
          'Unknown work host method: ${call.method}',
        );
    }
  }

  /// 通知 ios-client：Worker 会话已失效，应由宿主用户体系重新换取会话。
  Future<void> notifySessionExpired() async {
    await _channel.invokeMethod<void>('sessionExpired');
  }

  /// 通知 ios-client 通道监听已经建立，宿主收到后即可安全发送 bootstrap。
  Future<void> _notifyModuleReady() async {
    try {
      await _channel.invokeMethod<void>('moduleReady');
    } on MissingPluginException {
      // 独立 Flutter 调试没有原生宿主，保持等待页即可。
    }
  }

  /// 通知 ios-client 是否需要隐藏原生 TabBar，供后续二级页接入时使用。
  Future<void> setHostTabBarHidden(bool hidden) async {
    try {
      await _channel.invokeMethod<void>('setTabBarHidden', {'hidden': hidden});
    } on MissingPluginException {
      // 独立 Flutter 调试没有原生 TabBar，不需要模拟宿主界面。
    }
  }

  /// 请求 ios-client 在当前工作导航栈打开原生消息列表。
  Future<void> openMessages() async {
    try {
      await _channel.invokeMethod<void>('openMessages');
    } on MissingPluginException {
      // 独立 Flutter 调试没有原生消息页，保持当前页面即可。
    }
  }

  /// 通知 ios-client 打开原生通讯录，具体控制器和导航行为由宿主实现。
  Future<void> openContacts() async {
    try {
      await _channel.invokeMethod<void>('openContacts');
    } on MissingPluginException {
      // 独立 Flutter 调试没有原生通讯录，保持当前团队页即可。
    }
  }

  /// 请求 CandyTalk 更新当前用户的 IM 名字和可选头像，并返回 IM 最终头像地址。
  ///
  /// [displayName] 是去除首尾空白后的新名字；[avatarBytes] 为空时保留当前 IM 头像。
  Future<String> updateCurrentUserProfile({
    required String displayName,
    Uint8List? avatarBytes,
    String? avatarFileName,
  }) async {
    final result = await _channel
        .invokeMapMethod<String, dynamic>('updateCurrentUserProfile', {
          'displayName': displayName,
          'avatarBytes': ?avatarBytes,
          'avatarFileName': ?avatarFileName,
        });
    return result?['avatarUrl']?.toString() ?? '';
  }

  /// 打开 CandyTalk 原生好友选择器，并只允许选择当前团队对应的好友。
  Future<List<String>> selectTaskFriends(
    List<String> allowedCandyUserUids,
  ) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'selectTaskFriends',
        {'allowedCandyUserUids': allowedCandyUserUids},
      );
      return (result ?? const [])
          .whereType<Map>()
          .map((item) => item['candyUserUid']?.toString() ?? '')
          .where((identifier) => identifier.isNotEmpty)
          .toList(growable: false);
    } on MissingPluginException {
      return const [];
    }
  }

  /// 请求 CandyTalk 静默创建任务群，返回群标识和服务端校验所需成员集合。
  Future<TaskGroupCreationResult> createTaskGroup({
    required String title,
    required List<Map<String, String>> members,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'createTaskGroup',
      {'title': title, 'members': members},
    );
    final memberUIDs = result?['memberCandyUserUids'];
    return TaskGroupCreationResult(
      groupId: result?['groupId']?.toString() ?? '',
      memberCandyUserUids: memberUIDs is List
          ? memberUIDs.map((value) => value.toString()).toList(growable: false)
          : const [],
    );
  }

  /// 请求当前 CandyTalk 用户创建团队群，只返回稳定群标识。
  Future<TeamGroupCreationResult> createTeamGroup({
    required String title,
    required List<Map<String, String>> members,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'createTeamGroup',
      {'title': title, 'members': members},
    );
    final memberUIDs = result?['memberCandyUserUids'];
    return TeamGroupCreationResult(
      groupId: result?['groupId']?.toString() ?? '',
      memberCandyUserUids: memberUIDs is List
          ? memberUIDs.map((value) => value.toString()).toList(growable: false)
          : const [],
    );
  }

  /// 邀请一名新增团队成员进入已绑定 CandyTalk 群。
  Future<void> inviteTeamGroupMember({
    required String groupId,
    required String candyUserUid,
    required String name,
  }) async {
    await _channel.invokeMethod<void>('inviteTeamGroupMember', {
      'groupId': groupId,
      'candyUserUid': candyUserUid,
      'name': name,
    });
  }

  /// 打开已经绑定到任务的原生 CandyTalk 群聊。
  Future<void> openTaskGroup(String groupId) async {
    await _channel.invokeMethod<void>('openTaskGroup', {'groupId': groupId});
  }

  /// 请求群主通过 CandyTalk SDK 解散任务群。
  Future<void> dissolveTaskGroup(String groupId) async {
    await _channel.invokeMethod<void>('dissolveTaskGroup', {
      'groupId': groupId,
    });
  }

  /// 请求 CandyTalk 原生宿主清理 IM 和用户会话并返回登录页面。
  Future<void> logout() async {
    try {
      await _channel.invokeMethod<void>('logout');
    } on MissingPluginException {
      // 独立 Flutter 调试没有 CandyTalk 登录宿主，不模拟退出副作用。
    }
  }

  /// 使用替换根路由的方式切换工作/团队 Tab，避免重复点击累积返回栈。
  ///
  /// [routeName] 只允许传入工作模块的两个根路由。
  Future<void> _showRoot(String routeName) async {
    if (_config == null || Get.currentRoute == routeName) {
      return;
    }
    await Get.offAllNamed<void>(routeName);
  }

  /// 解除 MethodChannel 回调，避免 Engine 销毁后继续持有桥对象。
  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    messageUnreadCount.dispose();
    super.dispose();
  }
}

/// CandyTalk 静默建群成功结果。
final class TaskGroupCreationResult {
  /// 创建结果包含服务端群标识和实际成员 UID 集合。
  const TaskGroupCreationResult({
    required this.groupId,
    required this.memberCandyUserUids,
  });

  /// CandyTalk 群唯一标识。
  final String groupId;

  /// 创建人和全部负责人组成的实际成员集合。
  final List<String> memberCandyUserUids;
}

/// CandyTalk 团队群创建结果，包含实际初始成员集合。
final class TeamGroupCreationResult {
  /// 创建不可变团队群结果。
  const TeamGroupCreationResult({
    required this.groupId,
    required this.memberCandyUserUids,
  });

  /// CandyTalk 群唯一标识。
  final String groupId;

  /// CandyTalk 实际建群成员 UID。
  final List<String> memberCandyUserUids;
}
