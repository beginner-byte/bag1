import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/features/main/main.controller.dart';

void main() {
  test('main shell switches among the three Worker tabs', () {
    final controller = MainController();

    controller.onTabChanged(2);

    expect(controller.index.value, 2);
  });

  test('main shell ignores an out-of-range tab index', () {
    final controller = MainController();

    controller.onTabChanged(3);

    expect(controller.index.value, 0);
  });
}
