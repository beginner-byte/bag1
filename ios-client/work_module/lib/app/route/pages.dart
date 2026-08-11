import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/features/addTeamMember/add.team.member.bindings.dart';
import 'package:work_module/features/addTeamMember/add.team.member.screen.dart';
import 'package:work_module/features/createTask/create.task.bindings.dart';
import 'package:work_module/features/createTask/create.task.screen.dart';
import 'package:work_module/features/createTeam/create.team.bindings.dart';
import 'package:work_module/features/createTeam/create.team.screen.dart';
import 'package:work_module/features/editProfile/edit.profile.bindings.dart';
import 'package:work_module/features/editProfile/edit.profile.screen.dart';
import 'package:work_module/features/notifications/notifications.bindings.dart';
import 'package:work_module/features/notifications/notifications.screen.dart';
import 'package:work_module/features/main/main.bindings.dart';
import 'package:work_module/features/main/main.screen.dart';
import 'package:work_module/features/tabbar/task/task.bindings.dart';
import 'package:work_module/features/tabbar/task/task.screen.dart';
import 'package:work_module/features/tabbar/teams/teams.screen.dart';
import 'package:work_module/features/taskDetail/task.detail.screen.dart';
import 'package:work_module/features/taskDetail/task.detail.bindings.dart';
import 'package:work_module/features/teamDetail/team.detail.bindings.dart';
import 'package:work_module/features/teamDetail/team.detail.screen.dart';
import 'package:work_module/features/teamMembers/team.members.screen.dart';
import 'package:work_module/features/work/work.screen.dart';

/// 工作模块页面表，只暴露工作台、团队、任务和通知能力。
abstract final class WorkModulePages {
  /// 工作模块全部页面，不包含登录、注册、个人中心和模块内 TabBar。
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: GetRouter.main,
      page: MainScreen.new,
      binding: MainBindings(),
      transition: Transition.noTransition,
    ),
    GetPage(name: GetRouter.work, page: WorkScreen.new),
    GetPage(name: GetRouter.teams, page: TeamsScreen.new),
    GetPage(
      name: GetRouter.createTeam,
      page: CreateTeamScreen.new,
      binding: CreateTeamBindings(),
    ),
    GetPage(
      name: GetRouter.teamDetail,
      page: TeamDetailScreen.new,
      binding: TeamDetailBindings(),
    ),
    GetPage(name: GetRouter.teamMembers, page: TeamMembersScreen.new),
    GetPage(
      name: GetRouter.addTeamMember,
      page: AddTeamMemberScreen.new,
      binding: AddTeamMemberBindings(),
    ),
    GetPage(
      name: GetRouter.tasks,
      page: TaskScreen.new,
      binding: TaskBindings(),
    ),
    GetPage(
      name: GetRouter.createTask,
      page: CreateTaskScreen.new,
      binding: CreateTaskBindings(),
    ),
    GetPage(
      name: GetRouter.taskDetail,
      page: TaskDetailScreen.new,
      binding: TaskDetailBindings(),
    ),
    GetPage(
      name: GetRouter.notifications,
      page: NotificationsScreen.new,
      binding: NotificationsBindings(),
    ),
    GetPage(
      name: GetRouter.editProfile,
      page: EditProfileScreen.new,
      binding: EditProfileBindings(),
    ),
  ];
}
