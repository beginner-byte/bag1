import 'package:get/get.dart';
import 'package:work_module/features/createTeam/create.team.controller.dart';

class CreateTeamBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateTeamController());
  }
}
