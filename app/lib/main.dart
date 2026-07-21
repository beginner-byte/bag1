import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// 提供 Flutter 内置组件的本地化文案，例如 Material、Widgets 和 Cupertino。
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/app.bindings.dart';
import 'package:worker/app/route/pages.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/app/theme/app.theme.dart';
import 'package:worker/core/service/settings.service.dart';
// 提供应用生成的多语言代理和支持的语言列表。
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 在创建界面前恢复应用设置，避免首屏语言出现短暂切换。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsService.initialization();
  Get.put(settings, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 构建应用根组件，并使用 [context] 绑定当前组件树的主题与本地化环境。
  ///
  /// 返回包含路由、主题及多语言代理配置的应用组件；构建时只读取已初始化的设置服务。
  @override
  Widget build(BuildContext context) {
    // 设置服务在 runApp 前完成初始化，此处可以直接读取首屏语言。
    final settings = Get.find<SettingsService>();

    return ScreenUtilInit(
      // 保持应用现有的 UI 适配基准尺寸。
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        initialBinding: AppBinding(),
        initialRoute: GetRouter.splash,
        getPages: GetPages.pages,
        // 全局点击空白区域时释放输入焦点，统一处理键盘收起行为。
        builder: builder,
        // 使用应用统一的浅色主题，保证页面和组件风格一致。
        theme: AppTheme.light,
        // 深色主题由应用设置切换，未指定时跟随设备明暗模式。
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        // null 表示跟随系统，明确语言则使用用户保存的偏好。
        locale: settings.initialLocale,
        // 设备语言不支持时，默认回退到中文。
        fallbackLocale: const Locale('zh'),
        // 注册应用文案和 Flutter 内置组件文案的多语言代理。
        localizationsDelegates: const [
          S.delegate,
          // 根据应用当前语言为国家选择器提供本地化国家名称。
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 使用根据 ARB 文件生成的语言支持列表。
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
  }

  Widget builder(BuildContext context, Widget? child) {
    final builder = EasyLoading.init(
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    return builder(context, child);
  }
}
