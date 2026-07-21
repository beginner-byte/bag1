import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/core/model/settings/notification.preferences.model.dart';
import 'package:worker/core/repository/settings.repository.dart';
import 'package:worker/core/service/settings.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 应用设置控制器，协调服务端通知偏好与本地语言、主题和缓存状态。
class AppSettingsController extends GetxController {
  /// 全局设置服务，负责语言、主题以及临时缓存操作。
  final SettingsService settings = Get.find<SettingsService>();

  /// 设置仓库，负责同步当前账号的通知偏好。
  final SettingsRepository repository = SettingsRepository();

  /// 当前通知偏好，服务端请求完成后驱动四个通知开关刷新。
  final Rx<NotificationPreferences> notificationPreferences =
      NotificationPreferences.defaults.obs;

  /// 是否正在首次加载通知偏好。
  final RxBool notificationLoading = true.obs;

  /// 是否正在保存通知偏好，用于防止快速点击造成请求覆盖。
  final RxBool notificationSaving = false.obs;

  /// 当前临时缓存字节数。
  final RxInt cacheBytes = 0.obs;

  /// 是否正在统计缓存大小。
  final RxBool cacheLoading = true.obs;

  /// 是否正在清理缓存，避免用户重复触发删除操作。
  final RxBool cacheClearing = false.obs;

  /// 当前语言选项，供页面响应式展示选中状态。
  AppLanguage get language => settings.language.value;

  /// 当前主题选项。
  AppThemePreference get theme => settings.theme.value;

  /// 页面初始化时并行加载服务端通知偏好和本地缓存大小。
  @override
  void onInit() {
    super.onInit();
    loadNotificationPreferences();
    loadCacheSize();
  }

  /// 从服务端加载当前账号通知偏好，失败时保留安全默认值。
  Future<void> loadNotificationPreferences() async {
    notificationLoading.value = true;

    try {
      notificationPreferences.value = await repository
          .notificationPreferences();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      notificationLoading.value = false;
    }
  }

  /// 保存完整通知偏好；失败时回滚旧状态，避免界面与服务端不一致。
  ///
  /// [value] 是用户本次调整后的四项通知状态。
  Future<void> updateNotificationPreferences(
    NotificationPreferences value,
  ) async {
    if (notificationSaving.value) {
      return;
    }

    final previousValue = notificationPreferences.value;
    notificationPreferences.value = value;
    notificationSaving.value = true;

    try {
      notificationPreferences.value = await repository
          .updateNotificationPreferences(value);
    } catch (error) {
      notificationPreferences.value = previousValue;
      EasyLoading.showError(error.toString());
    } finally {
      notificationSaving.value = false;
    }
  }

  /// 保存语言偏好并立即刷新全局本地化内容。
  ///
  /// [value] 是用户选择的新语言模式。
  Future<void> selectLanguage(AppLanguage value) async {
    try {
      await settings.setLanguage(value);
    } catch (error) {
      EasyLoading.showError(error.toString());
    }
  }

  /// 保存主题偏好并立即刷新全局 ThemeMode。
  ///
  /// [value] 是跟随系统、浅色或深色模式。
  Future<void> selectTheme(AppThemePreference value) async {
    try {
      await settings.setTheme(value);
    } catch (error) {
      EasyLoading.showError(error.toString());
    }
  }

  /// 重新统计临时缓存大小，页面首次进入和清理后都会调用。
  Future<void> loadCacheSize() async {
    cacheLoading.value = true;

    try {
      cacheBytes.value = await settings.calculateCacheSize();
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      cacheLoading.value = false;
    }
  }

  /// 清空临时缓存并刷新展示大小，不影响账号和用户设置。
  Future<void> clearCache() async {
    if (cacheClearing.value) {
      return;
    }

    cacheClearing.value = true;

    try {
      await settings.clearTemporaryCache();
      cacheBytes.value = 0;
      EasyLoading.showSuccess(S.current.appSettingsCacheCleared);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      cacheClearing.value = false;
    }
  }

  /// 将缓存字节数格式化为适合设置项展示的 B、KB 或 MB。
  String get cacheSizeLabel {
    final bytes = cacheBytes.value;

    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
