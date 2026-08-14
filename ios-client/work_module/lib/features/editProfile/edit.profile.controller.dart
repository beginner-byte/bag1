import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_module/core/model/user.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/repository/profile.repository.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';

/// 编辑 Worker 个人资料的表单状态和提交控制器。
final class EditProfileController extends GetxController {
  /// 单张头像的客户端字节上限。
  static const maxAvatarBytes = 5 * 1024 * 1024;

  /// 男性稳定接口代码。
  static const genderMale = 'male';

  /// 女性稳定接口代码。
  static const genderFemale = 'female';

  /// 不透露性别稳定接口代码。
  static const genderUnspecified = 'unspecified';

  /// 资料仓库，负责头像上传和资料保存。
  final ProfileRepository repository = ProfileRepository();

  /// CandyTalk 宿主桥，用于把名字和头像写入 IM 主资料。
  final WorkHostBridge bridge = Get.find<WorkHostBridge>();

  /// 路由传入的当前 Worker 用户资料。
  late final User user;

  /// iOS 映射用户在 Profile 响应不含邮箱或手机号时使用的宿主登录账号。
  late final String fallbackAccount;

  /// 昵称输入控制器。
  late final TextEditingController displayName;

  /// 昵称校验错误；空字符串表示有效。
  final RxString nameError = ''.obs;

  /// 当前是否正在保存。
  final RxBool submitting = false.obs;

  /// 当前表单是否允许保存。
  final RxBool canSubmit = false.obs;

  /// 当前昵称生成的头像兜底首字。
  final RxString avatarInitial = '?'.obs;

  /// 当前性别稳定代码。
  final RxString gender = genderUnspecified.obs;

  /// 当前 YYYY-MM-DD 生日字符串。
  final RxString birthday = ''.obs;

  /// 系统相册选择器。
  final ImagePicker _imagePicker = ImagePicker();

  /// 尚未保存的新头像。
  final Rxn<XFile> selectedAvatar = Rxn<XFile>();

  /// 头像选择或上传错误；空字符串表示正常。
  final RxString avatarError = ''.obs;

  /// 是否正在等待系统相册返回。
  final RxBool selectingAvatar = false.obs;

  /// 当前服务器头像地址。
  String get avatarUrl => user.avatarUrl;

  /// 当前本地头像预览路径。
  String get selectedAvatarPath => selectedAvatar.value?.path ?? '';

  /// 当前 Worker 用户 ID。
  String get userId => user.id;

  /// 当前只读登录账号。
  String get account =>
      user.primaryAccount.isNotEmpty ? user.primaryAccount : fallbackAccount;

  /// 当前账号是否为手机号。
  bool get isPhoneAccount =>
      user.isPhoneAccount || fallbackAccount.startsWith('+');

  /// 将生日字符串转换为选择器初始日期。
  DateTime? get birthdayDate => DateTime.tryParse(birthday.value);

  /// 读取路由用户并初始化表单。
  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    final currentUser = argument is Map ? argument['user'] : null;
    if (currentUser is! User) {
      throw StateError('编辑个人资料缺少 Worker 用户数据');
    }
    user = currentUser;
    fallbackAccount = argument is Map
        ? argument['account']?.toString() ?? ''
        : '';
    displayName = TextEditingController(text: user.displayName);
    gender.value = user.gender;
    birthday.value = user.birthday;
    displayName.addListener(_syncFormState);
    _syncFormState();
  }

  /// 根据昵称和提交状态同步表单可用性。
  void _syncFormState() {
    final name = displayName.text.trim();
    canSubmit.value = name.isNotEmpty && !submitting.value;
    avatarInitial.value = name.isEmpty
        ? '?'
        : name.substring(0, 1).toUpperCase();
    if (name.isNotEmpty) {
      nameError.value = '';
    }
  }

  /// 从相册选择压缩头像，并在本地完成 5 MB 限制校验。
  Future<void> onPickAvatar() async {
    if (selectingAvatar.value || submitting.value) {
      return;
    }
    selectingAvatar.value = true;
    avatarError.value = '';
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) {
        return;
      }
      if (await image.length() > maxAvatarBytes) {
        avatarError.value = S.current.profileAvatarTooLarge;
        return;
      }
      selectedAvatar.value = image;
    } on PlatformException {
      avatarError.value = S.current.profileAvatarPickFailed;
    } catch (_) {
      avatarError.value = S.current.profileAvatarPickFailed;
    } finally {
      selectingAvatar.value = false;
    }
  }

  /// 更新页面选择的性别代码，拒绝接口范围外的值。
  void updateGender(String value) {
    if (const {genderMale, genderFemale, genderUnspecified}.contains(value)) {
      gender.value = value;
    }
  }

  /// 将选择日期保存为无时区歧义的 YYYY-MM-DD 字符串。
  void updateBirthday(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    birthday.value = '${value.year}-$month-$day';
  }

  /// 复制只读 Worker 用户 ID。
  Future<void> copyUserId() async {
    if (userId.isEmpty) {
      EasyLoading.showToast(S.current.profileUserIdUnavailable);
      return;
    }
    await Clipboard.setData(ClipboardData(text: userId));
    EasyLoading.showToast(S.current.profileUserIdCopied);
  }

  /// 按需上传头像，再更新资料并把最新用户返回“我的”页面。
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
    try {
      Uint8List? avatarBytes;
      final avatar = selectedAvatar.value;
      if (avatar != null) {
        avatarBytes = await avatar.readAsBytes();
        if (avatarBytes.length > maxAvatarBytes) {
          avatarError.value = S.current.profileAvatarTooLarge;
          return;
        }
      }
      final imAvatarUrl = await bridge.updateCurrentUserProfile(
        displayName: name,
        avatarBytes: avatarBytes,
        avatarFileName: avatar?.name,
      );
      final nextAvatarUrl = imAvatarUrl.isNotEmpty ? imAvatarUrl : avatarUrl;
      final updatedUser = await repository.updateProfile(
        displayName: name,
        avatarUrl: nextAvatarUrl,
        gender: gender.value,
        birthday: birthday.value,
      );
      EasyLoading.showSuccess(S.current.profileSaveSuccess);
      Get.back(result: updatedUser);
    } catch (error) {
      EasyLoading.showError(error.toString());
    } finally {
      submitting.value = false;
      _syncFormState();
    }
  }

  /// 页面销毁时释放输入控制器。
  @override
  void onClose() {
    displayName.removeListener(_syncFormState);
    displayName.dispose();
    super.onClose();
  }
}
