import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:worker/core/model/auth/account.deletion.status.dart';
import 'package:worker/core/model/auth/auth.identity.dart';
import 'package:worker/core/model/auth/login.device.model.dart';
import 'package:worker/core/model/user.dart';
import 'package:worker/core/network/auth/change.password.target.dart';
import 'package:worker/core/network/auth/account.deletion.targets.dart';
import 'package:worker/core/network/auth/code.target.dart';
import 'package:worker/core/network/auth/login.target.dart';
import 'package:worker/core/network/auth/login.devices.target.dart';
import 'package:worker/core/network/auth/logout.device.target.dart';
import 'package:worker/core/network/auth/profile.target.dart';
import 'package:worker/core/network/auth/register.target.dart';
import 'package:worker/core/network/auth/reset.password.target.dart';
import 'package:worker/core/network/auth/update.profile.target.dart';
import 'package:worker/core/network/auth/upload.avatar.target.dart';
import 'package:worker/core/network/auth/core/network.service.dart';
import 'package:worker/core/service/auth.service.dart';

/// Mock 认证结果，供 controller 映射成页面提示文案。
enum AuthResult {
  success,
  invalidCode,
  accountAlreadyRegistered,
  accountNotFound,
  invalidPassword,
}

/// 修改密码结果，让界面使用本地化文案处理可预期的业务失败。
enum ChangePasswordResult { success, invalidCurrentPassword }

/// 找回密码结果，让页面区分验证码错误和账号不存在两种可预期失败。
enum ResetPasswordResult { success, invalidCode, accountNotFound }

/// 注册接口结果，保留业务状态并携带成功后可直接使用的设备会话 Token。
final class RegisterResult {
  /// 创建注册结果；失败状态的 [token] 为空字符串。
  const RegisterResult({required this.result, this.token = ''});

  /// 注册业务状态，用于页面映射已有本地化提示。
  final AuthResult result;

  /// 注册成功后服务器签发的首个设备会话 Token。
  final String token;
}

