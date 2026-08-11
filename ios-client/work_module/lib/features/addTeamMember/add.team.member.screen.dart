import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/features/addTeamMember/add.team.member.controller.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/mixins/screen.mixin.dart';
import 'package:work_module/shared/widgets/avatar.image.dart';

/// 邀请成员独立页面，通过用户 ID、邮箱或手机号搜索并确认发送邀请。
class AddTeamMemberScreen extends GetView<AddTeamMemberController>
    with ScreenMixin {
  const AddTeamMemberScreen({super.key});

  @override
  bool resizeToAvoidBottomInset() {
    return true;
  }

  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).teamDetailAddMember),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context) {
    if (controller.team == null || !controller.isCreator) {
      return _permissionDenied(context);
    }

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Obx(() {
            return Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    size: 64.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton.icon(
                      onPressed: controller.inviting.value
                          ? null
                          : controller.addNativeFriends,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(S.of(context).teamDetailAddMember),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 使用 [context] 构建搜索输入和显式搜索操作，并返回支持键盘提交的搜索栏。
  ///
  /// 已废弃（2026-08-10）：新入口改用 CandyTalk 原生好友选择；当前无调用，保留以兼容旧搜索交互回退。
  // ignore: unused_element
  Widget _searchBar(BuildContext context) {
    final busy = controller.searching.value || controller.inviting.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.query,
        builder: (context, value, child) {
          final hasText = value.text.trim().isNotEmpty;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.query,
                  autofocus: true,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.search,
                  onChanged: controller.onQueryChanged,
                  onSubmitted: (_) => controller.search(),
                  decoration: InputDecoration(
                    hintText: S.of(context).teamDetailMemberUserIdHint,
                    errorText: controller.inputError.value.isEmpty
                        ? null
                        : controller.inputError.value,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 22.r,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            onPressed: busy
                                ? null
                                : () {
                                    controller.query.clear();
                                    controller.onQueryChanged('');
                                  },
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 19.r,
                              color: AppColors.textDisabled,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    constraints: BoxConstraints(minHeight: 48.h),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    border: _inputBorder(AppColors.divider),
                    enabledBorder: _inputBorder(AppColors.divider),
                    focusedBorder: _inputBorder(AppColors.primary),
                    errorBorder: _inputBorder(AppColors.error),
                    focusedErrorBorder: _inputBorder(AppColors.error),
                  ),
                ),
              ),
              if (hasText) ...[
                SizedBox(width: 6.w),
                TextButton(
                  onPressed: busy ? null : controller.search,
                  style: TextButton.styleFrom(
                    minimumSize: Size(54.w, 48.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    S.of(context).teamMemberSearchAction,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 根据搜索状态展示微信式引导、加载、无结果或用户列表行。
  ///
  /// 已废弃（2026-08-10）：由原生好友选择结果替代；当前无调用，和旧搜索栏一起保留作为回退实现。
  // ignore: unused_element
  Widget _searchContent(BuildContext context) {
    if (controller.searching.value) {
      return Padding(
        padding: EdgeInsets.only(top: 44.h),
        child: Center(
          child: SizedBox(
            width: 24.r,
            height: 24.r,
            child: const CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    final member = controller.result.value;

    if (member != null) {
      return _resultSection(context, member);
    }

    if (controller.hasSearched.value) {
      return _stateMessage(
        icon: Icons.person_search_outlined,
        title: S.of(context).teamMemberSearchNoResultTitle,
        description: S.of(context).teamMemberSearchNoResult,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17.r,
            color: AppColors.textDisabled,
          ),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              S.of(context).teamMemberSearchGuide,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 使用 [context] 和 [member] 构建搜索结果标题，并返回可发送邀请的用户列表行。
  Widget _resultSection(BuildContext context, TeamMemberSummary member) {
    final alreadyJoined = controller.isAlreadyMember;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).teamMemberSearchResult,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.85),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              child: Row(
                children: [
                  _avatar(member),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          member.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  if (controller.inviting.value)
                    SizedBox(
                      width: 44.r,
                      height: 44.r,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (alreadyJoined)
                    Text(
                      S.of(context).teamMemberAlreadyJoined,
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: controller.inviteMember,
                      style: TextButton.styleFrom(
                        minimumSize: Size(72.w, 44.h),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        foregroundColor: AppColors.primary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            S.of(context).teamDetailAddMember,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Icon(Icons.chevron_right_rounded, size: 18.r),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建固定 50 × 50 的用户头像，图片不可用时使用姓名首字兜底。
  Widget _avatar(TeamMemberSummary member) {
    final name = member.name.trim();
    final fallback = Container(
      width: 50.r,
      height: 50.r,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.14),
      child: Text(
        name.isEmpty ? '' : name.substring(0, 1),
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Semantics(
      label: member.name,
      image: true,
      child: SizedBox.square(
        dimension: 50.r,
        child: ClipOval(
          child: AvatarImage(source: member.avatarUrl, fallback: fallback),
        ),
      ),
    );
  }

  /// 构建无结果或权限提示，使用标题和说明建立清晰层级。
  Widget _stateMessage({
    required IconData icon,
    required String title,
    String? description,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 44.h, 24.w, 0),
      child: Column(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.divider.withValues(alpha: 0.7),
            ),
            child: Icon(icon, size: 26.r, color: AppColors.textSecondary),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description != null) ...[
            SizedBox(height: 7.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 路由参数无效或非创建者访问时展示只读权限提示。
  Widget _permissionDenied(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: _stateMessage(
          icon: Icons.lock_outline_rounded,
          title: S.of(context).teamMemberAddPermissionDenied,
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}
