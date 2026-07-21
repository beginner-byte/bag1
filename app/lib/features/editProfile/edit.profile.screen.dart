import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/features/editProfile/edit.profile.controller.dart';
import 'package:worker/features/editProfile/edit.profile.mixin.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';

/// 编辑个人资料二级页，在公开资料与登录账号信息之间保持清晰边界。
class EditProfileScreen extends GetView<EditProfileController>
    with ScreenMixin, EditProfileMixin {
  const EditProfileScreen({super.key});

  /// 表单页跟随键盘调整可用高度，避免昵称输入框和保存按钮被遮挡。
  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  /// 二级页内容从导航栏下方开始，避免表单与返回按钮重叠。
  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  /// 构建与页面顶部背景一致的编辑资料导航栏。
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).profileEditTitle),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// 在 Screen 中组合头像、基础资料和只读账号信息分组。
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
              final error = controller.nameError.value;
              final gender = controller.gender.value;
              final birthday = controller.birthday.value;
              // localAvatarPath drives immediate preview without changing the persisted user model.
              final localAvatarPath = controller.selectedAvatarPath;
              // avatarError is rendered inline so the selected preview remains visible for retry.
              final avatarError = controller.avatarError.value;
              // uploadingAvatar covers only the save-time upload stage represented by a selected image.
              final uploadingAvatar =
                  controller.submitting.value && localAvatarPath.isNotEmpty;

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
                          : uploadingAvatar
                          ? l10n.profileAvatarUploading
                          : l10n.profileAvatarSelected,
                      errorText: avatarError.isEmpty ? null : avatarError,
                      loading: uploadingAvatar,
                      onTap:
                          controller.submitting.value ||
                              controller.selectingAvatar.value
                          ? null
                          : () => controller.onPickAvatar(),
                    ),
                  ]),
                  SizedBox(height: 14.r),
                  editProfileGroup([
                    editNameRow(
                      controller: controller.displayName,
                      label: l10n.profileDisplayName,
                      hint: l10n.profileDisplayNameHint,
                      errorText: error.isEmpty ? null : error,
                    ),
                    editValueRow(
                      label: l10n.profileUserId,
                      value: controller.userId,
                      onTap: controller.copyUserId,
                      trailingIcon: Icons.copy_rounded,
                    ),
                    editValueRow(
                      label: l10n.profileGender,
                      value: _genderLabel(l10n, gender),
                      onTap: () => _pickGender(context),
                    ),
                    editValueRow(
                      label: l10n.profileBirthday,
                      value: _birthdayLabel(context, birthday),
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

  /// 构建固定底部保存按钮，让用户编辑后始终能快速提交。
  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.r, 20.w, 18.r),
        child: Obx(() {
          return editSaveButton(
            label: S.of(context).profileSave,
            enabled: controller.canSubmit.value,
            loading: controller.submitting.value,
            onPressed: controller.save,
          );
        }),
      ),
    );
  }

  /// 打开性别选择面板，并将返回的稳定代码同步到表单控制器。
  Future<void> _pickGender(BuildContext context) async {
    final l10n = S.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheetContext) {
        return genderPicker(
          context: sheetContext,
          title: l10n.profileGender,
          selectedValue: controller.gender.value,
          options: {
            EditProfileController.genderMale: l10n.profileGenderMale,
            EditProfileController.genderFemale: l10n.profileGenderFemale,
            EditProfileController.genderUnspecified:
                l10n.profileGenderUnspecified,
          },
        );
      },
    );

    if (selected == null) {
      return;
    }

    controller.updateGender(selected);
  }

  /// 打开生日日期选择器；限制未来日期，避免保存无效个人资料。
  Future<void> _pickBirthday(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final current = controller.birthdayDate;
    final initialDate = current == null || current.isAfter(today)
        ? DateTime(2000)
        : current;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: S.of(context).profileBirthday,
    );

    if (selected == null) {
      return;
    }

    controller.updateBirthday(selected);
  }

  /// 将接口性别代码转换为当前语言展示文案，未知代码按不透露处理。
  String _genderLabel(S l10n, String value) {
    return switch (value) {
      EditProfileController.genderMale => l10n.profileGenderMale,
      EditProfileController.genderFemale => l10n.profileGenderFemale,
      _ => l10n.profileGenderUnspecified,
    };
  }

  /// 将 YYYY-MM-DD 生日转换为系统本地化日期，空值展示“未设置”。
  String _birthdayLabel(BuildContext context, String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return S.of(context).profileNotSet;
    }

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}