final class AuthRepository {
  /// 请求短信或邮箱验证码，返回 true 表示后端已接受发送请求。
  ///
  /// [identity] 必须是控制器已标准化并校验的账号；真实后端会通过 Twilio
  /// Verify 发送短信，Mock 模式仍使用本地模拟结果。
  Future<bool> code(AuthIdentity identity) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      CodeTarget(
        identityType: identity.type,
        account: identity.account,
        phoneRegionCode: identity.phoneRegionCode,
      ),
    );

    return response.code == 0;
  }

  /// 调用注册接口，并把后端业务码转换成页面可处理的认证结果。
  Future<RegisterResult> register({
    required AuthIdentity identity,
    required String password,
    required String code,
  }) async {
    final net = Get.find<NetworkService>();
    // auth 提供安装级匿名设备信息，不读取硬件标识。
    final auth = Get.find<AuthService>();

    final response = await net.fetch<String>(
      RegisterTarget(
        identityType: identity.type,
        account: identity.account,
        phoneRegionCode: identity.phoneRegionCode,
        password: password,
        code: code,
        deviceId: auth.deviceId,
        deviceName: auth.deviceName,
        platform: auth.devicePlatform,
      ),
      decoder: (data) {
        if (data is Map<String, dynamic>) {
          return data['token']?.toString() ?? '';
        }
        return '';
      },
    );

    if (response.code == 0 && response.data?.isNotEmpty == true) {
      return RegisterResult(result: AuthResult.success, token: response.data!);
    }

    if (response.code == 4001) {
      return const RegisterResult(result: AuthResult.invalidCode);
    }

    return const RegisterResult(result: AuthResult.accountAlreadyRegistered);
  }

  /// 调用登录接口，成功时返回后端下发的 session token。
  Future<String> login({
    required AuthIdentity identity,
    required String password,
  }) async {
    final net = Get.find<NetworkService>();
    // auth 提供当前 App 安装对应的稳定匿名设备信息。
    final auth = Get.find<AuthService>();

    final response = await net.fetch<String>(
      LoginTarget(
        identityType: identity.type,
        account: identity.account,
        phoneRegionCode: identity.phoneRegionCode,
        password: password,
        deviceId: auth.deviceId,
        deviceName: auth.deviceName,
        platform: auth.devicePlatform,
      ),
      decoder: (data) {
        if (data is Map<String, dynamic>) {
          return data['token']?.toString() ?? '';
        }

        return data?.toString() ?? '';
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '登录失败';
  }

  /// 获取当前账号全部有效设备会话，当前设备由服务端根据 JWT 标记。
  Future<List<LoginDevice>> loginDevices() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<List<LoginDevice>>(
      LoginDevicesTarget(),
      decoder: (data) {
        if (data is! List) {
          return <LoginDevice>[];
        }
        return data.map(LoginDevice.fromJson).toList(growable: false);
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '获取登录设备失败';
  }

  /// 撤销指定设备会话；[sessionId] 必须属于当前登录账号。
  Future<void> logoutDevice(String sessionId) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(LogoutDeviceTarget(sessionId: sessionId));
    if (response.code != 0) {
      throw response.message ?? '退出登录设备失败';
    }
  }

  /// 查询当前账号是否已预约永久删除以及准确删除时间。
  ///
  /// 接口失败时抛出服务端文案，调用方保留现有页面状态并允许用户重试。
  Future<AccountDeletionStatus> accountDeletionStatus() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<AccountDeletionStatus>(
      AccountDeletionStatusTarget(),
      decoder: AccountDeletionStatus.fromJson,
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '获取账号删除状态失败';
  }

  /// 预约账号在服务端固定 15 天冷静期结束后永久删除。
  ///
  /// 返回服务端保存的首次预约时间；重复调用不会延长原期限。
  Future<AccountDeletionStatus> scheduleAccountDeletion() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<AccountDeletionStatus>(
      ScheduleAccountDeletionTarget(),
      decoder: AccountDeletionStatus.fromJson,
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '预约删除账号失败';
  }

  /// 撤销尚未到期的账号删除预约并保留现有账号数据。
  Future<void> cancelAccountDeletion() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(CancelAccountDeletionTarget());
    if (response.code != 0) {
      throw response.message ?? '撤销账号删除失败';
    }
  }

  /// 立即永久删除当前账号并使所有服务端会话失效。
  ///
  /// 成功后调用方必须清理本地账号数据，且不得尝试使用原 Token 请求其他接口。
  Future<void> deleteAccountNow() async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(DeleteAccountNowTarget());
    if (response.code != 0) {
      throw response.message ?? '删除账号失败';
    }
  }

  /// 获取当前登录用户信息，后续接入 profile 接口并解析为 User。
  Future<User> profile() async {
    final net = Get.find<NetworkService>();

    final response = await net.fetch(
      ProfileTarget(),
      decoder: (data) {
        return User.fromJson(data);
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '登录失败';
  }

  /// 更新当前用户的公开资料，并返回服务端保存后的完整用户模型。
  ///
  /// [displayName] 是新的昵称；[avatarUrl] 是当前或上传后的头像地址；
  /// [gender] 和 [birthday] 分别是性别代码与 YYYY-MM-DD 日期字符串。
  Future<User> updateProfile({
    required String displayName,
    required String avatarUrl,
    required String gender,
    required String birthday,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      UpdateProfileTarget(
        displayName: displayName,
        avatarUrl: avatarUrl,
        gender: gender,
        birthday: birthday,
      ),
      decoder: User.fromJson,
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }

    throw response.message ?? '更新个人资料失败';
  }

  /// 上传当前用户的新头像并返回服务端生成的公开地址。
  ///
  /// [bytes] 是相册选择后压缩并校验过的图片内容；[fileName] 仅用于 multipart
  /// 元数据。接口业务失败或缺少头像地址时抛出异常，不修改本地用户资料。
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch<String>(
      UploadAvatarTarget(bytes: bytes, fileName: fileName),
      decoder: (data) {
        if (data is! Map) {
          return '';
        }
        return data['avatarUrl']?.toString() ?? '';
      },
    );

    final uploadedURL = response.data?.trim() ?? '';
    if (response.code == 0 && uploadedURL.isNotEmpty) {
      return uploadedURL;
    }

    throw response.message ?? '头像上传失败';
  }

  /// 校验当前密码并更新登录账号的密码。
  ///
  /// [currentPassword] 是用户当前密码；[newPassword] 是准备替换的新密码。
  Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      ChangePasswordTarget(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    if (response.code == 0) {
      return ChangePasswordResult.success;
    }

    if (response.code == 4004) {
      return ChangePasswordResult.invalidCurrentPassword;
    }

    throw response.message ?? '修改密码失败';
  }

  /// 通过短信或邮箱验证码重置未登录账号的密码。
  ///
  /// [identity] 是已标准化账号；[code] 是 Mock 验证码；[newPassword] 是新密码。
  Future<ResetPasswordResult> resetPassword({
    required AuthIdentity identity,
    required String code,
    required String newPassword,
  }) async {
    final net = Get.find<NetworkService>();
    final response = await net.fetch(
      ResetPasswordTarget(
        identityType: identity.type,
        account: identity.account,
        phoneRegionCode: identity.phoneRegionCode,
        code: code,
        newPassword: newPassword,
      ),
    );

    if (response.code == 0) {
      return ResetPasswordResult.success;
    }

    if (response.code == 4001) {
      return ResetPasswordResult.invalidCode;
    }

    if (response.code == 4003) {
      return ResetPasswordResult.accountNotFound;
    }

    throw response.message ?? '重置密码失败';
  }
}
