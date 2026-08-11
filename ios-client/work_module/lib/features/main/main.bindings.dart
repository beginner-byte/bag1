import 'package:get/get.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.controller.dart';
import 'package:work_module/features/main/main.controller.dart';
import 'package:work_module/features/tabbar/profile/profile.controller.dart';
import 'package:work_module/features/tabbar/teams/teams.controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => TeamsController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => MainController());
  }
}
