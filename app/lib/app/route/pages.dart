import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/features/about/about.screen.dart';
import 'package:worker/features/accountSecurity/account.security.bindings.dart';
import 'package:worker/features/accountSecurity/account.security.screen.dart';
import 'package:worker/features/addTeamMember/add.team.member.bindings.dart';
import 'package:worker/features/addTeamMember/add.team.member.screen.dart';
import 'package:worker/features/appSettings/app.settings.bindings.dart';
import 'package:worker/features/appSettings/app.settings.screen.dart';
import 'package:worker/features/auth/auth.bindings.dart';
import 'package:worker/features/auth/auth.screen.dart';
import 'package:worker/features/createTeam/create.team.bindings.dart';
import 'package:worker/features/createTeam/create.team.screen.dart';
import 'package:worker/features/createTask/create.task.bindings.dart';
import 'package:worker/features/createTask/create.task.screen.dart';
import 'package:worker/features/teamDetail/team.detail.screen.dart';
import 'package:worker/features/teamDetail/team.detail.bindings.dart';
import 'package:worker/features/teamMembers/team.members.screen.dart';
import 'package:worker/features/taskDetail/task.detail.screen.dart';
import 'package:worker/features/editProfile/edit.profile.bindings.dart';
import 'package:worker/features/editProfile/edit.profile.screen.dart';
import 'package:worker/features/main/main.bindings.dart';
import 'package:worker/features/main/main.screen.dart';
import 'package:worker/features/notifications/notifications.bindings.dart';
import 'package:worker/features/notifications/notifications.screen.dart';
import 'package:worker/features/register/register.bindings.dart';
import 'package:worker/features/register/register.screen.dart';
import 'package:worker/features/resetPassword/reset.password.bindings.dart';
import 'package:worker/features/resetPassword/reset.password.screen.dart';
import 'package:worker/features/splash/splash.bindings.dart';
import 'package:worker/features/splash/splash.screen.dart';
import 'package:worker/features/onboarding/onboarding.bindings.dart';
import 'package:worker/features/onboarding/onboarding.screen.dart';
import 'package:worker/features/tabbar/task/task.bindings.dart';
import 'package:worker/features/tabbar/task/task.screen.dart';

class GetPages {
  GetPages._();

  static final pages = [
    GetPage(
      name: GetRouter.splash,
      page: () => SplashScreen(),
      binding: SplashBindings(),
    ),
    GetPage(
      name: GetRouter.auth,
      page: () => const AuthScreen(),
      binding: AuthBindings(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: GetRouter.register,
      page: () => RegisterScreen(),
      binding: RegisterBindings(),
    ),
    GetPage(
      name: GetRouter.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBindings(),
    ),
    GetPage(
      name: GetRouter.main,
      page: () => MainScreen(),
      binding: MainBindings(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: GetRouter.team,
      page: () => OnboardingScreen(),
      binding: OnboardingBindings(),
    ),
    GetPage(
      name: GetRouter.createTeam,
      page: () => CreateTeamScreen(),
      binding: CreateTeamBindings(),
    ),
    GetPage(
      name: GetRouter.teamDetail,
      page: () => const TeamDetailScreen(),
      binding: TeamDetailBindings(),
    ),
    GetPage(name: GetRouter.teamMembers, page: () => const TeamMembersScreen()),
    GetPage(
      name: GetRouter.addTeamMember,
      page: () => const AddTeamMemberScreen(),
      binding: AddTeamMemberBindings(),
    ),
    GetPage(
      name: GetRouter.tasks,
      page: () => const TaskScreen(),
      binding: TaskBindings(),
    ),
    GetPage(
      name: GetRouter.createTask,
      page: () => const CreateTaskScreen(),
      binding: CreateTaskBindings(),
    ),
    GetPage(name: GetRouter.taskDetail, page: () => const TaskDetailScreen()),
    GetPage(
      name: GetRouter.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBindings(),
    ),
    GetPage(
      name: GetRouter.accountSecurity,
      page: () => const AccountSecurityScreen(),
      binding: AccountSecurityBindings(),
    ),
    GetPage(
      name: GetRouter.editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBindings(),
    ),
    GetPage(
      name: GetRouter.appSettings,
      page: () => const AppSettingsScreen(),
      binding: AppSettingsBindings(),
    ),
    GetPage(name: GetRouter.about, page: () => const AboutScreen()),
  ];
}
