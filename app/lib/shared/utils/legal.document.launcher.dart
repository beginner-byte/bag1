import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worker/app/config/environment.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 服务器法律文档的稳定类型，不能使用本地化标题参与链接判断。
enum LegalDocumentType {
  /// Worker 用户协议，对应服务器 terms.html。
  agreement,

  /// Worker 隐私政策，对应服务器 privacy.html。
  privacy,
}

/// 统一生成并打开服务器法律文档链接，供登录页和关于我们页面复用。
abstract final class LegalDocumentLauncher {
  /// 返回 [type] 对应的完整服务器 URI。
  static Uri uri(LegalDocumentType type) {
    // documentName 与服务端文件名保持稳定对应，不受当前语言影响。
    final documentName = switch (type) {
      LegalDocumentType.agreement => 'terms.html',
      LegalDocumentType.privacy => 'privacy.html',
    };

    return Uri.parse('${Environment.legalBaseUrl}/legal/$documentName');
  }

  /// 使用系统浏览器打开 [type] 对应链接，失败时在当前页面提示用户。
  ///
  /// 此操作会离开 App 打开外部浏览器，但不会修改登录或协议同意状态。
  static Future<void> open(LegalDocumentType type) async {
    try {
      // opened 表示操作系统已经接受打开链接的请求。
      final opened = await launchUrl(
        uri(type),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        EasyLoading.showToast(S.current.legalDocumentOpenFailed);
      }
    } catch (_) {
      EasyLoading.showToast(S.current.legalDocumentOpenFailed);
    }
  }
}
