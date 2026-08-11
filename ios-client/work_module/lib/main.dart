import 'package:flutter/widgets.dart';
import 'package:work_module/work_module.dart';

/// 独立调试或 FlutterEngine 默认入口；真实配置必须由 ios-client bootstrap 注入。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runWorkModule();
}
