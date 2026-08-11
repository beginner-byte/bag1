import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:work_module/app/route/router.dart';

/// 原生 TabBar 显隐回调；参数为 true 时宿主隐藏底部栏。
typedef HostTabBarHiddenCallback = Future<void> Function(bool hidden);

/// 观察工作模块路由栈，并把根页/二级页状态同步给 ios-client。
final class WorkNavigationObserver extends NavigatorObserver {
  /// 使用宿主 [setHidden] 回调创建观察器。
  WorkNavigationObserver(this._setHidden);

  /// 向 ios-client 发送当前底部栏显隐状态。
  final HostTabBarHiddenCallback _setHidden;

  /// 最近一次已发送状态，避免连续导航回调产生重复 MethodChannel 消息。
  bool? _lastHidden;

  /// 新页面入栈后，工作和团队根页显示原生 TabBar，其余页面隐藏。
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _syncRoute(route);
  }

  /// 页面出栈后，以重新可见的上一页决定原生 TabBar 状态。
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _syncRoute(previousRoute);
  }

  /// 当前路由被移除后，以其下方重新可见路由同步原生 TabBar。
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _syncRoute(previousRoute);
  }

  /// 路由替换后，以新路由同步原生 TabBar。
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _syncRoute(newRoute);
  }

  /// 忽略根路由替换中的临时空路由，仅在有效页面的显隐值变化时通知宿主。
  void _syncRoute(Route<dynamic>? route) {
    final routeName = route?.settings.name;
    if (routeName == null) {
      return;
    }
    final hidden = routeName != GetRouter.work && routeName != GetRouter.teams;
    if (_lastHidden == hidden) {
      return;
    }
    _lastHidden = hidden;
    unawaited(_notifyHost(hidden));
  }

  /// 执行宿主回调；导航成功不依赖原生界面是否仍可接收消息。
  Future<void> _notifyHost(bool hidden) async {
    try {
      await _setHidden(hidden);
    } on Object {
      // Engine 退出或宿主通道尚未建立时，保留 Flutter 当前导航状态。
    }
  }
}
