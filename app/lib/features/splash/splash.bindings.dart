import 'package:get/get.dart';
import 'package:worker/features/splash/splash.controller.dart';

class SplashBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}
