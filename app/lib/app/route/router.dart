import 'package:get/get.dart';

class GetRouter {
  const GetRouter._();

  static const splash = "/splash";

  static const auth = "/auth";

  static const register = "/register";

  /// 找回密码页，通过邮箱验证码为未登录账号设置新密码。
  static const resetPassword = "/auth/reset-password";

  static const main = "/main";

  static const team = "/team";

  static const createTeam = "/team/create";

  /// 团队详情二级页，通过 arguments 接收当前团队信息。
  static const teamDetail = "/team/detail";

  /// 团队成员二级页，通过 arguments 接收当前团队信息。
  static const teamMembers = "/team/members";

  /// 添加成员二级页，通过 arguments 接收当前团队和成员快照。
  static const addTeamMember = "/add-team-member";

  /// 任务列表二级页，通过 arguments 接收任务筛选类型。
  static const tasks = "/tasks";

  /// 创建任务二级页，通过 arguments 接收当前团队和成员快照。
  static const createTask = "/tasks/create";

  /// 任务详情二级页，通过 arguments 接收完整任务快照。
  static const taskDetail = "/tasks/detail";

  /// 通知中心二级页，展示团队邀请和任务完成确认。
  static const notifications = "/notifications";

  /// 账号与安全二级页，承载账号信息和退出登录等会话操作。
  static const accountSecurity = "/profile/account-security";

  /// 编辑个人资料二级页，只处理头像和昵称等公开资料。
  static const editProfile = "/profile/edit";

  /// 应用设置二级页，承载语言和默认首页等本地偏好。
  static const appSettings = "/profile/app-settings";

  /// 关于我们二级页，展示应用信息和本地法律文档入口。
  static const about = "/profile/about";

  static void onAuth() {
    /// 当前已经在登录页时不重复重建页面，避免输入框控制器被重复销毁。
    if (Get.currentRoute == auth) {
      return;
    }

    Get.offAllNamed(auth);
  }
}
