import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/model/task/task.item.model.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/core/repository/task.repository.dart';
import 'package:worker/core/service/auth.service.dart';

/// 团队详情控制器，负责权限判断、任务加载、完成情况和任务创建。
class TeamDetailController extends GetxController {
  /// 创建团队详情状态；[team] 为空表示路由参数无效。
  TeamDetailController({required this.team}) {
    members.assignAll(team?.members ?? const []);
  }

  /// 当前详情对应的团队。
  final TeamItem? team;

  /// 任务仓库，统一访问团队任务和创建任务接口。
  final TaskRepository repository = TaskRepository();

  /// 当前登录用户服务，用于判断团队管理权限。
  final AuthService authService = Get.find<AuthService>();

  /// 当前团队的细分任务。
  final RxList<TaskItem> tasks = <TaskItem>[].obs;

  /// 当前详情页成员列表，添加成功后立即驱动头像、数量和负责人选项刷新。
  final RxList<TeamMemberSummary> members = <TeamMemberSummary>[].obs;

  /// 是否正在加载团队任务。
  final RxBool loading = false.obs;

  /// 当前用户是否为团队创建者。
  bool get isCreator {
    final currentTeam = team;
    final userId = authService.user?.id ?? '';

    return currentTeam != null &&
        userId.isNotEmpty &&
        currentTeam.creator.id == userId;
  }

  /// 当前团队任务总数。
  int get totalTaskCount => tasks.length;

  /// 当前团队已完成任务数。
  int get completedTaskCount => tasks.where((task) => task.isCompleted).length;

  /// 当前团队待完成任务数。
  int get pendingTaskCount => totalTaskCount - completedTaskCount;

  /// 当前团队任务完成比例；没有任务时保持为 0。
  double get completionProgress {
    if (totalTaskCount == 0) {
      return 0;
    }

    return completedTaskCount / totalTaskCount;
  }

  /// 页面准备完成后加载当前团队任务。
  @override
  void onReady() {
    super.onReady();
    loadTasks();
  }

  /// 加载当前团队的全部细分任务，并忽略进行中的重复请求。
  Future<void> loadTasks() async {
    final currentTeam = team;

    if (currentTeam == null || loading.value) {
      return;
    }

    loading.value = true;

    try {
      tasks.assignAll(await repository.teamTasks(currentTeam.id));
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      loading.value = false;
    }
  }

  /// 接收创建任务页面返回的新任务，并插入详情列表顶部。
  void addCreatedTask(TaskItem task) {
    if (tasks.any((item) => item.id == task.id)) {
      return;
    }

    tasks.insert(0, task);
  }

  /// 打开任务详情二级页，并传递当前团队任务快照。
  void onTaskPressed(TaskItem task) {
    Get.toNamed(GetRouter.taskDetail, arguments: task);
  }
}
