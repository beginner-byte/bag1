import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/app/route/pages.dart';
import 'package:work_module/app/route/router.dart';

void main() {
  test('all module routes stay under the work namespace', () {
    final routes = WorkModulePages.pages.map((page) => page.name).toList();

    expect(routes, isNotEmpty);
    expect(routes.every((route) => route.startsWith('/work')), isTrue);
    expect(routes.where((route) => route.contains('auth')), isEmpty);
    expect(routes.where((route) => route.contains('login')), isEmpty);
    expect(routes.where((route) => route.contains('register')), isEmpty);
  });

  test('every engine route starts the complete Worker main shell', () {
    expect(GetRouter.normalizeRootRoute(GetRouter.work), GetRouter.main);
    expect(GetRouter.normalizeRootRoute(GetRouter.teams), GetRouter.main);
    expect(GetRouter.normalizeRootRoute('/'), GetRouter.main);
    expect(GetRouter.normalizeRootRoute('/work/tasks'), GetRouter.main);
    expect(GetRouter.normalizeRootRoute(null), GetRouter.main);
  });
}
