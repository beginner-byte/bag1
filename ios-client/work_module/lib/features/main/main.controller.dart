import 'package:get/get.dart';

class MainController extends GetxController {
  /// 当前底部导航选中的 tab 下标，用于驱动 IndexedStack 和底部栏状态。
  final RxInt index = 0.obs;

  /// 切换底部 tab，越界值直接忽略以避免异常状态进入页面。
  void onTabChanged(int index) {
    if (index < 0 || index > 2) {
      return;
    }

    this.index.value = index;
  }
}
