import 'package:get/get.dart';
import 'package:worker/features/tabbar/dashboard/dashboard.controller.dart';
import 'package:worker/features/main/main.controller.dart';
import 'package:worker/features/tabbar/profile/profile.controller.dart';
import 'package:worker/features/tabbar/teams/teams.controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => TeamsController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => MainController());
  }
}
