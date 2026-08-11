import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/model/task/task.item.model.dart';
import 'package:work_module/core/repository/task.repository.dart';
import 'package:work_module/core/repository/team.repository.dart';
import 'package:work_module/core/service/work_session_service.dart';

/// 管理任务详情快照和等待成员任务的负责人追加流程。
final class TaskDetailController extends GetxController {
  final TaskRepository taskRepository = TaskRepository();
  final TeamRepository teamRepository = TeamRepository();
  final WorkHostBridge bridge = Get.find<WorkHostBridge>();
  final Rxn<TaskItem> task = Rxn<TaskItem>();

  bool get canAddAssignees {
    final value = task.value;
    return value != null &&
        value.groupAction == 'waiting_members' &&
        value.creatorId == Get.find<WorkSessionService>().workerUserId;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is TaskItem) task.value = Get.arguments as TaskItem;
  }

  /// 选择团队内 CandyTalk 好友，追加负责人并在达到三人后静默建群。
  Future<void> addAssignees() async {
    final current = task.value;
    if (!canAddAssignees || current == null) return;
    try {
      EasyLoading.show();
      final teams = await teamRepository.teams();
      final team = teams.firstWhere((item) => item.id == current.teamId);
      final existing = current.assignees.map((item) => item.id).toSet();
      final candidates = team.members
          .where(
            (item) =>
                item.candyUserUid.isNotEmpty && !existing.contains(item.id),
          )
          .toList(growable: false);
      EasyLoading.dismiss();
      final selectedUIDs = await bridge.selectTaskFriends(
        candidates.map((item) => item.candyUserUid).toList(growable: false),
      );
      if (selectedUIDs.isEmpty) return;
      EasyLoading.show();
      var updated = await taskRepository.addAssignees(
        taskId: current.id,
        assigneeIds: candidates
            .where((item) => selectedUIDs.contains(item.candyUserUid))
            .map((item) => item.id)
            .toList(growable: false),
      );
      if (updated.groupAction == 'create' &&
          updated.groupOperationId.isNotEmpty) {
        late final TaskGroupCreationResult creation;
        try {
          creation = await bridge.createTaskGroup(
            title: updated.title,
            members: updated.assignees
                .map(
                  (item) => {
                    'candyUserUid': item.candyUserUid,
                    'name': item.name,
                  },
                )
                .toList(growable: false),
          );
        } catch (error) {
          task.value = await taskRepository.failTaskGroup(
            taskId: updated.id,
            operationId: updated.groupOperationId,
            message: error.toString(),
          );
          rethrow;
        }
        updated = await taskRepository.bindTaskGroup(
          taskId: updated.id,
          groupId: creation.groupId,
          operationId: updated.groupOperationId,
          memberCandyUserUids: creation.memberCandyUserUids,
        );
      }
      task.value = updated;
      EasyLoading.dismiss();
      await Get.offNamed<void>(GetRouter.taskDetail, arguments: updated);
    } catch (error) {
      EasyLoading.showError(error.toString());
    }
  }
}
