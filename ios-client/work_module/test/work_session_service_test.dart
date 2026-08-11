import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/core/service/work_session_service.dart';

void main() {
  test('session only contains identity injected by ios-client', () {
    final service = WorkSessionService(
      session: 'ios-session',
      workerUserId: 'worker-user-1',
    );

    expect(service.session, 'ios-session');
    expect(service.workerUserId, 'worker-user-1');
    expect(service.isValid, isTrue);

    service.clear();

    expect(service.session, isEmpty);
    expect(service.workerUserId, isEmpty);
    expect(service.isValid, isFalse);
  });
}
