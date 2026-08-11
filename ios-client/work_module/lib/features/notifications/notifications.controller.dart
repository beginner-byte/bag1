import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:work_module/core/model/notification/notification.item.model.dart';
import 'package:work_module/core/repository/notification.repository.dart';
import 'package:work_module/features/tabbar/dashboard/dashboard.controller.dart';
import 'package:work_module/features/tabbar/teams/teams.controller.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 通知中心控制器，负责列表刷新、单条互斥处理和首页未读数同步。
class NotificationsController extends GetxController {
  /// 通知仓库，统一访问列表和处理接口。
  final NotificationRepository repository = NotificationRepository();

  /// 当前账号最近的通知，服务端已经按待处理优先和时间倒序排列。
  final RxList<WorkerNotificationItem> notifications =
      <WorkerNotificationItem>[].obs;

  /// 首次进入页面时的加载状态，普通刷新保留已有列表。
  final RxBool loading = true.obs;

  /// 正在提交动作的通知标识集合，只锁定用户当前操作的卡片。
  final RxSet<String> actingIds = <String>{}.obs;

  /// 页面准备完成后读取通知列表。
  @override
  void onReady() {
    super.onReady();
    loadNotifications();
  }

  /// 从服务端刷新通知；首次加载结束后不再清空或遮挡已有内容。
  ///
  /// 请求失败时保留已有列表并显示错误提示，不向调用方抛出异常。
  Future<void> loadNotifications() async {
    try {
      notifications.assignAll(await repository.notifications());
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      loading.value = false;
    }
  }

  /// 为 [notification] 提交 [action]，成功后更新卡片、首页计数及团队列表。
  ///
  /// 重复点击或已处理通知会直接返回；失败时保持原状态并显示错误提示。
  Future<void> handle(
    WorkerNotificationItem notification,
    String action,
  ) async {
    if (notification.status != WorkerNotificationStatus.pending ||
        notification.id.isEmpty ||
        !actingIds.add(notification.id)) {
      return;
    }

    try {
      await repository.handle(notificationId: notification.id, action: action);
      // index 指向当前列表中的同一通知，列表刷新导致项目消失时允许为 -1。
      final index = notifications.indexWhere(
        (item) => item.id == notification.id,
      );
      if (index >= 0) {
        notifications[index] = notification.copyWithStatus(
          _statusAfterAction(action),
        );
      }

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().load();
      }
      if (action == 'accept' && Get.isRegistered<TeamsController>()) {
        await Get.find<TeamsController>().loadTeams();
      }

      EasyLoading.showSuccess(S.current.notificationHandled);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      actingIds.remove(notification.id);
    }
  }

  /// 将服务端动作 [action] 映射为处理成功后的稳定展示状态。
  WorkerNotificationStatus _statusAfterAction(String action) {
    return switch (action) {
      'accept' => WorkerNotificationStatus.accepted,
      'confirm' => WorkerNotificationStatus.confirmed,
      'reject' => WorkerNotificationStatus.rejected,
      _ => WorkerNotificationStatus.unknown,
    };
  }
}
