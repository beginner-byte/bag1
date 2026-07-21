import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/core/service/auth.service.dart';

class OnboardingController extends GetxController {
  /// 进入创建团队流程，成功创建后直接进入主页面查看新团队。
  Future<void> onCreateTeam() async {
    final result = await Get.toNamed(GetRouter.createTeam);

    if (result is! TeamItem) {
      return;
    }

    Get.offAllNamed(GetRouter.main);
  }

  /// 保存当前账号的跳过标记后进入主页面，后续启动不再重复展示引导。
  Future<void> onContinue() async {
    try {
      await Get.find<AuthService>().markTeamOnboardingSkipped();
      Get.offAllNamed(GetRouter.main);
    } catch (error) {
      EasyLoading.showError(error.toString());
    }
  }
}
