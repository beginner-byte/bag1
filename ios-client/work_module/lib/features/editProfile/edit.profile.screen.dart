import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/features/editProfile/edit.profile.controller.dart';
import 'package:work_module/features/editProfile/edit.profile.mixin.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/mixins/screen.mixin.dart';

/// Worker 编辑个人资料二级页面。
final class EditProfileScreen extends GetView<EditProfileController>
    with ScreenMixin, EditProfileMixin {
  const EditProfileScreen({super.key});

  @override
  bool resizeToAvoidBottomInset() => true;

  @override
  bool extendBodyBehindAppBar() => false;

  /// 构建编辑资料导航栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).profileEditTitle),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 构建头像、公开资料和只读账号信息表单。
  @override
  Widget body(BuildContext context) {
    final l10n = S.of(context);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.r, 20.w, 120.r),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Obx(() {
              final localAvatarPath = controller.selectedAvatarPath;
              final avatarError = controller.avatarError.value;
              return Column(
                children: [
                  editProfileGroup([
                    editAvatarRow(
                      label: l10n.profileAvatar,
                      avatarUrl: controller.avatarUrl,
                      localAvatarPath: localAvatarPath,
                      avatarInitial: controller.avatarInitial.value,
                      statusText: localAvatarPath.isEmpty
                          ? null
                          : l10n.profileAvatarSelected,
                      errorText: avatarError.isEmpty ? null : avatarError,
                      loading:
                          controller.submitting.value &&
                          localAvatarPath.isNotEmpty,
                      onTap:
                          controller.submitting.value ||
                              controller.selectingAvatar.value
                          ? null
                          : controller.onPickAvatar,
                    ),
                  ]),
                  SizedBox(height: 14.r),
                  editProfileGroup([
                    editNameRow(
                      label: l10n.profileDisplayName,
                      hint: l10n.profileDisplayNameHint,
                      controller: controller.displayName,
                      errorText: controller.nameError.value.isEmpty
                          ? null
                          : controller.nameError.value,
                    ),
                    editValueRow(
                      label: l10n.profileUserId,
                      value: controller.userId,
                      onTap: controller.copyUserId,
                      trailingIcon: Icons.copy_rounded,
                    ),
                    editValueRow(
                      label: l10n.profileGender,
                      value: _genderLabel(l10n, controller.gender.value),
                      onTap: () => _pickGender(context),
                    ),
                    editValueRow(
                      label: l10n.profileBirthday,
                      value: _birthdayLabel(context, controller.birthday.value),
                      onTap: () => _pickBirthday(context),
                    ),
                  ]),
                  SizedBox(height: 14.r),
                  editProfileGroup([
                    editValueRow(
                      label: controller.isPhoneAccount
                          ? l10n.profilePhone
                          : l10n.profileEmail,
                      value: controller.account,
                    ),
                  ]),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 构建固定保存按钮。
  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.r, 20.w, 18.r),
        child: Obx(
          () => editSaveButton(
            label: S.of(context).profileSave,
            enabled: controller.canSubmit.value,
            loading: controller.submitting.value,
            onPressed: controller.save,
          ),
        ),
      ),
    );
  }

  /// 打开性别选择面板并保存返回代码。
  Future<void> _pickGender(BuildContext context) async {
    final l10n = S.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (context) => genderPicker(
        context: context,
        title: l10n.profileGender,
        selectedValue: controller.gender.value,
        options: {
          EditProfileController.genderMale: l10n.profileGenderMale,
          EditProfileController.genderFemale: l10n.profileGenderFemale,
          EditProfileController.genderUnspecified:
              l10n.profileGenderUnspecified,
        },
      ),
    );
    if (selected != null) {
      controller.updateGender(selected);
    }
  }

  /// 打开生日选择器并禁止选择未来日期。
  Future<void> _pickBirthday(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final current = controller.birthdayDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: current == null || current.isAfter(today)
          ? DateTime(2000)
          : current,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: S.of(context).profileBirthday,
    );
    if (selected != null) {
      controller.updateBirthday(selected);
    }
  }

  /// 将性别代码转换为当前语言文案。
  String _genderLabel(S l10n, String value) {
    return switch (value) {
      EditProfileController.genderMale => l10n.profileGenderMale,
      EditProfileController.genderFemale => l10n.profileGenderFemale,
      _ => l10n.profileGenderUnspecified,
    };
  }

  /// 将生日字符串转换为本地化展示文本。
  String _birthdayLabel(BuildContext context, String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? S.of(context).profileNotSet
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }
}
