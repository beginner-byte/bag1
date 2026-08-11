import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/core/repository/task.repository.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/service/work_session_service.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 创建任务页面控制器，管理表单状态、负责人选择和提交生命周期。
class CreateTaskController extends GetxController {
  /// 创建页面状态；[team] 为空表示路由参数无效。
  CreateTaskController({required this.team});

  /// 当前任务所属团队，包含创建页面可选择的成员快照。
  final TeamItem? team;

  /// 任务仓库，负责提交创建请求并解析任务数据。
  final TaskRepository repository = TaskRepository();

  /// 当前登录用户服务，用于阻止非团队创建者提交。
  final WorkSessionService sessionService = Get.find<WorkSessionService>();

  /// iOS 原生能力桥，负责只展示当前用户 CandyTalk 好友并静默创建群聊。
  final WorkHostBridge hostBridge = Get.find<WorkHostBridge>();

  /// 任务名称输入控制器，生命周期跟随创建任务路由。
  final title = TextEditingController();

  /// 任务描述输入控制器，生命周期跟随创建任务路由。
  final description = TextEditingController();

  /// 可选的任务开始时间，通过日期时间滚轮一次性选择。
  final Rxn<DateTime> selectedStartTime = Rxn<DateTime>();

  /// 必选的任务结束时间，通过日期时间滚轮一次性选择。
  final Rxn<DateTime> selectedEndTime = Rxn<DateTime>();

  /// 已选择的负责人 ID，支持多选并驱动选择态刷新。
  final RxList<String> selectedAssigneeIds = <String>[].obs;

  /// 是否正在提交任务，用于阻止重复请求并驱动按钮加载状态。
  final RxBool submitting = false.obs;

  /// 当前用户是否为团队创建者。
  bool get isCreator {
    final currentTeam = team;
    final userId = sessionService.workerUserId;

    return currentTeam != null &&
        userId.isNotEmpty &&
        currentTeam.creator.id == userId;
  }

  /// 更新可选开始时间；新开始时间晚于已有结束时间时清空无效结束时间。
  void updateStartTime(DateTime value) {
    selectedStartTime.value = _toMinute(value);
    final endTime = selectedEndTime.value;

    if (endTime != null && !endTime.isAfter(selectedStartTime.value!)) {
      selectedEndTime.value = null;
    }
  }

  /// 清除可选开始时间，保留用户已经选择的结束时间。
  void clearStartTime() {
    selectedStartTime.value = null;
  }

  /// 更新必选结束时间，仅保留到分钟精度。
  void updateEndTime(DateTime value) {
    selectedEndTime.value = _toMinute(value);
  }

  /// 更新单个负责人的选择状态。
  void toggleAssignee(String memberId, bool selected) {
    if (selected) {
      if (!selectedAssigneeIds.contains(memberId)) {
        selectedAssigneeIds.add(memberId);
      }
      return;
    }

    selectedAssigneeIds.remove(memberId);
  }

  /// 打开原生 CandyTalk 好友选择器，并把返回 UID 映射回稳定 Worker 成员 ID。
  Future<void> selectAssignees() async {
    final currentTeam = team;
    if (currentTeam == null) {
      return;
    }
    final selectableMembers = currentTeam.members
        .where((member) => member.candyUserUid.isNotEmpty)
        .toList(growable: false);
    final selectedCandyUIDs = await hostBridge.selectTaskFriends(
      selectableMembers
          .map((member) => member.candyUserUid)
          .toList(growable: false),
    );
    final selectedSet = selectedCandyUIDs.toSet();
    selectedAssigneeIds.assignAll(
      selectableMembers
          .where((member) => selectedSet.contains(member.candyUserUid))
          .map((member) => member.id),
    );
  }

  /// 当前原生选择结果对应的团队成员，用于页面只读展示。
  List<TeamMemberSummary> get selectedAssignees {
    final selected = selectedAssigneeIds.toSet();
    return team?.members
            .where((member) => selected.contains(member.id))
            .toList(growable: false) ??
        const [];
  }

  /// 校验并创建任务，成功后将完整任务返回团队详情页。
  Future<void> onCreateTask() async {
    final currentTeam = team;
    final normalizedTitle = title.text.trim();
    final normalizedDescription = description.text.trim();
    final startTime = selectedStartTime.value;
    final endTime = selectedEndTime.value;

    if (!isCreator || currentTeam == null) {
      return;
    }

    if (normalizedTitle.isEmpty ||
        normalizedDescription.isEmpty ||
        endTime == null ||
        selectedAssigneeIds.isEmpty) {
      EasyLoading.showToast(S.current.teamDetailTaskRequired);
      return;
    }

    final now = _toMinute(DateTime.now());

    if (startTime != null && startTime.isBefore(now)) {
      EasyLoading.showToast(S.current.teamDetailTaskStartPastTime);
      return;
    }

    if (endTime.isBefore(now)) {
      EasyLoading.showToast(S.current.teamDetailTaskPastTime);
      return;
    }

    if (startTime != null && !endTime.isAfter(startTime)) {
      EasyLoading.showToast(S.current.teamDetailTaskTimeRangeInvalid);
      return;
    }

    if (submitting.value) {
      return;
    }

    submitting.value = true;

    try {
      var task = await repository.createTask(
        teamId: currentTeam.id,
        title: normalizedTitle,
        description: normalizedDescription,
        time: _formatTimeRange(startTime: startTime, endTime: endTime),
        assigneeIds: selectedAssigneeIds.toList(growable: false),
      );

      if (task.groupAction == 'create' && task.groupOperationId.isNotEmpty) {
        late final TaskGroupCreationResult creation;
        try {
          creation = await hostBridge.createTaskGroup(
            title: task.title,
            members: task.assignees
                .map(
                  (member) => {
                    'candyUserUid': member.candyUserUid,
                    'name': member.name,
                  },
                )
                .where((member) => member['candyUserUid']!.isNotEmpty)
                .toList(growable: false),
          );
        } catch (error) {
          await repository.failTaskGroup(
            taskId: task.id,
            operationId: task.groupOperationId,
            message: error.toString(),
          );
          rethrow;
        }
        // Binding is intentionally outside the SDK failure handler: the group already exists,
        // so a network error must never mark it for creation retry and produce a duplicate group.
        task = await repository.bindTaskGroup(
          taskId: task.id,
          groupId: creation.groupId,
          operationId: task.groupOperationId,
          memberCandyUserUids: creation.memberCandyUserUids,
        );
      }

      EasyLoading.showSuccess(S.current.teamDetailTaskCreated);
      Get.back(result: task);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
    }
  }

  /// 将分钟精度的任务时间拼装为当前接口兼容的单个时间字符串。
  String _formatTimeRange({DateTime? startTime, required DateTime endTime}) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final formattedEndTime = formatter.format(endTime);

    if (startTime == null) {
      return formattedEndTime;
    }

    return '${formatter.format(startTime)} ~ $formattedEndTime';
  }

  /// 去除秒和毫秒，保证滚轮结果、校验和提交格式使用相同精度。
  DateTime _toMinute(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
  }

  /// 页面路由销毁后统一释放输入资源，避免退场动画期间提前释放。
  @override
  void onClose() {
    title.dispose();
    description.dispose();
    super.onClose();
  }
}
