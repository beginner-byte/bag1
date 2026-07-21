import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 查询当前账号删除预约状态的请求目标。
final class AccountDeletionStatusTarget extends BaseTarget {
  /// 使用 GET 读取状态，不改变预约期限。
  @override
  HttpMethod get method => HttpMethod.get;

  /// 账号删除状态与预约操作共享服务端资源路径。
  @override
  String get path => '/v1/auth/account/deletion';
}

/// 预约当前账号在固定 15 天冷静期后永久删除的请求目标。
final class ScheduleAccountDeletionTarget extends BaseTarget {
  /// 使用 POST 创建固定期限的删除预约。
  @override
  HttpMethod get method => HttpMethod.post;

  /// 账号删除状态与预约操作共享服务端资源路径。
  @override
  String get path => '/v1/auth/account/deletion';

  /// action 仅帮助本地 Mock 区分同路径操作，真实服务端固定忽略客户端期限。
  @override
  RequestTask get task => const RequestTask.parameters(
    parameters: {'action': 'schedule'},
    encoding: ParameterEncoding.json,
  );
}

/// 在永久删除开始前撤销当前账号预约的请求目标。
final class CancelAccountDeletionTarget extends BaseTarget {
  /// 使用 DELETE 撤销尚未到期的预约资源。
  @override
  HttpMethod get method => HttpMethod.delete;

  /// 账号删除状态与预约操作共享服务端资源路径。
  @override
  String get path => '/v1/auth/account/deletion';

  /// action 仅帮助本地 Mock 区分查询和撤销，不允许客户端改变服务端状态规则。
  @override
  RequestTask get task => const RequestTask.parameters(
    parameters: {'action': 'cancel'},
    encoding: ParameterEncoding.json,
  );
}

/// 跳过冷静期并立即永久删除当前账号的请求目标。
final class DeleteAccountNowTarget extends BaseTarget {
  /// 使用 DELETE 执行账号本体的不可撤销移除。
  @override
  HttpMethod get method => HttpMethod.delete;

  /// 账号资源路径与可撤销预约资源保持分离。
  @override
  String get path => '/v1/auth/account';
}
