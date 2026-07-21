import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:worker/app/route/router.dart';
import 'package:worker/app/theme/app.color.dart';
import 'package:worker/core/model/team/team.item.model.dart';
import 'package:worker/core/service/auth.service.dart';
import 'package:worker/shared/l10n/generated/l10n.dart';
import 'package:worker/shared/mixins/screen.mixin.dart';
import 'package:worker/shared/widgets/avatar.image.dart';

/// 团队成员二级页，完整展示当前团队成员和创建者身份。
class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen>
    with ScreenMixin {
  /// 当前团队参数和进入页面时的成员快照；邀请接受后由下次团队请求更新。
  TeamItem? _team;
  final List<TeamMemberSummary> _members = [];

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;

    if (arguments is TeamItem) {
      _team = arguments;
      _members.addAll(arguments.members);
    }
  }

  /// 当前登录用户是否为本团队创建者。
  bool get _isCreator {
    final currentTeam = _team;
    final userId = Get.find<AuthService>().user?.id ?? '';

    return currentTeam != null &&
        userId.isNotEmpty &&
        currentTeam.creator.id == userId;
  }

  @override
  bool extendBodyBehindAppBar() {
    return false;
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).teamListMembers),
      backgroundColor: AppColors.backgroundGradientStart,
      surfaceTintColor: Colors.transparent,
      actions: [
        if (_isCreator)
          IconButton(
            onPressed: _openAddMember,
            tooltip: S.of(context).teamDetailAddMember,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        if (_isCreator) SizedBox(width: 8.w),
      ],
    );
  }

  /// 构建带成员数量、用户 ID 和创建者标记的完整列表。
  @override
  Widget body(BuildContext context) {
    final currentTeam = _team;

    if (currentTeam == null) {
      return _invalidArguments(context);
    }

    return SafeArea(
      top: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 32.h),
        children: [
          Text(
            '${S.of(context).teamListMembers} (${_members.length})',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              children: [
                for (var index = 0; index < _members.length; index++) ...[
                  _memberRow(context, currentTeam, _members[index]),
                  if (index < _members.length - 1)
                    Padding(
                      padding: EdgeInsets.only(left: 70.w),
                      child: Divider(height: 1.h, color: AppColors.divider),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 打开邀请成员搜索页；接收人接受前不改变当前成员列表。
  Future<void> _openAddMember() async {
    final currentTeam = _team;

    if (!_isCreator || currentTeam == null) {
      return;
    }

    await Get.toNamed(
      GetRouter.addTeamMember,
      arguments: currentTeam.copyWith(
        members: _members.toList(growable: false),
      ),
    );
  }

  /// 构建成员头像、姓名、用户 ID 和创建者标记。
  Widget _memberRow(
    BuildContext context,
    TeamItem currentTeam,
    TeamMemberSummary member,
  ) {
    final isCreator = member.id == currentTeam.creator.id;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(
        children: [
          _memberAvatar(member),
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
                    fontSize: 14.sp,
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
          if (isCreator) ...[
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                S.of(context).teamDetailCreatorBadge,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建成员头像，图片不可用时使用姓名首字。
  Widget _memberAvatar(TeamMemberSummary member) {
    return Semantics(
      label: member.name,
      image: true,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        clipBehavior: Clip.antiAlias,
        child: AvatarImage(
          source: member.avatarUrl,
          fallback: _avatarFallback(member.name),
        ),
      ),
    );
  }

  /// 构建姓名首字头像兜底。
  Widget _avatarFallback(String name) {
    final trimmedName = name.trim();

    return Center(
      child: trimmedName.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              size: 21.r,
              color: AppColors.primary,
            )
          : Text(
              trimmedName.substring(0, 1),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  /// 路由参数无效时展示安全空状态。
  Widget _invalidArguments(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).teamListEmpty,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
