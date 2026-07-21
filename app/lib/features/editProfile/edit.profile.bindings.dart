import 'package:get/get.dart';
import 'package:worker/features/editProfile/edit.profile.controller.dart';

/// 编辑个人资料页依赖绑定，让表单控制器跟随二级页生命周期。
class EditProfileBindings extends Bindings {
  /// 进入编辑页时延迟创建控制器，离开后由 GetX 统一释放。
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
  }
}
