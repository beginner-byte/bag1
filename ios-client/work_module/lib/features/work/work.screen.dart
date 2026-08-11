import 'package:flutter/widgets.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.screen.dart';

/// 工作模块根页面，复用原 Worker 工作台但不包含登录页或内部 TabBar。
final class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  /// 构建工作台根内容。
  @override
  Widget build(BuildContext context) => const DashboardScreen();
}
