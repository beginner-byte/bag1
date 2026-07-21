import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:worker/core/network/auth/core/http.method.dart';
import 'package:worker/core/network/auth/core/task.dart';
import 'package:worker/core/network/base.target.dart';

/// 上传当前登录用户头像的 multipart 请求目标。
final class UploadAvatarTarget extends BaseTarget {
  /// 创建头像上传请求。
  ///
  /// [bytes] 是选择器压缩后的图片内容；[fileName] 仅作为 multipart 文件描述，
  /// 服务端会根据真实图片字节和登录用户重新校验、命名与存储。
  UploadAvatarTarget({required this.bytes, required this.fileName});

  /// 经客户端尺寸压缩并完成 5 MB 上限校验的头像字节。
  final Uint8List bytes;

  /// 系统选择器返回的原文件名，用于 multipart 文件元数据而不参与服务端路径。
  final String fileName;

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get path => '/v1/auth/avatar';

  /// 将图片放在服务端约定的 file 字段中并使用 multipart 编码。
  @override
  RequestTask get task => RequestTask.parameters(
    parameters: {'file': MultipartFile.fromBytes(bytes, filename: fileName)},
    encoding: ParameterEncoding.multipart,
  );
}
