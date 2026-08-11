import 'package:flutter/widgets.dart';
import 'package:work_module/app/work_module_app.dart';
import 'package:work_module/core/host/work_host_bridge.dart';

export 'app/work_module_config.dart';
export 'core/host/work_host_bridge.dart';

/// 启动工作模块；未收到 ios-client bootstrap 前只展示等待页且不请求网络。
void runWorkModule({WorkHostBridge? bridge}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WorkModuleApp(bridge: bridge ?? WorkHostBridge()));
}
