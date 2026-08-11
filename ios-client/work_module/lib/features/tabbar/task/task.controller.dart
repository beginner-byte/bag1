import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/core/repository/task.repository.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 可复用任务列表控制器，根据路由参数加载对应筛选数据。
class TaskController extends GetxController {
  /// 任务仓库，用于访问统一的任务列表接口。
  final TaskRepository repository = TaskRepository();

  /// 当前页面的筛选条件，无有效路由参数时默认显示全部任务。
  late final TaskFilter filter;

  /// 当前筛选条件下的任务列表。
  final RxList<TaskItem> tasks = <TaskItem>[].obs;

  /// 列表首次加载和刷新期间的请求状态。
  final RxBool loading = false.obs;

  /// 读取路由传入的筛选条件并加载首页数据。
  @override
  void onInit() {
    super.onInit();
    filter = Get.arguments is TaskFilter
        ? Get.arguments as TaskFilter
        : TaskFilter.all;
    loadTasks();
  }

  /// 根据当前筛选返回页面标题，复用 Dashboard 已有多语言文案。
  String get title {
    return switch (filter) {
      TaskFilter.all => S.current.dashboardMyTasks,
      TaskFilter.dueToday => S.current.dashboardDueToday,
      TaskFilter.inProgress => S.current.dashboardInProgress,
    };
  }

  /// 请求当前筛选的任务，重复刷新时直接忽略以保护列表状态。
  Future<void> loadTasks() async {
    if (loading.value) {
      return;
    }

    loading.value = true;

    try {
      final fetchedTasks = await repository.tasks(filter);
      tasks.assignAll(fetchedTasks);
    } catch (error) {
      EasyLoading.showToast(error.toString());
    } finally {
      loading.value = false;
    }
  }

  /// 打开任务详情二级页，并传递当前列表中的完整任务快照。
  void onTaskPressed(TaskItem task) {
    Get.toNamed(GetRouter.taskDetail, arguments: task);
  }
}
