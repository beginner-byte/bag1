/// 工作模块内部命名路由；所有路径均以 `/work` 开头，避免污染宿主命名空间。
abstract final class GetRouter {
  static const work = '/work';
  static const main = '/work/main';
  static const teams = '/work/teams';
  static const createTeam = '/work/teams/create';
  static const teamDetail = '/work/teams/detail';
  static const teamMembers = '/work/teams/members';
  static const addTeamMember = '/work/teams/members/add';
  static const tasks = '/work/tasks';
  static const createTask = '/work/tasks/create';
  static const taskDetail = '/work/tasks/detail';
  static const notifications = '/work/notifications';
  static const editProfile = '/work/profile/edit';

  /// 将原生 FlutterEngine 传入的初始路由限制为工作或团队根页。
  ///
  /// [routeName] 为空或任意其他路由时安全回退到工作根页。
  static String normalizeRootRoute(String? routeName) {
    return main;
  }
}
