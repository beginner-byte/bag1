import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:work_module/core/network/base.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/core/task.dart';

/// 将当前用户的新头像上传到 Worker 服务。
final class UploadAvatarTarget extends BaseTarget {
  /// 使用已完成大小校验的图片内容创建 multipart 请求。
  UploadAvatarTarget({required this.bytes, required this.fileName});

  /// 待上传图片字节。
  final Uint8List bytes;

  /// 系统相册返回的文件名，仅用于 multipart 元数据。
  final String fileName;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/auth/avatar';

  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'file': MultipartFile.fromBytes(bytes, filename: fileName)},
    encoding: ParameterEncoding.multipart,
  );
}
