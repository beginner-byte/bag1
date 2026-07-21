import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// 应用支持的语言偏好，system 表示始终跟随设备语言。
enum AppLanguage { system, simplifiedChinese, english }

/// 应用支持的主题偏好，system 表示跟随设备明暗模式。
enum AppThemePreference { system, light, dark }

/// 应用设置服务，负责恢复、保存并应用与账号无关的本地偏好。
final class SettingsService extends GetxService {
  SettingsService._();

  /// 语言偏好的安全存储 key，使用独立命名空间避免和登录态冲突。
  static const _languageKey = 'settings.language';

  /// 主题偏好的安全存储 key。
  static const _themeKey = 'settings.theme';

  /// 复用项目已有安全存储能力，避免为少量设置增加新的依赖。
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 当前语言偏好，设置页通过响应式值即时更新选中状态。
  final Rx<AppLanguage> language = AppLanguage.system.obs;

  /// 当前主题偏好，设置页通过响应式值即时更新选中状态。
  final Rx<AppThemePreference> theme = AppThemePreference.system.obs;

  /// 创建并恢复持久化设置，确保首屏使用正确语言和默认值。
  static Future<SettingsService> initialization() async {
    final service = SettingsService._();
    await service._restore();
    return service;
  }

  /// GetMaterialApp 的初始语言；返回 null 时由 Flutter 自动跟随设备。
  Locale? get initialLocale {
    return switch (language.value) {
      AppLanguage.system => null,
      AppLanguage.simplifiedChinese => const Locale('zh'),
      AppLanguage.english => const Locale('en'),
    };
  }

  /// 将主题偏好转换为 GetMaterialApp 使用的 ThemeMode。
  ThemeMode get themeMode {
    return switch (theme.value) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  /// 保存并立即应用新的语言偏好。
  ///
  /// [value] 是用户选择的系统语言、简体中文或英文。
  Future<void> setLanguage(AppLanguage value) async {
    language.value = value;
    await _storage.write(key: _languageKey, value: value.name);

    // Get.updateLocale 需要明确 Locale；系统模式使用设备当前语言即时刷新。
    final locale = switch (value) {
      AppLanguage.system => Get.deviceLocale ?? const Locale('zh'),
      AppLanguage.simplifiedChinese => const Locale('zh'),
      AppLanguage.english => const Locale('en'),
    };
    Get.updateLocale(locale);
  }

  /// 保存并立即应用新的主题偏好。
  ///
  /// [value] 是跟随系统、浅色或深色模式。
  Future<void> setTheme(AppThemePreference value) async {
    theme.value = value;
    await _storage.write(key: _themeKey, value: value.name);
    Get.changeThemeMode(themeMode);
  }

  /// 统计临时目录中的缓存文件总字节数，不读取用户文档和登录态。
  Future<int> calculateCacheSize() async {
    final directory = await getTemporaryDirectory();

    if (!await directory.exists()) {
      return 0;
    }

    var totalBytes = 0;

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }

    return totalBytes;
  }

  /// 清空系统临时目录内容，但保留 Mock 账号文件、语言、主题和登录态。
  Future<void> clearTemporaryCache() async {
    final directory = await getTemporaryDirectory();

    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      await entity.delete(recursive: true);
    }
  }

  /// 从安全存储恢复枚举值，未知或旧版本值安全回退到默认设置。
  Future<void> _restore() async {
    final storedLanguage = await _storage.read(key: _languageKey);
    final storedTheme = await _storage.read(key: _themeKey);

    language.value =
        AppLanguage.values.firstWhereOrNull(
          (value) => value.name == storedLanguage,
        ) ??
        AppLanguage.system;
    theme.value =
        AppThemePreference.values.firstWhereOrNull(
          (value) => value.name == storedTheme,
        ) ??
        AppThemePreference.system;
  }
}
