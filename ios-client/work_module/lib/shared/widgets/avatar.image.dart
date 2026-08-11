import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// 统一显示网络、本地文件或 data URI 头像，并在任何读取失败时使用占位组件。
class AvatarImage extends StatelessWidget {
  /// 创建头像图片。
  ///
  /// [source] 是已保存的服务器或 Mock 地址；[localPath] 是尚未保存的相册预览，
  /// 非空时优先显示；[fallback] 在地址为空、格式错误或加载失败时展示。
  const AvatarImage({
    super.key,
    required this.source,
    required this.fallback,
    this.localPath = '',
    this.fit = BoxFit.cover,
  });

  /// 服务器返回的 HTTP URL、Mock 本地路径或兼容旧 Mock 数据的 data URI。
  final String source;

  /// 相册刚选择的本地图片路径，保存前优先于 source 显示。
  final String localPath;

  /// 图片不可用时显示的昵称首字、图标或其他现有占位内容。
  final Widget fallback;

  /// 图片在既有圆形或圆角容器中的缩放方式。
  final BoxFit fit;

  /// 根据地址类型选择正确 Image 构造器，保持调用页面不关心 Mock 与真实环境差异。
  @override
  Widget build(BuildContext context) {
    // previewPath 仅在编辑页选择新头像后存在，必须覆盖尚未更新的服务器地址。
    final previewPath = localPath.trim();
    if (previewPath.isNotEmpty) {
      return _fileImage(previewPath);
    }

    // normalizedSource 清除接口意外携带的首尾空白，空值直接进入现有占位状态。
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty) {
      return fallback;
    }

    if (normalizedSource.startsWith('data:image/')) {
      return _dataImage(normalizedSource);
    }

    // parsedSource 用于识别 file URI；Mock 当前返回普通绝对路径，也在下方兼容。
    final parsedSource = Uri.tryParse(normalizedSource);
    if (parsedSource?.scheme == 'file') {
      return _fileImage(parsedSource!.toFilePath());
    }
    if (normalizedSource.startsWith('/')) {
      return _fileImage(normalizedSource);
    }

    return Image.network(
      normalizedSource,
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  /// 构建 [path] 指向的本地图片；文件缺失或解码失败时显示 fallback。
  Widget _fileImage(String path) {
    return Image.file(
      File(path),
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  /// 解码 [dataUri] 中的 base64 图片，兼容旧版本可能保存的内嵌 Mock 地址。
  Widget _dataImage(String dataUri) {
    try {
      // commaIndex separates the data URI metadata from its base64 payload.
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex < 0) {
        return fallback;
      }
      // encodedPayload excludes the comma so base64Decode receives only image bytes.
      final encodedPayload = dataUri.substring(commaIndex + 1);
      // decodedBytes lives only for the current image provider and is released with the widget tree.
      final decodedBytes = base64Decode(encodedPayload);
      return Image.memory(
        decodedBytes,
        fit: fit,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } on FormatException {
      return fallback;
    }
  }
}
