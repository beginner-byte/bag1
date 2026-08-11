import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/pages.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/app/theme/app.theme.dart';
import 'package:work_module/app/work_module_binding.dart';
import 'package:work_module/app/work_module_config.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/host/work_navigation_observer.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 工作模块根组件，在宿主身份到达前不会创建业务依赖或发起 Worker 请求。
final class WorkModuleApp extends StatefulWidget {
  /// 使用指定宿主通信 [bridge] 创建根组件。
  const WorkModuleApp({required this.bridge, super.key});

  /// ios-client 与工作模块的通信桥。
  final WorkHostBridge bridge;

  /// 创建负责隔离不同宿主会话的状态对象。
  @override
  State<WorkModuleApp> createState() => _WorkModuleAppState();
}

/// 监听 bootstrap/clearSession，并在重建页面前同步清空旧 GetX 依赖。
final class _WorkModuleAppState extends State<WorkModuleApp> {
  /// 注册宿主桥监听；后续每次通知都代表会话边界发生变化。
  @override
  void initState() {
    super.initState();
    widget.bridge.addListener(_handleHostSessionChanged);
  }

  /// 桥对象被替换时迁移监听，避免旧 Engine 通道继续驱动当前页面。
  @override
  void didUpdateWidget(covariant WorkModuleApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bridge == widget.bridge) {
      return;
    }
    oldWidget.bridge.removeListener(_handleHostSessionChanged);
    widget.bridge.addListener(_handleHostSessionChanged);
    _handleHostSessionChanged();
  }

  /// 清空旧用户的控制器、仓储和内存 token，再装载当前宿主配置。
  void _handleHostSessionChanged() {
    Get.reset();
    if (mounted) {
      setState(() {});
    }
  }

  /// 根据 bootstrap 状态在等待页和真实工作模块之间切换。
  @override
  Widget build(BuildContext context) {
    final config = widget.bridge.config;
    if (config == null) {
      return const _WaitingForHostApp();
    }
    return _ReadyWorkModule(
      key: ValueKey(widget.bridge.revision),
      config: config,
      bridge: widget.bridge,
    );
  }

  /// 解除宿主桥监听，避免 FlutterEngine 销毁后继续持有页面状态。
  @override
  void dispose() {
    widget.bridge.removeListener(_handleHostSessionChanged);
    super.dispose();
  }
}

/// 已取得宿主配置的工作模块应用。
final class _ReadyWorkModule extends StatelessWidget {
  /// 创建可访问 Worker 服务的模块应用。
  const _ReadyWorkModule({
    required this.config,
    required this.bridge,
    super.key,
  });

  /// 当前宿主启动配置。
  final WorkModuleConfig config;

  /// 当前宿主通信桥。
  final WorkHostBridge bridge;

  /// 初始化屏幕适配、路由、本地化和工作域依赖。
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Work',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: config.themeMode,
          locale: config.locale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialBinding: WorkModuleBinding(config: config, bridge: bridge),
          initialRoute: GetRouter.main,
          getPages: WorkModulePages.pages,
          navigatorObservers: [
            WorkNavigationObserver(bridge.setHostTabBarHidden),
          ],
          builder: _buildAppOverlay,
        );
      },
    );
  }

  /// 组合全局加载层和背景点击手势，使所有业务页面能够统一收起键盘。
  Widget _buildAppOverlay(BuildContext context, Widget? child) {
    final easyLoadingBuilder = EasyLoading.init(
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    return easyLoadingBuilder(context, child);
  }
}

/// 未收到身份配置时的安全占位，不泄露也不伪造 Worker 登录入口。
final class _WaitingForHostApp extends StatelessWidget {
  const _WaitingForHostApp();

  /// 展示简洁等待状态，宿主 bootstrap 后自动替换为工作台。
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
