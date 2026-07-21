import 'package:get/get.dart';
import 'package:worker/core/model/settings/notification.preferences.model.dart';
import 'package:worker/core/network/auth/core/network.service.dart';
import 'package:worker/core/network/settings/notification.preferences.target.dart';

/// 应用设置仓库，封装需要跨设备同步的账号偏好请求。
final class SettingsRepository {
  /// 获取当前登录账号保存的通知偏好。
  Future<NotificationPreferences> notificationPreferences() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      NotificationPreferencesTarget(),
      decoder: NotificationPreferences.fromJson,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '获取通知设置失败';
  }

  /// 保存完整通知偏好，并返回服务端最终状态。
  ///
  /// [preferences] 是用户本次调整后的完整开关集合。
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      UpdateNotificationPreferencesTarget(preferences),
      decoder: NotificationPreferences.fromJson,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '更新通知设置失败';
  }
}
