import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:work_module/core/model/user.dart';
import 'package:work_module/core/network/auth/profile.target.dart';
import 'package:work_module/core/network/auth/update.profile.target.dart';
import 'package:work_module/core/network/auth/upload.avatar.target.dart';
import 'package:work_module/core/network/core/network.service.dart';

/// Worker 个人资料仓库，只承载查询、资料更新和头像上传能力。
final class ProfileRepository {
  /// 获取当前 Bearer 会话对应的完整 Worker 用户资料。
  Future<User> profile() async {
    final response = await Get.find<NetworkService>().fetch<User>(
      ProfileTarget(),
      decoder: User.fromJson,
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    throw response.message ?? '获取个人资料失败';
  }

  /// 更新公开资料并返回服务端保存后的完整用户模型。
  Future<User> updateProfile({
    required String displayName,
    required String avatarUrl,
    required String gender,
    required String birthday,
  }) async {
    final response = await Get.find<NetworkService>().fetch<User>(
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

  /// 上传头像并返回服务端生成的公开地址。
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await Get.find<NetworkService>().fetch<String>(
      UploadAvatarTarget(bytes: bytes, fileName: fileName),
      decoder: (data) => data is Map ? data['avatarUrl']?.toString() ?? '' : '',
    );
    final avatarUrl = response.data?.trim() ?? '';
    if (response.code == 0 && avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
    throw response.message ?? '头像上传失败';
  }
}
