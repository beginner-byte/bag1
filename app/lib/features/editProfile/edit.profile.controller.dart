import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worker/core/model/user.dart';
import 'package:worker/core/repository/auth.repository.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';

/// 编辑个人资料控制器，负责资料状态、输入校验、提交和全局用户缓存同步。
class EditProfileController extends GetxController {
  /// 头像上传与服务端共同执行的字节上限，避免无效大文件进入网络请求。
  static const maxAvatarBytes = 5 * 1024 * 1024;

  /// 性别字段使用稳定代码，避免展示文案随应用语言变化后污染接口值。
  static const genderMale = 'male';

  /// 女性性别代码，与资料接口约定保持一致。
  static const genderFemale = 'female';

  /// 不透露性别代码，同时作为旧账号缺失字段时的默认值。
  static const genderUnspecified = 'unspecified';

  /// 认证服务，提供当前头像、昵称以及更新后的全局缓存位置。
  final AuthService authService = Get.find<AuthService>();

  /// 认证仓库，负责提交公开资料更新请求。
  final AuthRepository authRepository = AuthRepository();

  /// 昵称输入控制器，初始值来自当前登录用户。
  late final TextEditingController displayName;

  /// 昵称错误文案，空字符串表示当前输入有效。
  final RxString nameError = ''.obs;

  /// 是否正在保存，用于阻止重复提交并显示按钮加载状态。
  final RxBool submitting = false.obs;

  /// 当前表单是否允许保存，由昵称非空和提交状态共同决定。
  final RxBool canSubmit = false.obs;

  /// 当前昵称对应的头像占位首字，随输入变化驱动头像组件刷新。
  final RxString avatarInitial = '?'.obs;

  /// 当前选择的性别代码，UI 根据本地化语言转换为展示文案。
  final RxString gender = genderUnspecified.obs;

  /// 当前生日的 YYYY-MM-DD 字符串，空字符串表示尚未设置。
  final RxString birthday = ''.obs;

  /// 当前头像地址；未选择新头像前始终沿用登录用户资料。
  String get avatarUrl => authService.user?.avatarUrl ?? '';

  /// 系统相册选择器，只负责获取并压缩图片，不直接修改用户资料。
  final ImagePicker _imagePicker = ImagePicker();

  /// 当前尚未保存的新头像；null 表示继续使用服务器已保存的头像。
  final Rxn<XFile> selectedAvatar = Rxn<XFile>();

  /// 头像区域内联错误；空字符串表示选择与上传状态正常。
  final RxString avatarError = ''.obs;

  /// 是否正在等待系统相册返回，用于阻止重复打开图片选择器。
  final RxBool selectingAvatar = false.obs;

  /// 当前本地头像预览路径，选择新图片前为空。
  String get selectedAvatarPath => selectedAvatar.value?.path ?? '';

  /// 当前用户 ID，仅用于资料页只读展示和复制。
  String get userId => authService.user?.id ?? '';

  /// 当前登录主要账号仅用于只读展示，账号修改仍由账号与安全模块负责。
  String get account => authService.user?.primaryAccount ?? '';

  /// 当前账号是否为手机号，用于编辑页选择本地化字段标签。
  bool get isPhoneAccount => authService.user?.isPhoneAccount ?? false;

  /// 将生日字符串转换为日期选择器初始值，非法旧数据按未设置处理。
  DateTime? get birthdayDate => DateTime.tryParse(birthday.value);

  /// 初始化昵称输入和状态监听，让保存按钮实时响应表单变化。
  @override
  void onInit() {
    super.onInit();
    displayName = TextEditingController(
      text: authService.user?.displayName ?? '',
    );
    gender.value = authService.user?.gender ?? genderUnspecified;
    birthday.value = authService.user?.birthday ?? '';
    displayName.addListener(_syncFormState);
    _syncFormState();
  }

  /// 同步昵称校验与按钮状态，用户修正输入后及时移除旧错误。
  void _syncFormState() {
    final name = displayName.text.trim();
    final hasName = name.isNotEmpty;
    canSubmit.value = hasName && !submitting.value;
    avatarInitial.value = hasName ? name.substring(0, 1).toUpperCase() : '?';

    if (hasName && nameError.value.isNotEmpty) {
      nameError.value = '';
    }
  }

