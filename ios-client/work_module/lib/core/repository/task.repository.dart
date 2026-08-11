import 'package:get/get.dart';
import 'package:work_module/core/model/task/summary.model.dart';
import 'package:work_module/core/model/task/task.filter.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/core/network/core/network.service.dart';
import 'package:work_module/core/network/task/create.task.target.dart';
import 'package:work_module/core/network/task/add.task.assignees.target.dart';
import 'package:work_module/core/network/task/bind.task.group.target.dart';
import 'package:work_module/core/network/task/fail.task.group.target.dart';
import 'package:work_module/core/network/task/delete.task.target.dart';
import 'package:work_module/core/network/task/dissolved.task.group.target.dart';
import 'package:work_module/core/network/task/summary.target.dart';
import 'package:work_module/core/network/task/tasks.target.dart';
import 'package:work_module/core/network/task/today.tasks.target.dart';
import 'package:work_module/core/network/task/update.task.status.target.dart';

/// 任务数据仓库，统一封装任务列表和任务汇总的获取逻辑。
final class TaskRepository {
  /// 为等待成员的任务追加负责人，并返回服务端最新群状态。
  Future<TaskItem> addAssignees({
    required String taskId,
    required List<String> assigneeIds,
  }) async {
    final response = await Get.find<NetworkService>().fetch<TaskItem>(
      AddTaskAssigneesTarget(taskId: taskId, assigneeIds: assigneeIds),
      decoder: (data) => TaskItem.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '添加任务负责人失败';
  }

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

  /// 将 CandyTalk 原生建群结果绑定到指定任务，并返回最新任务快照。
  Future<TaskItem> bindTaskGroup({
    required String taskId,
    required String groupId,
    required String operationId,
    required List<String> memberCandyUserUids,
  }) async {
    final response = await Get.find<NetworkService>().fetch<TaskItem>(
      BindTaskGroupTarget(
        taskId: taskId,
        groupId: groupId,
        operationId: operationId,
        memberCandyUserUids: memberCandyUserUids,
      ),
      decoder: (data) => TaskItem.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '绑定任务群聊失败';
  }

  /// 记录建群失败并返回可重试的任务快照。
  Future<TaskItem> failTaskGroup({
    required String taskId,
    required String operationId,
    required String message,
  }) async {
    final response = await Get.find<NetworkService>().fetch<TaskItem>(
      FailTaskGroupTarget(
        taskId: taskId,
        operationId: operationId,
        message: message,
      ),
      decoder: (data) => TaskItem.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '记录群聊创建失败';
  }

  /// 开始删除任务，返回是否需要先通过原生 SDK 解散关联群聊。
  Future<TaskDeleteCommand> beginDeleteTask(String taskId) async {
    final response = await Get.find<NetworkService>().fetch<TaskDeleteCommand>(
      DeleteTaskTarget(taskId),
      decoder: (data) =>
          TaskDeleteCommand.fromJson(data as Map<String, dynamic>),
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '删除任务失败';
  }

  /// 原生群解散成功后完成 Worker 任务逻辑删除。
  Future<void> completeTaskGroupDissolution({
    required String groupId,
    required String operationId,
  }) async {
    final response = await Get.find<NetworkService>().fetch<Object?>(
      DissolvedTaskGroupTarget(groupId: groupId, operationId: operationId),
      decoder: (data) => data,
    );
    if (response.code != 0) {
      throw response.message ?? '完成任务删除失败';
    }
  }

  /// 将指定任务标记为已完成，并返回服务端更新后的任务快照。
  Future<TaskItem> completeTask(String taskId, {String note = ''}) {
    return _updateTaskStatus(taskId: taskId, status: 'completed', note: note);
  }

  /// 将指定任务标记为已延后，并返回服务端更新后的任务快照。
  Future<TaskItem> postponeTask(String taskId, {String note = ''}) {
    return _updateTaskStatus(taskId: taskId, status: 'postponed', note: note);
  }

  /// 使用宿主注入的 Worker 会话获取今日待办列表。
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

  /// 使用宿主注入的 Worker 会话获取顶部统计卡片数量。
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

/// Worker 返回的两阶段任务删除命令。
final class TaskDeleteCommand {
  /// 从服务端 JSON 构建删除命令。
  const TaskDeleteCommand({
    required this.action,
    required this.groupId,
    required this.operationId,
  });

  factory TaskDeleteCommand.fromJson(Map<String, dynamic> json) {
    return TaskDeleteCommand(
      action: json['action']?.toString() ?? 'none',
      groupId: json['groupId']?.toString() ?? '',
      operationId: json['operationId']?.toString() ?? '',
    );
  }

  final String action;
  final String groupId;
  final String operationId;
}
