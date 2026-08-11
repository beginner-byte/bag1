import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/core/repository/task.repository.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

class DashboardController extends GetxController {
  /// 任务仓库，统一通过网络层获取任务相关数据。
  final TaskRepository repository = TaskRepository();

  /// 今日待办列表，网络请求完成后更新并驱动页面刷新。
  final RxList<TaskItem> tasks = <TaskItem>[].obs;

  /// 今日待办加载状态，用于后续扩展骨架屏或空态。
  final RxBool loading = false.obs;

  /// 整个首页是否仍处于第一次数据加载，完成后不再因后台刷新重新开启骨架。
  final RxBool _initialLoading = true.obs;

  /// 汇总请求互斥标记，避免下拉刷新和通知处理同时覆盖统计结果。
  bool _requestingSummary = false;

  /// 任务请求互斥标记；后台刷新时不改变列表骨架状态，但仍需阻止重复请求。
  bool _requestingTasks = false;

  /// 我的任务数量，来源于 Worker 汇总接口。
  final myTaskCount = 0.obs;

  /// 今日截止任务数量，来源于 Worker 汇总接口。
  final dueTodayCount = 0.obs;

  /// 进行中任务数量，来源于 Worker 汇总接口。
  final inProgressCount = 0.obs;

  /// 未读通知数量，来源于 Worker 汇总接口。
  final unreadCount = 0.obs;

  /// 正在更新状态的任务 ID，避免重复触发完成或延后请求。
  final Set<String> _updatingTaskIds = {};

  /// 初始化 Dashboard 的非界面数据。
  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  /// 并行刷新首页统计和今日待办；只有第一次调用会维持整页骨架状态。
  Future<void> refreshDashboard() async {
    try {
      await Future.wait([load(), loadTask()]);
    } finally {
      _initialLoading.value = false;
    }
  }

  /// 加载 Dashboard 顶部统计数据，并同步到响应式数量字段。
  Future<void> load() async {
    if (_requestingSummary) {
      return;
    }

    _requestingSummary = true;

    try {
      final summary = await repository.summary();
      myTaskCount.value = summary.myTaskCount;
      dueTodayCount.value = summary.dueTodayCount;
      inProgressCount.value = summary.inProgressCount;
      unreadCount.value = summary.unreadCount;
    } catch (error) {
      EasyLoading.showToast(error.toString());
    } finally {
      _requestingSummary = false;
    }
  }

  /// 首次数据尚未就绪时启用 Dashboard 骨架，已有任务刷新时保留真实内容。
  bool get initialLoading {
    return _initialLoading.value;
  }

  /// 加载今日待办，并防止重复请求导致列表状态相互覆盖。
  Future<void> loadTask() async {
    if (_requestingTasks) {
      return;
    }

    _requestingTasks = true;
    if (_initialLoading.value) {
      loading.value = true;
    }

    try {
      final fetchedTasks = await repository.todayTasks();
      tasks.assignAll(fetchedTasks);
    } catch (error) {
      EasyLoading.showToast(error.toString());
    } finally {
      loading.value = false;
      _requestingTasks = false;
    }
  }

  /// 查看全部任务，复用通用任务列表二级页。
  Future<void> onViewAllTasks() async {
    await onOpenTasks(TaskFilter.all);
  }

  /// 按 [filter] 打开同一个任务列表页，避免为三个入口重复实现界面。
  Future<void> onOpenTasks(TaskFilter filter) async {
    await Get.toNamed(GetRouter.tasks, arguments: filter);
  }

  /// 打开团队列表，替代原 Worker 应用内部 TabBar 的团队入口。
  Future<void> onOpenTeams() async {
    await Get.toNamed(GetRouter.teams);
  }

  /// 打开任务详情二级页，并传递当前列表中的完整任务快照。
  void onOpenTask(TaskItem task) {
    Get.toNamed(GetRouter.taskDetail, arguments: task);
  }

  /// 打开通知中心，并在返回首页后静默刷新未处理通知数量。
  Future<void> onOpenNotifications() async {
    await Get.toNamed(GetRouter.notifications);
    await load();
  }

  /// 将首页任务标记为已完成，成功后从今日待办中移除。
  Future<void> onCompleteTask(TaskItem task, {String note = ''}) async {
    await _updateTaskStatus(
      task: task,
      update: (taskId) => repository.completeTask(taskId, note: note),
      successMessage: S.current.taskActionCompletedSuccess,
    );
  }

  /// 将首页任务标记为已延后，成功后从今日待办中移除。
  Future<void> onPostponeTask(TaskItem task, {String note = ''}) async {
    await _updateTaskStatus(
      task: task,
      update: (taskId) => repository.postponeTask(taskId, note: note),
      successMessage: S.current.taskActionPostponedSuccess,
    );
  }

  /// 统一处理首页快捷状态更新、加载反馈和列表移除逻辑。
  Future<void> _updateTaskStatus({
    required TaskItem task,
    required Future<TaskItem> Function(String taskId) update,
    required String successMessage,
  }) async {
    if (task.id.isEmpty || !_updatingTaskIds.add(task.id)) {
      return;
    }

    EasyLoading.show(status: S.current.taskActionUpdating);

    try {
      await update(task.id);
      tasks.removeWhere((item) => item.id == task.id);
      // 状态变更后重新读取服务端汇总，避免多个统计字段只做局部猜测。
      await load();

      EasyLoading.showSuccess(successMessage);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      _updatingTaskIds.remove(task.id);
    }
  }

  /// 释放外层滚动控制器，避免页面销毁后继续持有滚动位置资源。
  @override
  void onClose() {
    super.onClose();
  }
}