  /// 打开系统相册并保存压缩后的本地预览，不在用户点击保存前发起上传。
  ///
  /// 用户取消时保持原头像；权限拒绝、读取失败或超过 5 MB 时设置头像区域错误。
  Future<void> onPickAvatar() async {
    if (selectingAvatar.value || submitting.value) {
      return;
    }

    selectingAvatar.value = true;
    avatarError.value = '';

    try {
      // pickedImage 由系统相册返回，并限制最长边与质量以降低移动网络上传开销。
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedImage == null) {
        return;
      }

      // imageLength 在上传前再次执行硬限制，覆盖部分格式不支持质量压缩的情况。
      final imageLength = await pickedImage.length();
      if (imageLength > maxAvatarBytes) {
        avatarError.value = S.current.profileAvatarTooLarge;
        return;
      }

      selectedAvatar.value = pickedImage;
    } on PlatformException {
      avatarError.value = S.current.profileAvatarPickFailed;
    } catch (_) {
      avatarError.value = S.current.profileAvatarPickFailed;
    } finally {
      selectingAvatar.value = false;
    }
  }

  /// 更新性别选择；[value] 仅接受接口约定值，防止意外文案被提交到服务端。
  void updateGender(String value) {
    if (!const {genderMale, genderFemale, genderUnspecified}.contains(value)) {
      return;
    }

    gender.value = value;
  }

  /// 保存日期选择器返回的本地 [value]，并固定为接口要求的 YYYY-MM-DD 格式。
  void updateBirthday(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    birthday.value = '${value.year}-$month-$day';
  }

  /// 复制只读用户 ID，便于用户将稳定标识发送给团队管理员。
  Future<void> copyUserId() async {
    final value = userId.trim();

    if (value.isEmpty) {
      EasyLoading.showToast(S.current.profileUserIdUnavailable);
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    EasyLoading.showToast(S.current.profileUserIdCopied);
  }

  /// 校验表单，按需上传新头像，再提交完整资料并返回更新后的用户模型。
  ///
  /// 头像上传失败时保留本地选择供重试；资料更新失败时不覆盖全局用户缓存。
  Future<void> save() async {
    final name = displayName.text.trim();

    if (name.isEmpty) {
      nameError.value = S.current.profileDisplayNameRequired;
      return;
    }

    if (submitting.value) {
      return;
    }

    submitting.value = true;
    canSubmit.value = false;
    User? updatedUser;

    try {
      // nextAvatarURL 默认沿用服务器头像，只有本次选择图片时才调用上传接口替换。
      var nextAvatarURL = avatarUrl;
      // pendingAvatar 在一次保存周期内固定，避免异步上传期间读取到变化的选择状态。
      final pendingAvatar = selectedAvatar.value;
      if (pendingAvatar != null) {
        try {
          // avatarBytes 是压缩后的待上传内容，保存前再次检查长度防止文件被外部替换。
          final avatarBytes = await pendingAvatar.readAsBytes();
          if (avatarBytes.length > maxAvatarBytes) {
            avatarError.value = S.current.profileAvatarTooLarge;
            return;
          }
          nextAvatarURL = await authRepository.uploadAvatar(
            bytes: avatarBytes,
            fileName: pendingAvatar.name,
          );
          avatarError.value = '';
        } catch (_) {
          avatarError.value = S.current.profileAvatarUploadFailed;
          return;
        }
      }

      updatedUser = await authRepository.updateProfile(
        displayName: name,
        avatarUrl: nextAvatarURL,
        gender: gender.value,
        birthday: birthday.value,
      );

      authService.user = updatedUser;
      selectedAvatar.value = null;
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
      _syncFormState();
    }

    if (updatedUser == null) {
      return;
    }

    EasyLoading.showSuccess(S.current.profileSaveSuccess);
    Get.back(result: updatedUser);
  }

  /// 释放昵称输入控制器，避免页面关闭后继续持有文本编辑资源。
  @override
  void onClose() {
    displayName.removeListener(_syncFormState);
    displayName.dispose();
    super.onClose();
  }
}
