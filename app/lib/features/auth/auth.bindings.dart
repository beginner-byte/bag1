import 'package:get/get.dart';
import 'package:worker/features/auth/auth.controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
