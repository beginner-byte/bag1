import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:work_module/app/theme/app.color.dart';
import 'package:work_module/core/model/team/team.item.model.dart';
import 'package:work_module/shared/l10n/generated/l10n.dart';
import 'package:work_module/shared/widgets/avatar.image.dart';

/// 团队列表卡片，展示团队归属、成员和时间范围。
class TeamCell extends StatelessWidget {
  /// 创建团队卡片，[team] 提供展示数据，[onTap] 处理点击事件。
  const TeamCell({required this.team, required this.onTap, super.key});

  /// 创建与真实团队卡片同结构的骨架占位内容。
  factory TeamCell.skeleton({Key? key}) {
    return TeamCell(
      key: key,
      team: TeamItem(
        id: 'skeleton-team',
        name: '这是一个团队名称占位',
        creator: const TeamMemberSummary(
          id: 'skeleton-creator',
          name: '创建人姓名',
          avatarUrl: '',
        ),
        members: const [
          TeamMemberSummary(
            id: 'skeleton-member-1',
            name: '成员一',
            avatarUrl: '',
          ),
          TeamMemberSummary(
            id: 'skeleton-member-2',
            name: '成员二',
            avatarUrl: '',
          ),
          TeamMemberSummary(
            id: 'skeleton-member-3',
            name: '成员三',
            avatarUrl: '',
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      ),
      onTap: _emptyCallback,
    );
  }

  /// 当前团队数据。
  final TeamItem team;

  /// 用户点击卡片时执行的回调。
  final VoidCallback onTap;

  /// 骨架占位卡片的空回调，实际交互会由 Skeletonizer 禁用。
  static void _emptyCallback() {}

  /// 构建可点击的团队信息卡片。
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.75),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 14.h),
              _creator(context),
              SizedBox(height: 16.h),
              Divider(height: 1.h, color: AppColors.divider),
              SizedBox(height: 14.h),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建团队名称和详情方向提示。
  Widget _header() {
    return Row(
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(
            Icons.groups_2_outlined,
            color: AppColors.primary,
            size: 23.r,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textDisabled,
          size: 22.r,
        ),
      ],
    );
  }

  /// 构建创建人和创建时间，两端对齐便于快速扫描。
  Widget _creator(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _metadata(
            icon: Icons.person_outline_rounded,
            label: S.of(context).teamListCreator,
            value: team.creator.name,
          ),
        ),
        SizedBox(width: 12.w),
        _metadata(
          icon: Icons.schedule_rounded,
          label: S.of(context).teamListCreatedAt,
          value: _formatDate(team.createdAt),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  /// 构建成员头像预览和团队起止日期。
  Widget _footer(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).teamListMembers, style: _labelStyle()),
              SizedBox(height: 8.h),
              _memberAvatars(),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(S.of(context).teamListPeriod, style: _labelStyle()),
            SizedBox(height: 8.h),
            Text(
              _dateRange(context),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建带图标的辅助信息，统一创建人和时间的层级。
  Widget _metadata({
    required IconData icon,
    required String label,
    required String value,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Text(label, style: _labelStyle()),
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// 构建最多四个重叠头像，其余成员使用 +N 汇总。
  Widget _memberAvatars() {
    const maximumVisibleMembers = 4;
    final visibleCount = math.min(team.members.length, maximumVisibleMembers);
    final remainingCount = team.members.length - visibleCount;
    final itemCount = visibleCount + (remainingCount > 0 ? 1 : 0);

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 32.r + ((itemCount - 1) * 22.r),
      height: 32.r,
      child: Stack(
        children: [
          for (var index = 0; index < visibleCount; index++)
            Positioned(left: index * 22.r, child: _avatar(team.members[index])),
          if (remainingCount > 0)
            Positioned(
              left: visibleCount * 22.r,
              child: _remainingAvatar(remainingCount),
            ),
        ],
      ),
    );
  }

  /// 构建单个成员头像，图片为空或加载失败时使用姓名首字。
  Widget _avatar(TeamMemberSummary member) {
    return Container(
      width: 32.r,
      height: 32.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.14),
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: AvatarImage(
        source: member.avatarUrl,
        fallback: _avatarFallback(member.name),
      ),
    );
  }

  /// 构建姓名首字头像，无姓名时使用成员图标。
  Widget _avatarFallback(String name) {
    final initial = name.trim().isEmpty ? '' : name.trim().substring(0, 1);

    return Center(
      child: initial.isEmpty
          ? Icon(Icons.person_outline_rounded, size: 15.r)
          : Text(
              initial,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  /// 构建未展开成员数量头像。
  Widget _remainingAvatar(int count) {
    return Container(
      width: 32.r,
      height: 32.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutral,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// 格式化日期，缺失时返回短横线保持卡片结构稳定。
  String _formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }

    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  /// 组合团队起止日期，没有结束日期时显示长期。
  String _dateRange(BuildContext context) {
    final startDate = _formatDate(team.startDate);
    final endDate = team.endDate == null
        ? S.of(context).teamListLongTerm
        : _formatDate(team.endDate);

    return '$startDate  ~  $endDate';
  }

  /// 返回团队卡片辅助标题的统一文字样式。
  TextStyle _labelStyle() {
    return TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
    );
  }
}
