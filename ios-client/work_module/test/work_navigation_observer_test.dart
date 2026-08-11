import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/app/route/router.dart';
import 'package:work_module/core/host/work_navigation_observer.dart';

void main() {
  test(
    'work and teams roots show host tab bar while child routes hide it',
    () async {
      final states = <bool>[];
      final observer = WorkNavigationObserver((hidden) async {
        states.add(hidden);
      });
      final rootRoute = PageRouteBuilder<void>(
        settings: const RouteSettings(name: GetRouter.work),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SizedBox(),
      );
      final childRoute = PageRouteBuilder<void>(
        settings: const RouteSettings(name: GetRouter.tasks),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SizedBox(),
      );
      final teamsRoute = PageRouteBuilder<void>(
        settings: const RouteSettings(name: GetRouter.teams),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SizedBox(),
      );

      observer.didPush(rootRoute, null);
      observer.didReplace(newRoute: teamsRoute, oldRoute: rootRoute);
      observer.didPush(childRoute, rootRoute);
      observer.didPop(childRoute, teamsRoute);
      await Future<void>.delayed(Duration.zero);

      expect(states, [false, true, false]);
    },
  );

  test('duplicate route callbacks do not resend the same state', () async {
    final states = <bool>[];
    final observer = WorkNavigationObserver((hidden) async {
      states.add(hidden);
    });
    final rootRoute = PageRouteBuilder<void>(
      settings: const RouteSettings(name: GetRouter.work),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
    );

    observer.didPush(rootRoute, null);
    observer.didReplace(newRoute: rootRoute, oldRoute: rootRoute);
    await Future<void>.delayed(Duration.zero);

    expect(states, [false]);
  });

  test(
    'temporary null route does not hide tab bar during root switch',
    () async {
      final states = <bool>[];
      final observer = WorkNavigationObserver((hidden) async {
        states.add(hidden);
      });
      final workRoute = PageRouteBuilder<void>(
        settings: const RouteSettings(name: GetRouter.work),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SizedBox(),
      );
      final teamsRoute = PageRouteBuilder<void>(
        settings: const RouteSettings(name: GetRouter.teams),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SizedBox(),
      );

      observer.didPush(workRoute, null);
      observer.didPush(teamsRoute, workRoute);
      observer.didRemove(workRoute, null);
      await Future<void>.delayed(Duration.zero);

      expect(states, [false]);
    },
  );
}
