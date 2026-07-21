import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/core/model/user.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// “我的”页控制器，统一读取登录用户并处理页面导航与退出登录。
class ProfileController extends GetxController {
  /// 认证服务，提供当前用户和 session 管理能力。
  final AuthService authService = Get.find<AuthService>();

  /// 认证仓库，复用现有个人资料接口而不重复实现网络请求。
  final AuthRepository authRepository = AuthRepository();

  /// 当前页面展示的用户资料，请求成功后同时同步到认证服务。
  final Rxn<User> profile = Rxn<User>();

  /// 是否正在进行首次资料加载，用于控制资料卡骨架状态。
  final RxBool loading = true.obs;

  /// 当前可用的用户资料，优先使用页面最新请求结果，再回退到登录缓存。
  User? get currentUser => profile.value ?? authService.user;

  /// 当前登录用户的主要账号，手机号账号不会回退显示空邮箱。
  String get account => currentUser?.primaryAccount ?? '';

  /// 当前账号是否为手机号，用于页面选择本地化账号标签。
  bool get isPhoneAccount => currentUser?.isPhoneAccount ?? false;

  /// 当前登录用户的稳定 ID，用于团队和项目按 ID 添加成员。
  String get userId => currentUser?.id ?? '';

  /// 当前用户的展示姓名，缺失时回退为主要账号。
  String get displayName {
    final name = currentUser?.displayName.trim() ?? '';

    if (name.isNotEmpty) {
      return name;
    }

    return isPhoneAccount ? account : account.split('@').first;
  }

  /// 当前用户头像地址。
  String get avatarUrl => currentUser?.avatarUrl ?? '';

  /// 根据展示姓名生成头像首字，账号资料为空时使用问号兜底。
  String get avatarInitial {
    final value = displayName.trim();

    if (value.isEmpty) {
      return '?';
    }

    return value.substring(0, 1).toUpperCase();
  }

  /// 将用户 ID 写入系统剪贴板，方便发送给团队或项目创建者。
  Future<void> copyUserId() async {
    final value = userId.trim();

    if (value.isEmpty) {
      EasyLoading.showToast(S.current.profileUserIdUnavailable);
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    EasyLoading.showToast(S.current.profileUserIdCopied);
  }

  /// 页面首次初始化时请求最新资料，并显示个人资料卡骨架。
  @override
  void onInit() {
    super.onInit();
    loadProfile(showSkeleton: true);
  }

  /// 请求当前用户资料，并在成功后同步页面状态和全局认证缓存。
  ///
  /// [showSkeleton] 为 true 时显示首次加载骨架；下拉刷新时保留旧资料，
  /// 避免内容在网络请求期间闪烁。
  Future<void> loadProfile({required bool showSkeleton}) async {
    if (showSkeleton) {
      loading.value = true;
    }

    try {
      final user = await authRepository.profile();

      profile.value = user;
      authService.user = user;
    } catch (error) {
      EasyLoading.showToast(error.toString());
    } finally {
      loading.value = false;
    }
  }

  /// 执行下拉刷新；保留已有资料，只更新网络返回的数据。
  Future<void> refreshProfile() async {
    await loadProfile(showSkeleton: false);
  }

  /// 尚未接入的入口使用当前菜单名称提示，避免点击无反馈。
  @Deprecated(
    '关于我们已由 onOpenAbout 接入真实页面；当前未发现其他调用，暂时保留以避免扩大删除范围。标记日期：2026-07-15。',
  )
  void onPending(String title) {
    EasyLoading.showToast(title);
  }

  /// 打开账号与安全二级页，让会话操作离开个人页一级入口。
  Future<void> onOpenAccountSecurity() async {
    await Get.toNamed(GetRouter.accountSecurity);
  }

  /// 打开应用设置二级页，集中管理与账号无关的本地偏好。
  Future<void> onOpenAppSettings() async {
    await Get.toNamed(GetRouter.appSettings);
  }

  /// 打开关于我们二级页，集中展示版本信息和本地法律文档。
  Future<void> onOpenAbout() async {
    await Get.toNamed(GetRouter.about);
  }

  /// 打开编辑个人资料页，并用返回的最新用户模型刷新当前资料卡。
  Future<void> onOpenEditProfile() async {
    // GetX 的命名路由实际创建动态类型 Route，避免在导航阶段强制转换为 Route<User?>。
    final result = await Get.toNamed(GetRouter.editProfile);

    // 仅接收编辑页明确返回的用户模型，普通返回或异常结果不覆盖当前资料。
    if (result is! User) {
      return;
    }

    profile.value = result;
    authService.user = result;
  }
}
