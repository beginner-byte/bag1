import 'package:flutter_test/flutter_test.dart';
import 'package:worker/app/config/environment.dart';

/// 验证未传 dart-define 时默认关闭 Mock 并连接线上 Co Here 服务。
void main() {
  test('environment defaults to the production service', () {
    expect(Environment.enableMock, isFalse);
    expect(Environment.apiBaseUrl, 'https://web.cohereweb.xyz');
  });
}
