// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(Object actorName, Object teamName) =>
      "${actorName} 邀请你加入「${teamName}」";

  static String m1(Object actorName, Object taskTitle) =>
      "${actorName} 提交完成「${taskTitle}」";

  static String m2(Object note) => "说明：${note}";

  // m3 将本地化后的永久删除时间插入预约状态说明。
  static String m3(Object deletionTime) =>
      "账号将在 ${deletionTime} 永久删除。在此之前可以撤销，也可以选择立即删除。";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutDescription": MessageLookupByLibrary.simpleMessage("专注于团队任务分配与协作管理"),
    "aboutVersion": MessageLookupByLibrary.simpleMessage("版本 1.0.0（Build 1）"),
    "appName": MessageLookupByLibrary.simpleMessage("Co Here"),
    "appSettingsCacheCleared": MessageLookupByLibrary.simpleMessage("缓存已清除"),
    "appSettingsCacheDescription": MessageLookupByLibrary.simpleMessage(
      "仅清理临时文件，不会删除登录状态、账号数据或应用设置。",
    ),
    "appSettingsCacheSection": MessageLookupByLibrary.simpleMessage("缓存管理"),
    "appSettingsCacheSize": MessageLookupByLibrary.simpleMessage("当前缓存"),
    "appSettingsCalculatingCache": MessageLookupByLibrary.simpleMessage(
      "正在计算缓存大小",
    ),
    "appSettingsClearCache": MessageLookupByLibrary.simpleMessage("清除缓存"),
    "appSettingsClearCacheAction": MessageLookupByLibrary.simpleMessage("清除"),
    "appSettingsClearCacheConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "清理后部分图片和数据可能需要重新加载，但不会退出登录。",
    ),
    "appSettingsClearCacheConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "清除临时缓存？",
    ),
    "appSettingsCollaborationMessages": MessageLookupByLibrary.simpleMessage(
      "团队协作消息",
    ),
    "appSettingsDueReminder": MessageLookupByLibrary.simpleMessage("截止时间提醒"),
    "appSettingsFollowSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "appSettingsFollowSystemDescription": MessageLookupByLibrary.simpleMessage(
      "自动使用设备当前语言",
    ),
    "appSettingsLanguageSection": MessageLookupByLibrary.simpleMessage("应用语言"),
    "appSettingsLoadingNotifications": MessageLookupByLibrary.simpleMessage(
      "正在加载通知设置",
    ),
    "appSettingsNotificationSection": MessageLookupByLibrary.simpleMessage(
      "通知设置",
    ),
    "appSettingsNotificationsEnabled": MessageLookupByLibrary.simpleMessage(
      "接收通知",
    ),
    "appSettingsNotificationsEnabledDescription":
        MessageLookupByLibrary.simpleMessage("关闭后将暂停 Co Here 的所有通知"),
    "appSettingsSimplifiedChinese": MessageLookupByLibrary.simpleMessage(
      "简体中文",
    ),
    "appSettingsStatusOff": MessageLookupByLibrary.simpleMessage("已关闭"),
    "appSettingsStatusOn": MessageLookupByLibrary.simpleMessage("已开启"),
    "appSettingsTaskAssigned": MessageLookupByLibrary.simpleMessage("任务分配通知"),
    "appSettingsThemeDark": MessageLookupByLibrary.simpleMessage("深色模式"),
    "appSettingsThemeLight": MessageLookupByLibrary.simpleMessage("浅色模式"),
    "appSettingsThemeSection": MessageLookupByLibrary.simpleMessage("深色模式"),
    "appSettingsThemeSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "authAccountNotFound": MessageLookupByLibrary.simpleMessage("账号或密码错误"),
    "authEmailHint": MessageLookupByLibrary.simpleMessage("name@company.com"),
    "authEmailLabel": MessageLookupByLibrary.simpleMessage("邮箱"),
    "authEmailLogin": MessageLookupByLibrary.simpleMessage("邮箱登录"),
    "authEmptyPassword": MessageLookupByLibrary.simpleMessage("请输入密码"),
    "authLegalAcceptanceAnd": MessageLookupByLibrary.simpleMessage("和"),
    "authLegalAcceptancePrefix": MessageLookupByLibrary.simpleMessage(
      "我已阅读并同意",
    ),
    "authLegalAcceptanceRequired": MessageLookupByLibrary.simpleMessage(
      "请先阅读并同意用户协议和隐私政策",
    ),
    "legalDocumentOpenFailed": MessageLookupByLibrary.simpleMessage(
      "无法打开协议链接，请稍后重试",
    ),
    "authEnterpriseLogin": MessageLookupByLibrary.simpleMessage("使用企业账号登录"),
    "authForgotPassword": MessageLookupByLibrary.simpleMessage("忘记密码?"),
    "authInvalidEmail": MessageLookupByLibrary.simpleMessage("请输入正确的邮箱"),
    "authInvalidPassword": MessageLookupByLibrary.simpleMessage("账号或密码错误"),
    "authInvalidPhone": MessageLookupByLibrary.simpleMessage("请输入正确的国际手机号"),
    "authLoginPending": MessageLookupByLibrary.simpleMessage("登录逻辑待接入"),
    "authLoginSuccess": MessageLookupByLibrary.simpleMessage("登录成功"),
    "authLoginTitle": MessageLookupByLibrary.simpleMessage("登录"),
    "authNoAccount": MessageLookupByLibrary.simpleMessage("还没有账号?"),
    "authOr": MessageLookupByLibrary.simpleMessage("OR"),
    "authPasswordHint": MessageLookupByLibrary.simpleMessage("••••••••"),
    "authPasswordLabel": MessageLookupByLibrary.simpleMessage("密码"),
    "authPhoneHint": MessageLookupByLibrary.simpleMessage("请输入手机号码"),
    "authPhoneLabel": MessageLookupByLibrary.simpleMessage("手机号"),
    "authPhoneLogin": MessageLookupByLibrary.simpleMessage("手机号登录"),
    "authRegister": MessageLookupByLibrary.simpleMessage("立即注册"),
    "authSignIn": MessageLookupByLibrary.simpleMessage("登录"),
    "dashboardDueToday": MessageLookupByLibrary.simpleMessage("今日截止"),
    "dashboardInProgress": MessageLookupByLibrary.simpleMessage("进行中"),
    "dashboardMyTasks": MessageLookupByLibrary.simpleMessage("我的任务"),
    "dashboardPriorityHigh": MessageLookupByLibrary.simpleMessage("高优先级"),
    "dashboardReadyForToday": MessageLookupByLibrary.simpleMessage(
      "READY FOR TODAY?",
    ),
    "dashboardSearchPending": MessageLookupByLibrary.simpleMessage("搜索功能待接入"),
    "dashboardStatusInProgress": MessageLookupByLibrary.simpleMessage("进行中"),
    "dashboardStatusUrgent": MessageLookupByLibrary.simpleMessage("紧迫"),
    "dashboardTaskDesignReview": MessageLookupByLibrary.simpleMessage(
      "星河 2.0 界面设计评审",
    ),
    "dashboardTaskFeedbackDocs": MessageLookupByLibrary.simpleMessage(
      "客户反馈文档整理",
    ),
    "dashboardTaskQuarterReport": MessageLookupByLibrary.simpleMessage(
      "季度报告初稿提交",
    ),
    "dashboardTaskQuarterReportTime": MessageLookupByLibrary.simpleMessage(
      "今天截止 06:00 PM",
    ),
    "dashboardTeamName": MessageLookupByLibrary.simpleMessage("星河团队"),
    "dashboardTeamSubtitle": MessageLookupByLibrary.simpleMessage("Star Team"),
    "dashboardTitle": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardTodayTasks": MessageLookupByLibrary.simpleMessage("今日待办"),
    "dashboardTodayTasksSubtitle": MessageLookupByLibrary.simpleMessage(
      "Today’s Tasks",
    ),
    "dashboardUnread": MessageLookupByLibrary.simpleMessage("未读通知"),
    "dashboardUserName": MessageLookupByLibrary.simpleMessage("Alex"),
    "dashboardViewAll": MessageLookupByLibrary.simpleMessage("全部"),
    "dashboardViewAllPending": MessageLookupByLibrary.simpleMessage("全部任务待接入"),
    "dashboardWorkplace": MessageLookupByLibrary.simpleMessage("工作台"),
    "description": MessageLookupByLibrary.simpleMessage("轻松协作，高效完成"),
    "mainTabHome": MessageLookupByLibrary.simpleMessage("首页"),
    "mainTabProfile": MessageLookupByLibrary.simpleMessage("我的"),
    "mainTabTeams": MessageLookupByLibrary.simpleMessage("团队"),
    "notificationAcceptInvitation": MessageLookupByLibrary.simpleMessage(
      "接受邀请",
    ),
    "notificationAccepted": MessageLookupByLibrary.simpleMessage("已接受"),
    "notificationCenterTitle": MessageLookupByLibrary.simpleMessage("通知中心"),
    "notificationConfirmTask": MessageLookupByLibrary.simpleMessage("确认完成"),
    "notificationConfirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "notificationEmpty": MessageLookupByLibrary.simpleMessage("暂无通知"),
    "notificationHandled": MessageLookupByLibrary.simpleMessage("通知处理成功"),
    "notificationInvitationMessage": m0,
    "notificationPending": MessageLookupByLibrary.simpleMessage("待处理"),
    "notificationProcessed": MessageLookupByLibrary.simpleMessage("已处理"),
    "notificationReject": MessageLookupByLibrary.simpleMessage("拒绝"),
    "notificationRejected": MessageLookupByLibrary.simpleMessage("已拒绝"),
    "notificationTaskCompletion": MessageLookupByLibrary.simpleMessage("完成确认"),
    "notificationTaskMessage": m1,
    "notificationTaskNote": m2,
    "notificationTeamInvitation": MessageLookupByLibrary.simpleMessage("团队邀请"),
    "profileAbout": MessageLookupByLibrary.simpleMessage("关于我们"),
    "profileAccountActive": MessageLookupByLibrary.simpleMessage("正常"),
    "profileAccountInfo": MessageLookupByLibrary.simpleMessage("账号信息"),
    "profileAccountSection": MessageLookupByLibrary.simpleMessage("账户"),
    "profileAccountSecurity": MessageLookupByLibrary.simpleMessage("账号与安全"),
    "profileAccountStatus": MessageLookupByLibrary.simpleMessage("账号状态"),
    "profileAppSettings": MessageLookupByLibrary.simpleMessage("应用设置"),
    "profileAvatar": MessageLookupByLibrary.simpleMessage("头像"),
    "profileAvatarEditPending": MessageLookupByLibrary.simpleMessage(
      "头像选择与上传功能待接入",
    ),
    "profileAvatarPickFailed": MessageLookupByLibrary.simpleMessage(
      "无法读取所选图片，请检查相册权限后重试",
    ),
    "profileAvatarSelected": MessageLookupByLibrary.simpleMessage("保存后上传"),
    "profileAvatarTooLarge": MessageLookupByLibrary.simpleMessage(
      "头像图片不能超过 5 MB",
    ),
    "profileAvatarUploadFailed": MessageLookupByLibrary.simpleMessage(
      "头像上传失败，请重试",
    ),
    "profileAvatarUploading": MessageLookupByLibrary.simpleMessage("正在上传头像…"),
    "profileBirthday": MessageLookupByLibrary.simpleMessage("生日"),
    "profileCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "profileCancelDeletion": MessageLookupByLibrary.simpleMessage("撤销删除"),
    "profileChangePassword": MessageLookupByLibrary.simpleMessage("修改密码"),
    "profileConfirmChangePassword": MessageLookupByLibrary.simpleMessage(
      "确认修改",
    ),
    "profileConfirmLogout": MessageLookupByLibrary.simpleMessage("退出"),
    "profileConfirmPermanentDeletion": MessageLookupByLibrary.simpleMessage(
      "永久删除",
    ),
    "profileConfirmNewPassword": MessageLookupByLibrary.simpleMessage("确认新密码"),
    "profileCopyUserId": MessageLookupByLibrary.simpleMessage("复制用户 ID"),
    "profileCurrentDevice": MessageLookupByLibrary.simpleMessage("当前设备"),
    "profileCurrentPassword": MessageLookupByLibrary.simpleMessage("当前密码"),
    "profileCurrentPasswordIncorrect": MessageLookupByLibrary.simpleMessage(
      "当前密码错误",
    ),
    "profileDeleteAccount": MessageLookupByLibrary.simpleMessage("删除账号"),
    "profileDeleteAfterFifteenDays": MessageLookupByLibrary.simpleMessage(
      "15 天后删除",
    ),
    "profileDeleteAfterFifteenDaysDescription":
        MessageLookupByLibrary.simpleMessage(
          "从现在开始保留 15 天冷静期，在页面显示的删除时间前可以随时撤销。",
        ),
    "profileDeleteImmediately": MessageLookupByLibrary.simpleMessage("立即删除"),
    "profileDeleteImmediatelyConfirmMessage":
        MessageLookupByLibrary.simpleMessage(
          "账号、头像、个人数据以及你创建的团队和任务将被立即永久删除，此操作不可撤销。",
        ),
    "profileDeleteImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "立即永久删除账号，此操作不可撤销。",
    ),
    "profileDeleteImmediatelyTitle": MessageLookupByLibrary.simpleMessage(
      "永久删除账号？",
    ),
    "profileDeletionCancelledSuccess": MessageLookupByLibrary.simpleMessage(
      "已撤销账号删除",
    ),
    "profileDeletionChoiceMessage": MessageLookupByLibrary.simpleMessage(
      "请选择永久删除账号的时间。账号、头像、个人数据以及你创建的团队和任务都将被删除。",
    ),
    "profileDeletionScheduledMessage": m3,
    "profileDeletionScheduledSuccess": MessageLookupByLibrary.simpleMessage(
      "账号删除已预约",
    ),
    "profileDeletionScheduledTitle": MessageLookupByLibrary.simpleMessage(
      "账号删除已预约",
    ),
    "profileDeletionStatusRetry": MessageLookupByLibrary.simpleMessage(
      "删除状态加载失败，点击重试",
    ),
    "profileDeviceDescription": MessageLookupByLibrary.simpleMessage(
      "登录设备由服务器统一管理。退出其他设备后，对应设备需要重新登录。",
    ),
    "profileDeviceEmpty": MessageLookupByLibrary.simpleMessage("当前没有有效的登录设备"),
    "profileDeviceLastActive": MessageLookupByLibrary.simpleMessage("最近活跃"),
    "profileDeviceLoadFailed": MessageLookupByLibrary.simpleMessage("登录设备加载失败"),
    "profileDeviceLoading": MessageLookupByLibrary.simpleMessage("正在加载登录设备"),
    "profileDeviceLoggedOut": MessageLookupByLibrary.simpleMessage("设备已退出登录"),
    "profileDeviceLogout": MessageLookupByLibrary.simpleMessage("退出"),
    "profileDisplayName": MessageLookupByLibrary.simpleMessage("昵称"),
    "profileDisplayNameHint": MessageLookupByLibrary.simpleMessage("请输入昵称"),
    "profileDisplayNameRequired": MessageLookupByLibrary.simpleMessage("请输入昵称"),
    "profileEditAvatar": MessageLookupByLibrary.simpleMessage("修改头像"),
    "profileEditTitle": MessageLookupByLibrary.simpleMessage("编辑个人资料"),
    "profileEmail": MessageLookupByLibrary.simpleMessage("邮箱"),
    "profileGender": MessageLookupByLibrary.simpleMessage("性别"),
    "profileGenderFemale": MessageLookupByLibrary.simpleMessage("女"),
    "profileGenderMale": MessageLookupByLibrary.simpleMessage("男"),
    "profileGenderUnspecified": MessageLookupByLibrary.simpleMessage("不透露"),
    "profileHasTeam": MessageLookupByLibrary.simpleMessage("已加入团队"),
    "profileLoginDevices": MessageLookupByLibrary.simpleMessage("登录设备"),
    "profileLogout": MessageLookupByLibrary.simpleMessage("退出登录"),
    "profileLogoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "退出后需要重新登录才能继续使用。",
    ),
    "profileLogoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "确认退出登录？",
    ),
    "profileLogoutCurrentDevice": MessageLookupByLibrary.simpleMessage(
      "退出当前设备",
    ),
    "profileLogoutSubtitle": MessageLookupByLibrary.simpleMessage("LOG OUT"),
    "profileMyProjects": MessageLookupByLibrary.simpleMessage("我的项目"),
    "profileMyProjectsSubtitle": MessageLookupByLibrary.simpleMessage(
      "MY PROJECTS",
    ),
    "profileMyTasksSubtitle": MessageLookupByLibrary.simpleMessage("MY TASKS"),
    "profileMyTeamsSubtitle": MessageLookupByLibrary.simpleMessage("MY TEAMS"),
    "profileNewPassword": MessageLookupByLibrary.simpleMessage("新密码"),
    "profileNoTeam": MessageLookupByLibrary.simpleMessage("暂未加入团队"),
    "profileNotSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "profileOtherSection": MessageLookupByLibrary.simpleMessage("其他"),
    "profilePageSubtitle": MessageLookupByLibrary.simpleMessage("PROFILE"),
    "profilePasswordChanged": MessageLookupByLibrary.simpleMessage(
      "密码已修改，请使用新密码重新登录",
    ),
    "profilePasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "两次输入的新密码不一致",
    ),
    "profilePasswordRequired": MessageLookupByLibrary.simpleMessage(
      "请完整填写三个密码字段",
    ),
    "profilePasswordRequirement": MessageLookupByLibrary.simpleMessage(
      "新密码至少需要 6 位字符。",
    ),
    "profilePasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "新密码不能少于 6 位",
    ),
    "profilePasswordUnchanged": MessageLookupByLibrary.simpleMessage(
      "新密码不能与当前密码相同",
    ),
    "profilePhone": MessageLookupByLibrary.simpleMessage("手机号"),
    "profilePrivacy": MessageLookupByLibrary.simpleMessage("隐私政策"),
    "profilePrivacySubtitle": MessageLookupByLibrary.simpleMessage(
      "PRIVACY POLICY",
    ),
    "profileRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "profileSave": MessageLookupByLibrary.simpleMessage("保存"),
    "profileSaveSuccess": MessageLookupByLibrary.simpleMessage("个人资料已更新"),
    "profileSearchPending": MessageLookupByLibrary.simpleMessage("搜索功能待接入"),
    "profileSettings": MessageLookupByLibrary.simpleMessage("设置"),
    "profileSettingsSubtitle": MessageLookupByLibrary.simpleMessage("SETTINGS"),
    "profileSignedIn": MessageLookupByLibrary.simpleMessage("已登录"),
    "profileTeamStatus": MessageLookupByLibrary.simpleMessage("团队状态"),
    "profileTerms": MessageLookupByLibrary.simpleMessage("用户协议"),
    "profileTermsSubtitle": MessageLookupByLibrary.simpleMessage(
      "USER AGREEMENT",
    ),
    "profileUserId": MessageLookupByLibrary.simpleMessage("用户 ID"),
    "profileUserIdCopied": MessageLookupByLibrary.simpleMessage("用户 ID 已复制"),
    "profileUserIdHelp": MessageLookupByLibrary.simpleMessage("用于团队和项目添加成员"),
    "profileUserIdUnavailable": MessageLookupByLibrary.simpleMessage(
      "用户 ID 暂不可用",
    ),
    "registerAccountAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
      "该手机号或邮箱已注册",
    ),
    "registerBackToLogin": MessageLookupByLibrary.simpleMessage("返回登录"),
    "registerConfirmPasswordHint": MessageLookupByLibrary.simpleMessage(
      "再次输入密码",
    ),
    "registerConfirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "确认密码",
    ),
    "registerCreateAccount": MessageLookupByLibrary.simpleMessage("创建账号"),
    "registerEmailAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
      "邮箱已注册",
    ),
    "registerEmailCodeHint": MessageLookupByLibrary.simpleMessage("6 位验证码"),
    "registerEmailCodeLabel": MessageLookupByLibrary.simpleMessage("验证码"),
    "registerEmailCodePending": MessageLookupByLibrary.simpleMessage(
      "验证码发送失败，请稍后重试",
    ),
    "registerEmptyConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "请确认密码",
    ),
    "registerEmptyEmailCode": MessageLookupByLibrary.simpleMessage("请输入验证码"),
    "registerHaveAccount": MessageLookupByLibrary.simpleMessage("已有账号?"),
    "registerInvalidEmailCode": MessageLookupByLibrary.simpleMessage(
      "验证码错误或已过期",
    ),
    "registerCodeSent": MessageLookupByLibrary.simpleMessage("验证码已发送"),
    "registerPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "两次输入的密码不一致",
    ),
    "registerPending": MessageLookupByLibrary.simpleMessage("注册逻辑待接入"),
    "registerSendCode": MessageLookupByLibrary.simpleMessage("获取验证码"),
    "registerSendEmailCode": MessageLookupByLibrary.simpleMessage("获取验证码"),
    "registerSubtitle": MessageLookupByLibrary.simpleMessage(
      "使用工作邮箱和安全密码开始协作。",
    ),
    "registerSuccess": MessageLookupByLibrary.simpleMessage("注册成功"),
    "registerTitle": MessageLookupByLibrary.simpleMessage("创建账号"),
    "resetPasswordAccountNotFound": MessageLookupByLibrary.simpleMessage(
      "验证码错误或已过期",
    ),
    "resetPasswordAction": MessageLookupByLibrary.simpleMessage("重置密码"),
    "resetPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "请完整填写验证码和两次新密码",
    ),
    "resetPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "验证注册手机号或邮箱后设置新的登录密码。",
    ),
    "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "密码已重置，请使用新密码登录",
    ),
    "resetPasswordTitle": MessageLookupByLibrary.simpleMessage("找回密码"),
    "taskActionComplete": MessageLookupByLibrary.simpleMessage("完成"),
    "taskActionCompletedSuccess": MessageLookupByLibrary.simpleMessage(
      "完成情况已提交",
    ),
    "taskActionNoteHint": MessageLookupByLibrary.simpleMessage("补充完成情况或延后原因"),
    "taskActionNoteLabel": MessageLookupByLibrary.simpleMessage("情况说明（选填）"),
    "taskActionPostpone": MessageLookupByLibrary.simpleMessage("延后"),
    "taskActionPostponedSuccess": MessageLookupByLibrary.simpleMessage("任务已延后"),
    "taskActionUpdating": MessageLookupByLibrary.simpleMessage("正在更新任务状态..."),
    "taskActionViewDetails": MessageLookupByLibrary.simpleMessage("查看详情"),
    "taskDetailEndTime": MessageLookupByLibrary.simpleMessage("结束时间"),
    "taskDetailGroupChat": MessageLookupByLibrary.simpleMessage("任务群聊"),
    "taskDetailOpenGroup": MessageLookupByLibrary.simpleMessage("进入群聊"),
    "taskDetailRetryGroup": MessageLookupByLibrary.simpleMessage("创建群聊"),
    "taskDetailDelete": MessageLookupByLibrary.simpleMessage("删除任务"),
    "taskDetailDeleteConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "删除任务？",
    ),
    "taskDetailDeleteConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "删除任务将同时解散关联群聊，此操作需要群主确认。",
    ),
    "taskDetailCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "taskDetailConfirmDelete": MessageLookupByLibrary.simpleMessage("确认删除"),
    "taskDetailDeleteSuccess": MessageLookupByLibrary.simpleMessage("任务已删除"),
    "taskDetailInvalid": MessageLookupByLibrary.simpleMessage("无法加载任务详情"),
    "taskDetailNoAssignees": MessageLookupByLibrary.simpleMessage("暂无负责人"),
    "taskDetailAddAssignees": MessageLookupByLibrary.simpleMessage("添加负责人"),
    "taskDetailStartTime": MessageLookupByLibrary.simpleMessage("开始时间"),
    "taskDetailTitle": MessageLookupByLibrary.simpleMessage("任务详情"),
    "taskEmpty": MessageLookupByLibrary.simpleMessage("暂无符合条件的任务"),
    "teamContinue": MessageLookupByLibrary.simpleMessage("继续"),
    "teamCreateCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "teamCreateDescription": MessageLookupByLibrary.simpleMessage(
      "邀请成员、管理项目，并从一个统一空间开始协作。",
    ),
    "teamCreateDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "简单说明这个团队负责什么",
    ),
    "teamCreateDescriptionLabel": MessageLookupByLibrary.simpleMessage("团队描述"),
    "teamCreateDialogSubtitle": MessageLookupByLibrary.simpleMessage(
      "填写团队基础信息，图片可以稍后再补充。",
    ),
    "teamCreateDialogTitle": MessageLookupByLibrary.simpleMessage("创建团队"),
    "teamCreateImageCaption": MessageLookupByLibrary.simpleMessage("可稍后补充"),
    "teamCreateImageHint": MessageLookupByLibrary.simpleMessage("点击选择团队图片"),
    "teamCreateImageLabel": MessageLookupByLibrary.simpleMessage("团队图片（可选）"),
    "teamCreateImageOptional": MessageLookupByLibrary.simpleMessage(
      "当前未接入图片选择，可以直接创建",
    ),
    "teamCreateImagePageHint": MessageLookupByLibrary.simpleMessage(
      "上传头像能帮助成员更快识别团队，也可以稍后再补充。",
    ),
    "teamCreateImagePickerPending": MessageLookupByLibrary.simpleMessage(
      "图片选择待接入",
    ),
    "teamCreateImageSelected": MessageLookupByLibrary.simpleMessage("已选择团队图片"),
    "teamCreateNameHint": MessageLookupByLibrary.simpleMessage("请输入团队名称"),
    "teamCreateNameLabel": MessageLookupByLibrary.simpleMessage("团队名称"),
    "teamCreateNameRequired": MessageLookupByLibrary.simpleMessage("请输入团队名称"),
    "teamCreatePageNote": MessageLookupByLibrary.simpleMessage(
      "团队名称和描述后续都可以在团队设置中修改。",
    ),
    "teamCreatePending": MessageLookupByLibrary.simpleMessage("创建团队逻辑待接入"),
    "teamCreateScreenSubtitle": MessageLookupByLibrary.simpleMessage(
      "填写基础信息，创建后可通过用户 ID 添加成员。",
    ),
    "teamCreateScreenTitle": MessageLookupByLibrary.simpleMessage("创建你的团队"),
    "teamCreateSubmit": MessageLookupByLibrary.simpleMessage("创建"),
    "teamCreateSubtitle": MessageLookupByLibrary.simpleMessage("建立新的工作空间"),
    "teamCreateSuccess": MessageLookupByLibrary.simpleMessage("团队创建成功"),
    "teamCreateTitle": MessageLookupByLibrary.simpleMessage("创建团队"),
    "teamDetailAddMember": MessageLookupByLibrary.simpleMessage("邀请成员"),
    "teamDetailAddMemberDescription": MessageLookupByLibrary.simpleMessage(
      "输入用户 ID、邮箱或手机号，向对方发送团队邀请。",
    ),
    "teamDetailAddMemberPending": MessageLookupByLibrary.simpleMessage(
      "添加成员功能待接入",
    ),
    "teamDetailAllTasks": MessageLookupByLibrary.simpleMessage("全部任务"),
    "teamDetailAssignees": MessageLookupByLibrary.simpleMessage("负责人"),
    "teamDetailCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "teamDetailCreateTask": MessageLookupByLibrary.simpleMessage("创建任务"),
    "teamDetailCreatorBadge": MessageLookupByLibrary.simpleMessage("创建者"),
    "teamDetailDeadline": MessageLookupByLibrary.simpleMessage("截止时间"),
    "teamDetailIntroduction": MessageLookupByLibrary.simpleMessage("团队介绍"),
    "teamDetailMemberAdded": MessageLookupByLibrary.simpleMessage("团队邀请已发送"),
    "teamDetailMemberUserIdHint": MessageLookupByLibrary.simpleMessage(
      "用户 ID / 邮箱 / 国际手机号",
    ),
    "teamDetailMemberUserIdRequired": MessageLookupByLibrary.simpleMessage(
      "请输入用户 ID、邮箱或国际手机号",
    ),
    "teamDetailNoIntroduction": MessageLookupByLibrary.simpleMessage("暂无团队介绍"),
    "teamDetailNoTaskDescription": MessageLookupByLibrary.simpleMessage(
      "暂无任务描述",
    ),
    "teamDetailNoTasks": MessageLookupByLibrary.simpleMessage("暂无细分任务"),
    "teamDetailPending": MessageLookupByLibrary.simpleMessage("待完成"),
    "teamDetailProgress": MessageLookupByLibrary.simpleMessage("完成情况"),
    "teamDetailSelectAssignees": MessageLookupByLibrary.simpleMessage(
      "选择负责人（可多选）",
    ),
    "teamDetailTaskClearStartTime": MessageLookupByLibrary.simpleMessage(
      "清除开始时间",
    ),
    "teamDetailTaskCreated": MessageLookupByLibrary.simpleMessage("任务创建成功"),
    "teamDetailTaskDate": MessageLookupByLibrary.simpleMessage("截止日期"),
    "teamDetailTaskDateHint": MessageLookupByLibrary.simpleMessage("请选择日期"),
    "teamDetailTaskDescription": MessageLookupByLibrary.simpleMessage("任务描述"),
    "teamDetailTaskDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "请输入任务具体内容",
    ),
    "teamDetailTaskEndTime": MessageLookupByLibrary.simpleMessage("结束时间（必选）"),
    "teamDetailTaskInfo": MessageLookupByLibrary.simpleMessage("任务信息"),
    "teamDetailTaskPastTime": MessageLookupByLibrary.simpleMessage(
      "结束时间不能早于当前时间",
    ),
    "teamDetailTaskRequired": MessageLookupByLibrary.simpleMessage(
      "请填写任务信息、结束时间并选择负责人",
    ),
    "teamDetailTaskSelectEndTime": MessageLookupByLibrary.simpleMessage(
      "选择结束时间",
    ),
    "teamDetailTaskSelectStartTime": MessageLookupByLibrary.simpleMessage(
      "选择开始时间",
    ),
    "teamDetailTaskStartPastTime": MessageLookupByLibrary.simpleMessage(
      "开始时间不能早于当前时间",
    ),
    "teamDetailTaskStartTime": MessageLookupByLibrary.simpleMessage("开始时间（可选）"),
    "teamDetailTaskTime": MessageLookupByLibrary.simpleMessage("任务时间"),
    "teamDetailTaskTimeHint": MessageLookupByLibrary.simpleMessage("请选择时间"),
    "teamDetailTaskTimeRangeInvalid": MessageLookupByLibrary.simpleMessage(
      "结束时间必须晚于开始时间",
    ),
    "teamDetailTaskTitle": MessageLookupByLibrary.simpleMessage("任务名称"),
    "teamDetailTaskTitleHint": MessageLookupByLibrary.simpleMessage("请输入任务名称"),
    "teamDetailTasks": MessageLookupByLibrary.simpleMessage("细分任务"),
    "teamDetailViewAll": MessageLookupByLibrary.simpleMessage("查看全部"),
    "teamGuidePending": MessageLookupByLibrary.simpleMessage("团队指南待接入"),
    "teamGuideQuestion": MessageLookupByLibrary.simpleMessage("不确定怎么选择?"),
    "teamJoinDescription": MessageLookupByLibrary.simpleMessage(
      "通过团队邀请或邀请码加入同事已经创建的工作空间。",
    ),
    "teamJoinSubtitle": MessageLookupByLibrary.simpleMessage("进入已有工作空间"),
    "teamJoinTitle": MessageLookupByLibrary.simpleMessage("加入团队"),
    "teamListCreatedAt": MessageLookupByLibrary.simpleMessage("创建于"),
    "teamListCreator": MessageLookupByLibrary.simpleMessage("创建人"),
    "teamListEmpty": MessageLookupByLibrary.simpleMessage("暂无团队"),
    "teamListLongTerm": MessageLookupByLibrary.simpleMessage("长期"),
    "teamListMembers": MessageLookupByLibrary.simpleMessage("团队成员"),
    "teamListPeriod": MessageLookupByLibrary.simpleMessage("起止日期"),
    "teamMemberAddPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "只有团队创建者可以邀请成员",
    ),
    "teamMemberAlreadyJoined": MessageLookupByLibrary.simpleMessage("已在团队"),
    "teamMemberSearchAction": MessageLookupByLibrary.simpleMessage("搜索"),
    "teamMemberSearchGuide": MessageLookupByLibrary.simpleMessage(
      "可通过用户 ID、注册邮箱或完整国际手机号查找",
    ),
    "teamMemberSearchNoResult": MessageLookupByLibrary.simpleMessage(
      "未找到该用户，请检查用户 ID、邮箱或国际手机号后重试",
    ),
    "teamMemberSearchNoResultTitle": MessageLookupByLibrary.simpleMessage(
      "未找到该用户",
    ),
    "teamMemberSearchResult": MessageLookupByLibrary.simpleMessage("搜索结果"),
    "teamOnboardingSuccess": MessageLookupByLibrary.simpleMessage("团队设置完成"),
    "teamPassiveJoinDescription": MessageLookupByLibrary.simpleMessage(
      "无需主动申请加入。团队管理员通过用户 ID 添加你后，团队会自动出现在列表中。",
    ),
    "teamSkip": MessageLookupByLibrary.simpleMessage("跳过"),
    "teamStartSubtitle": MessageLookupByLibrary.simpleMessage("选择你的工作方式"),
    "teamStartTitle": MessageLookupByLibrary.simpleMessage("开始团队协作"),
    "teamViewGuide": MessageLookupByLibrary.simpleMessage("查看指南"),
  };
}
