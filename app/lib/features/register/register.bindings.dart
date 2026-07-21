import 'package:get/get.dart';
import 'package:worker/features/register/register.controller.dart';

class RegisterBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController());
  }
}
