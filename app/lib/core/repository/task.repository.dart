import 'package:get/get.dart';
import 'package:worker/core/model/task/summary.model.dart';
import 'package:worker/core/model/task/task.filter.dart';
import 'package:worker/core/model/task/task.item.model.dart';
import 'package:worker/core/network/auth/core/network.service.dart';
import 'package:worker/core/network/task/create.task.target.dart';
import 'package:worker/core/network/task/summary.target.dart';
import 'package:worker/core/network/task/tasks.target.dart';
import 'package:worker/core/network/task/today.tasks.target.dart';
import 'package:worker/core/network/task/update.task.status.target.dart';

/// 任务数据仓库，统一封装任务列表和任务汇总的获取逻辑。
final class TaskRepository {
  /// 根据 [filter] 获取任务列表，三个 Dashboard 入口共用同一套解析逻辑。
  Future<List<TaskItem>> tasks(TaskFilter filter, {String teamId = ''}) async {
    final net = Get.find<NetworkService>();

    final response = await net.fetch<List<TaskItem>>(
      TasksTarget(filter, teamId: teamId),
      decoder: _decodeTaskItems,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取任务列表失败';
  }

  /// 获取指定团队的全部细分任务。
  Future<List<TaskItem>> teamTasks(String teamId) {
    return tasks(TaskFilter.all, teamId: teamId);
  }

  /// 为指定团队创建任务，并返回服务端生成的完整任务信息。
  Future<TaskItem> createTask({
    required String teamId,
    required String title,
    required String description,
    required String time,
    required List<String> assigneeIds,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<TaskItem>(
      CreateTaskTarget(
        teamId: teamId,
        title: title,
        description: description,
        time: time,
        assigneeIds: assigneeIds,
      ),
      decoder: (data) => TaskItem.fromJson(data as Map<String, dynamic>),
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '创建任务失败';
  }

  /// 将指定任务标记为已完成，并返回服务端更新后的任务快照。
  Future<TaskItem> completeTask(String taskId, {String note = ''}) {
    return _updateTaskStatus(taskId: taskId, status: 'completed', note: note);
  }

  /// 将指定任务标记为已延后，并返回服务端更新后的任务快照。
  Future<TaskItem> postponeTask(String taskId, {String note = ''}) {
    return _updateTaskStatus(taskId: taskId, status: 'postponed', note: note);
  }

  /// 获取今日待办列表，当前由 mock 后端拦截 TodayTasksTarget 并返回数据。
  Future<List<TaskItem>> todayTasks() async {
    final net = Get.find<NetworkService>();

    final response = await net.fetch<List<TaskItem>>(
      TodayTasksTarget(),
      decoder: _decodeTaskItems,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取今日待办失败';
  }

  /// 获取任务汇总数据，当前由 mock 后端返回顶部统计卡片数量。
  Future<Summary> summary() async {
    final net = Get.find<NetworkService>();

    final response = await net.fetch<Summary>(
      SummaryTarget(),
      decoder: (data) {
        if (data is! Map<String, dynamic>) {
          return const Summary(
            myTaskCount: 0,
            dueTodayCount: 0,
            inProgressCount: 0,
            unreadCount: 0,
          );
        }

        return Summary.fromJson(data);
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取工作台汇总失败';
  }

  /// 统一提交任务状态更新，避免完成和延后重复网络解析逻辑。
  Future<TaskItem> _updateTaskStatus({
    required String taskId,
    required String status,
    required String note,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<TaskItem>(
      UpdateTaskStatusTarget(taskId: taskId, status: status, note: note),
      decoder: (data) => TaskItem.fromJson(data as Map<String, dynamic>),
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '更新任务状态失败';
  }

  /// 统一解析任务数组，非列表数据安全回退为空集合。
  List<TaskItem> _decodeTaskItems(dynamic data) {
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(TaskItem.fromJson)
        .toList();
  }
}
