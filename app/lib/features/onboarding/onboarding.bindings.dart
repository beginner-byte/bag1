import 'package:get/get.dart';
import 'package:worker/features/onboarding/onboarding.controller.dart';

class OnboardingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
  }
}
