import 'package:get/get.dart';
import 'package:worker/core/model/notification/notification.item.model.dart';
import 'package:worker/core/network/auth/core/network.service.dart';
import 'package:worker/core/network/notification/handle.notification.target.dart';
import 'package:worker/core/network/notification/notifications.target.dart';

/// 通知仓库，隔离页面状态与通知接口解析细节。
final class NotificationRepository {
  /// 获取当前账号最近的待处理和已处理通知。
  Future<List<WorkerNotificationItem>> notifications() async {
    // network 复用全局认证头和统一错误解析。
    final network = Get.find<NetworkService>();
    // response 只在业务 code 为 0 时向页面暴露解析后的列表。
    final response = await network.fetch<List<WorkerNotificationItem>>(
      NotificationsTarget(),
      decoder: _decodeNotifications,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取通知失败';
  }

  /// 对 [notificationId] 提交 [action]，成功响应不包含额外业务数据。
  Future<void> handle({
    required String notificationId,
    required String action,
  }) async {
    // network 负责附加当前会话，防止页面直接接触认证细节。
    final network = Get.find<NetworkService>();
    // response 的 data 为空属于正常命令响应，处理结果以 code 为准。
    final response = await network.fetch<void>(
      HandleNotificationTarget(notificationId: notificationId, action: action),
    );

    if (response.code == 0) {
      return;
    }

    throw response.message ?? '处理通知失败';
  }

  /// 将 [data] 的接口数组解析为通知模型，异常结构安全回退为空列表。
  List<WorkerNotificationItem> _decodeNotifications(dynamic data) {
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(WorkerNotificationItem.fromJson)
        .toList(growable: false);
  }
}
