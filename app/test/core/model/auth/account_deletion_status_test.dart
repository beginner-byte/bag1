import 'package:flutter_test/flutter_test.dart';
import 'package:worker/core/model/auth/account.deletion.status.dart';

/// 验证账号删除状态对有效预约和异常响应保持稳定解析。
void main() {
  test('parses a scheduled UTC deletion deadline', () {
    // status 模拟服务端返回的可撤销预约状态。
    final status = AccountDeletionStatus.fromJson({
      'scheduled': true,
      'scheduledAt': '2026-08-03T12:30:00Z',
    });

    expect(status.scheduled, isTrue);
    expect(status.scheduledAt, DateTime.utc(2026, 8, 3, 12, 30));
  });

  test('rejects a scheduled status without a valid deadline', () {
    // status 模拟字段不完整的响应，不能让页面展示不可撤销的错误期限。
    final status = AccountDeletionStatus.fromJson({
      'scheduled': true,
      'scheduledAt': 'invalid',
    });

    expect(status.scheduled, isFalse);
    expect(status.scheduledAt, isNull);
  });
}
