import 'package:get/get.dart';
import 'package:work_module/features/editProfile/edit.profile.controller.dart';

/// 编辑个人资料页依赖注册。
final class EditProfileBindings extends Bindings {
  /// 每次进入编辑页创建独立表单控制器。
  @override
  void dependencies() {
    Get.lazyPut(EditProfileController.new);
  }
}
