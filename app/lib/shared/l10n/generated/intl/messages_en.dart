// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(Object actorName, Object teamName) =>
      "${actorName} invited you to join \"${teamName}\"";

  static String m1(Object actorName, Object taskTitle) =>
      "${actorName} submitted \"${taskTitle}\" as complete";

  static String m2(Object note) => "Note: ${note}";

  // m3 interpolates the localized permanent deletion deadline.
  static String m3(Object deletionTime) =>
      "Your account will be permanently deleted on ${deletionTime}. You can cancel before then or delete it immediately.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutDescription": MessageLookupByLibrary.simpleMessage(
      "Team task assignment and collaboration management",
    ),
    "aboutVersion": MessageLookupByLibrary.simpleMessage(
      "Version 1.0.0 (Build 1)",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Co Here"),
    "appSettingsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "Cache cleared",
    ),
    "appSettingsCacheDescription": MessageLookupByLibrary.simpleMessage(
      "Only temporary files are removed. Your session, account data, and app settings remain intact.",
    ),
    "appSettingsCacheSection": MessageLookupByLibrary.simpleMessage(
      "Cache management",
    ),
    "appSettingsCacheSize": MessageLookupByLibrary.simpleMessage(
      "Current cache",
    ),
    "appSettingsCalculatingCache": MessageLookupByLibrary.simpleMessage(
      "Calculating cache size",
    ),
    "appSettingsClearCache": MessageLookupByLibrary.simpleMessage(
      "Clear cache",
    ),
    "appSettingsClearCacheAction": MessageLookupByLibrary.simpleMessage(
      "Clear",
    ),
    "appSettingsClearCacheConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Some images and data may need to reload, but you will remain signed in.",
    ),
    "appSettingsClearCacheConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Clear temporary cache?",
    ),
    "appSettingsCollaborationMessages": MessageLookupByLibrary.simpleMessage(
      "Team collaboration messages",
    ),
    "appSettingsDueReminder": MessageLookupByLibrary.simpleMessage(
      "Due date reminders",
    ),
    "appSettingsFollowSystem": MessageLookupByLibrary.simpleMessage(
      "Follow system",
    ),
    "appSettingsFollowSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically use the device language",
    ),
    "appSettingsLanguageSection": MessageLookupByLibrary.simpleMessage(
      "App language",
    ),
    "appSettingsLoadingNotifications": MessageLookupByLibrary.simpleMessage(
      "Loading notification settings",
    ),
    "appSettingsNotificationSection": MessageLookupByLibrary.simpleMessage(
      "Notification settings",
    ),
    "appSettingsNotificationsEnabled": MessageLookupByLibrary.simpleMessage(
      "Receive notifications",
    ),
    "appSettingsNotificationsEnabledDescription":
        MessageLookupByLibrary.simpleMessage(
          "Turn this off to pause all Co Here notifications",
        ),
    "appSettingsSimplifiedChinese": MessageLookupByLibrary.simpleMessage(
      "Simplified Chinese",
    ),
    "appSettingsStatusOff": MessageLookupByLibrary.simpleMessage("Off"),
    "appSettingsStatusOn": MessageLookupByLibrary.simpleMessage("On"),
    "appSettingsTaskAssigned": MessageLookupByLibrary.simpleMessage(
      "Task assignment notifications",
    ),
    "appSettingsThemeDark": MessageLookupByLibrary.simpleMessage("Dark mode"),
    "appSettingsThemeLight": MessageLookupByLibrary.simpleMessage("Light mode"),
    "appSettingsThemeSection": MessageLookupByLibrary.simpleMessage(
      "Dark mode",
    ),
    "appSettingsThemeSystem": MessageLookupByLibrary.simpleMessage(
      "Follow system",
    ),
    "authAccountNotFound": MessageLookupByLibrary.simpleMessage(
      "Incorrect account or password",
    ),
    "authEmailHint": MessageLookupByLibrary.simpleMessage("name@company.com"),
    "authEmailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "authEmailLogin": MessageLookupByLibrary.simpleMessage("Email login"),
    "authEmptyPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter your password",
    ),
    "authLegalAcceptanceAnd": MessageLookupByLibrary.simpleMessage("and"),
    "authLegalAcceptancePrefix": MessageLookupByLibrary.simpleMessage(
      "I have read and agree to",
    ),
    "authLegalAcceptanceRequired": MessageLookupByLibrary.simpleMessage(
      "Please read and accept the User agreement and Privacy policy",
    ),
    "legalDocumentOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to open the document link. Please try again later",
    ),
    "authEnterpriseLogin": MessageLookupByLibrary.simpleMessage(
      "Sign in with enterprise account",
    ),
    "authForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot password?",
    ),
    "authInvalidEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email",
    ),
    "authInvalidPassword": MessageLookupByLibrary.simpleMessage(
      "Incorrect account or password",
    ),
    "authInvalidPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid international phone number",
    ),
    "authLoginPending": MessageLookupByLibrary.simpleMessage(
      "Login flow is not connected yet",
    ),
    "authLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "authLoginTitle": MessageLookupByLibrary.simpleMessage("Login"),
    "authNoAccount": MessageLookupByLibrary.simpleMessage("No account yet?"),
    "authOr": MessageLookupByLibrary.simpleMessage("OR"),
    "authPasswordHint": MessageLookupByLibrary.simpleMessage("••••••••"),
    "authPasswordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "authPhoneHint": MessageLookupByLibrary.simpleMessage(
      "Enter local phone number",
    ),
    "authPhoneLabel": MessageLookupByLibrary.simpleMessage("Phone"),
    "authPhoneLogin": MessageLookupByLibrary.simpleMessage("Phone login"),
    "authRegister": MessageLookupByLibrary.simpleMessage("Register"),
    "authSignIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "dashboardDueToday": MessageLookupByLibrary.simpleMessage("Due today"),
    "dashboardInProgress": MessageLookupByLibrary.simpleMessage("In progress"),
    "dashboardMyTasks": MessageLookupByLibrary.simpleMessage("My tasks"),
    "dashboardPriorityHigh": MessageLookupByLibrary.simpleMessage("High"),
    "dashboardReadyForToday": MessageLookupByLibrary.simpleMessage(
      "READY FOR TODAY?",
    ),
    "dashboardSearchPending": MessageLookupByLibrary.simpleMessage(
      "Search is not connected yet",
    ),
    "dashboardStatusInProgress": MessageLookupByLibrary.simpleMessage("Active"),
    "dashboardStatusUrgent": MessageLookupByLibrary.simpleMessage("Urgent"),
    "dashboardTaskDesignReview": MessageLookupByLibrary.simpleMessage(
      "Galaxy 2.0 UI design review",
    ),
    "dashboardTaskFeedbackDocs": MessageLookupByLibrary.simpleMessage(
      "Customer feedback docs",
    ),
    "dashboardTaskQuarterReport": MessageLookupByLibrary.simpleMessage(
      "Quarter report draft",
    ),
    "dashboardTaskQuarterReportTime": MessageLookupByLibrary.simpleMessage(
      "Due today 06:00 PM",
    ),
    "dashboardTeamName": MessageLookupByLibrary.simpleMessage("Galaxy Team"),
    "dashboardTeamSubtitle": MessageLookupByLibrary.simpleMessage("Star Team"),
    "dashboardTitle": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardTodayTasks": MessageLookupByLibrary.simpleMessage(
      "Today’s Tasks",
    ),
    "dashboardTodayTasksSubtitle": MessageLookupByLibrary.simpleMessage(
      "Today’s Tasks",
    ),
    "dashboardUnread": MessageLookupByLibrary.simpleMessage("Unread"),
    "dashboardUserName": MessageLookupByLibrary.simpleMessage("Alex"),
    "dashboardViewAll": MessageLookupByLibrary.simpleMessage("All"),
    "dashboardViewAllPending": MessageLookupByLibrary.simpleMessage(
      "All tasks is not connected yet",
    ),
    "dashboardWorkplace": MessageLookupByLibrary.simpleMessage("Workspace"),
    "description": MessageLookupByLibrary.simpleMessage("WORK BETTER TOGETHER"),
    "mainTabHome": MessageLookupByLibrary.simpleMessage("Home"),
    "mainTabProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "mainTabTeams": MessageLookupByLibrary.simpleMessage("Teams"),
    "notificationAcceptInvitation": MessageLookupByLibrary.simpleMessage(
      "Accept invitation",
    ),
    "notificationAccepted": MessageLookupByLibrary.simpleMessage("Accepted"),
    "notificationCenterTitle": MessageLookupByLibrary.simpleMessage(
      "Notification center",
    ),
    "notificationConfirmTask": MessageLookupByLibrary.simpleMessage(
      "Confirm completion",
    ),
    "notificationConfirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "notificationEmpty": MessageLookupByLibrary.simpleMessage(
      "No notifications",
    ),
    "notificationHandled": MessageLookupByLibrary.simpleMessage(
      "Notification updated",
    ),
    "notificationInvitationMessage": m0,
    "notificationPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "notificationProcessed": MessageLookupByLibrary.simpleMessage("Processed"),
    "notificationReject": MessageLookupByLibrary.simpleMessage("Reject"),
    "notificationRejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "notificationTaskCompletion": MessageLookupByLibrary.simpleMessage(
      "Completion confirmation",
    ),
    "notificationTaskMessage": m1,
    "notificationTaskNote": m2,
    "notificationTeamInvitation": MessageLookupByLibrary.simpleMessage(
      "Team invitation",
    ),
    "profileAbout": MessageLookupByLibrary.simpleMessage("About us"),
    "profileAccountActive": MessageLookupByLibrary.simpleMessage("Active"),
    "profileAccountInfo": MessageLookupByLibrary.simpleMessage(
      "Account information",
    ),
    "profileAccountSection": MessageLookupByLibrary.simpleMessage("Account"),
    "profileAccountSecurity": MessageLookupByLibrary.simpleMessage(
      "Account & security",
    ),
    "profileAccountStatus": MessageLookupByLibrary.simpleMessage(
      "Account status",
    ),
    "profileAppSettings": MessageLookupByLibrary.simpleMessage("App settings"),
    "profileAvatar": MessageLookupByLibrary.simpleMessage("Photo"),
    "profileAvatarEditPending": MessageLookupByLibrary.simpleMessage(
      "Photo selection and upload are not connected yet",
    ),
    "profileAvatarPickFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read the selected photo. Check photo access and try again.",
    ),
    "profileAvatarSelected": MessageLookupByLibrary.simpleMessage(
      "Uploads when saved",
    ),
    "profileAvatarTooLarge": MessageLookupByLibrary.simpleMessage(
      "Photo must be 5 MB or smaller",
    ),
    "profileAvatarUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Photo upload failed. Try again.",
    ),
    "profileAvatarUploading": MessageLookupByLibrary.simpleMessage(
      "Uploading photo…",
    ),
    "profileBirthday": MessageLookupByLibrary.simpleMessage("Birthday"),
    "profileCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "profileCancelDeletion": MessageLookupByLibrary.simpleMessage(
      "Cancel deletion",
    ),
    "profileChangePassword": MessageLookupByLibrary.simpleMessage(
      "Change password",
    ),
    "profileConfirmChangePassword": MessageLookupByLibrary.simpleMessage(
      "Change password",
    ),
    "profileConfirmLogout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "profileConfirmPermanentDeletion": MessageLookupByLibrary.simpleMessage(
      "Delete permanently",
    ),
    "profileConfirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm new password",
    ),
    "profileCopyUserId": MessageLookupByLibrary.simpleMessage("Copy user ID"),
    "profileCurrentDevice": MessageLookupByLibrary.simpleMessage(
      "Current device",
    ),
    "profileCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Current password",
    ),
    "profileCurrentPasswordIncorrect": MessageLookupByLibrary.simpleMessage(
      "The current password is incorrect",
    ),
    "profileDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Delete account",
    ),
    "profileDeleteAfterFifteenDays": MessageLookupByLibrary.simpleMessage(
      "Delete after 15 days",
    ),
    "profileDeleteAfterFifteenDaysDescription":
        MessageLookupByLibrary.simpleMessage(
          "A 15-day grace period starts now. You can cancel before the displayed deletion time.",
        ),
    "profileDeleteImmediately": MessageLookupByLibrary.simpleMessage(
      "Delete immediately",
    ),
    "profileDeleteImmediatelyConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "This immediately and permanently deletes your account, photo, personal data, and teams and tasks you created. It cannot be undone.",
    ),
    "profileDeleteImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Permanently deletes the account now. This cannot be undone.",
    ),
    "profileDeleteImmediatelyTitle": MessageLookupByLibrary.simpleMessage(
      "Permanently delete account?",
    ),
    "profileDeletionCancelledSuccess": MessageLookupByLibrary.simpleMessage(
      "Account deletion cancelled",
    ),
    "profileDeletionChoiceMessage": MessageLookupByLibrary.simpleMessage(
      "Choose when to permanently delete your account. Your account, photo, personal data, and teams and tasks you created will be removed.",
    ),
    "profileDeletionScheduledMessage": m3,
    "profileDeletionScheduledSuccess": MessageLookupByLibrary.simpleMessage(
      "Account deletion scheduled",
    ),
    "profileDeletionScheduledTitle": MessageLookupByLibrary.simpleMessage(
      "Account deletion scheduled",
    ),
    "profileDeletionStatusRetry": MessageLookupByLibrary.simpleMessage(
      "Couldn’t load deletion status. Tap to retry",
    ),
    "profileDeviceDescription": MessageLookupByLibrary.simpleMessage(
      "Login devices are managed by the server. A signed-out device must sign in again.",
    ),
    "profileDeviceEmpty": MessageLookupByLibrary.simpleMessage(
      "There are no active login devices",
    ),
    "profileDeviceLastActive": MessageLookupByLibrary.simpleMessage(
      "Last active",
    ),
    "profileDeviceLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to load login devices",
    ),
    "profileDeviceLoading": MessageLookupByLibrary.simpleMessage(
      "Loading login devices",
    ),
    "profileDeviceLoggedOut": MessageLookupByLibrary.simpleMessage(
      "Device signed out",
    ),
    "profileDeviceLogout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "profileDisplayName": MessageLookupByLibrary.simpleMessage("Display name"),
    "profileDisplayNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter your display name",
    ),
    "profileDisplayNameRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a display name",
    ),
    "profileEditAvatar": MessageLookupByLibrary.simpleMessage("Change photo"),
    "profileEditTitle": MessageLookupByLibrary.simpleMessage("Edit profile"),
    "profileEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "profileGender": MessageLookupByLibrary.simpleMessage("Gender"),
    "profileGenderFemale": MessageLookupByLibrary.simpleMessage("Female"),
    "profileGenderMale": MessageLookupByLibrary.simpleMessage("Male"),
    "profileGenderUnspecified": MessageLookupByLibrary.simpleMessage(
      "Prefer not to say",
    ),
    "profileHasTeam": MessageLookupByLibrary.simpleMessage("Joined a team"),
    "profileLoginDevices": MessageLookupByLibrary.simpleMessage(
      "Login devices",
    ),
    "profileLogout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "profileLogoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "You will need to sign in again to continue using Co Here.",
    ),
    "profileLogoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Sign out?",
    ),
    "profileLogoutCurrentDevice": MessageLookupByLibrary.simpleMessage(
      "Sign out this device",
    ),
    "profileLogoutSubtitle": MessageLookupByLibrary.simpleMessage("LOG OUT"),
    "profileMyProjects": MessageLookupByLibrary.simpleMessage("My projects"),
    "profileMyProjectsSubtitle": MessageLookupByLibrary.simpleMessage(
      "MY PROJECTS",
    ),
    "profileMyTasksSubtitle": MessageLookupByLibrary.simpleMessage("MY TASKS"),
    "profileMyTeamsSubtitle": MessageLookupByLibrary.simpleMessage("MY TEAMS"),
    "profileNewPassword": MessageLookupByLibrary.simpleMessage("New password"),
    "profileNoTeam": MessageLookupByLibrary.simpleMessage("No team yet"),
    "profileNotSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "profileOtherSection": MessageLookupByLibrary.simpleMessage("Other"),
    "profilePageSubtitle": MessageLookupByLibrary.simpleMessage("PROFILE"),
    "profilePasswordChanged": MessageLookupByLibrary.simpleMessage(
      "Password changed. Sign in again with your new password",
    ),
    "profilePasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "The new passwords do not match",
    ),
    "profilePasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Please complete all three password fields",
    ),
    "profilePasswordRequirement": MessageLookupByLibrary.simpleMessage(
      "The new password must contain at least 6 characters.",
    ),
    "profilePasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "The new password must be at least 6 characters",
    ),
    "profilePasswordUnchanged": MessageLookupByLibrary.simpleMessage(
      "The new password must differ from the current password",
    ),
    "profilePhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "profilePrivacy": MessageLookupByLibrary.simpleMessage("Privacy policy"),
    "profilePrivacySubtitle": MessageLookupByLibrary.simpleMessage(
      "PRIVACY POLICY",
    ),
    "profileRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "profileSave": MessageLookupByLibrary.simpleMessage("Save"),
    "profileSaveSuccess": MessageLookupByLibrary.simpleMessage(
      "Profile updated",
    ),
    "profileSearchPending": MessageLookupByLibrary.simpleMessage(
      "Search is not connected yet",
    ),
    "profileSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "profileSettingsSubtitle": MessageLookupByLibrary.simpleMessage("SETTINGS"),
    "profileSignedIn": MessageLookupByLibrary.simpleMessage("Signed in"),
    "profileTeamStatus": MessageLookupByLibrary.simpleMessage("Team status"),
    "profileTerms": MessageLookupByLibrary.simpleMessage("User agreement"),
    "profileTermsSubtitle": MessageLookupByLibrary.simpleMessage(
      "USER AGREEMENT",
    ),
    "profileUserId": MessageLookupByLibrary.simpleMessage("User ID"),
    "profileUserIdCopied": MessageLookupByLibrary.simpleMessage(
      "User ID copied",
    ),
    "profileUserIdHelp": MessageLookupByLibrary.simpleMessage(
      "Used to add members to teams and projects",
    ),
    "profileUserIdUnavailable": MessageLookupByLibrary.simpleMessage(
      "User ID is currently unavailable",
    ),
    "registerAccountAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
      "This phone or email is already registered",
    ),
    "registerBackToLogin": MessageLookupByLibrary.simpleMessage(
      "Back to login",
    ),
    "registerConfirmPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Repeat your password",
    ),
    "registerConfirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Confirm password",
    ),
    "registerCreateAccount": MessageLookupByLibrary.simpleMessage(
      "Create Account",
    ),
    "registerEmailAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
      "Email is already registered",
    ),
    "registerEmailCodeHint": MessageLookupByLibrary.simpleMessage(
      "6-digit code",
    ),
    "registerEmailCodeLabel": MessageLookupByLibrary.simpleMessage(
      "Verification code",
    ),
    "registerEmailCodePending": MessageLookupByLibrary.simpleMessage(
      "Failed to send verification code. Please try again.",
    ),
    "registerEmptyConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "registerEmptyEmailCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the verification code",
    ),
    "registerHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "registerInvalidEmailCode": MessageLookupByLibrary.simpleMessage(
      "The verification code is incorrect or expired",
    ),
    "registerCodeSent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent",
    ),
    "registerPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "The two passwords do not match",
    ),
    "registerPending": MessageLookupByLibrary.simpleMessage(
      "Register flow is not connected yet",
    ),
    "registerSendCode": MessageLookupByLibrary.simpleMessage("Send code"),
    "registerSendEmailCode": MessageLookupByLibrary.simpleMessage("Send code"),
    "registerSubtitle": MessageLookupByLibrary.simpleMessage(
      "Start with your work email and a secure password.",
    ),
    "registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful",
    ),
    "registerTitle": MessageLookupByLibrary.simpleMessage("Create account"),
    "resetPasswordAccountNotFound": MessageLookupByLibrary.simpleMessage(
      "The verification code is incorrect or expired",
    ),
    "resetPasswordAction": MessageLookupByLibrary.simpleMessage(
      "Reset password",
    ),
    "resetPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the code and both new password fields",
    ),
    "resetPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Verify your registered phone or email and choose a new password.",
    ),
    "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Password reset. Sign in with your new password",
    ),
    "resetPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Reset password",
    ),
    "taskActionComplete": MessageLookupByLibrary.simpleMessage("Complete"),
    "taskActionCompletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Completion submitted",
    ),
    "taskActionNoteHint": MessageLookupByLibrary.simpleMessage(
      "Add completion details or a reason for postponing",
    ),
    "taskActionNoteLabel": MessageLookupByLibrary.simpleMessage(
      "Task update (optional)",
    ),
    "taskActionPostpone": MessageLookupByLibrary.simpleMessage("Postpone"),
    "taskActionPostponedSuccess": MessageLookupByLibrary.simpleMessage(
      "Task postponed",
    ),
    "taskActionUpdating": MessageLookupByLibrary.simpleMessage(
      "Updating task status...",
    ),
    "taskActionViewDetails": MessageLookupByLibrary.simpleMessage(
      "View details",
    ),
    "taskDetailEndTime": MessageLookupByLibrary.simpleMessage("End time"),
    "taskDetailInvalid": MessageLookupByLibrary.simpleMessage(
      "Unable to load task details",
    ),
    "taskDetailNoAssignees": MessageLookupByLibrary.simpleMessage(
      "No assignees",
    ),
    "taskDetailStartTime": MessageLookupByLibrary.simpleMessage("Start time"),
    "taskDetailTitle": MessageLookupByLibrary.simpleMessage("Task details"),
    "taskEmpty": MessageLookupByLibrary.simpleMessage(
      "No tasks match this filter",
    ),
    "teamContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "teamCreateCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "teamCreateDescription": MessageLookupByLibrary.simpleMessage(
      "Invite members, manage projects, and start collaborating from one shared space.",
    ),
    "teamCreateDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Briefly describe what this team works on",
    ),
    "teamCreateDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Team description",
    ),
    "teamCreateDialogSubtitle": MessageLookupByLibrary.simpleMessage(
      "Add the basics now. The image can be added later.",
    ),
    "teamCreateDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Create team",
    ),
    "teamCreateImageCaption": MessageLookupByLibrary.simpleMessage(
      "You can add this later",
    ),
    "teamCreateImageHint": MessageLookupByLibrary.simpleMessage(
      "Tap to choose a team image",
    ),
    "teamCreateImageLabel": MessageLookupByLibrary.simpleMessage(
      "Team image (optional)",
    ),
    "teamCreateImageOptional": MessageLookupByLibrary.simpleMessage(
      "Image picker is not connected yet. You can create without it.",
    ),
    "teamCreateImagePageHint": MessageLookupByLibrary.simpleMessage(
      "A team image helps members recognize the workspace. You can add it later.",
    ),
    "teamCreateImagePickerPending": MessageLookupByLibrary.simpleMessage(
      "Image picker is not connected yet",
    ),
    "teamCreateImageSelected": MessageLookupByLibrary.simpleMessage(
      "Team image selected",
    ),
    "teamCreateNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter a team name",
    ),
    "teamCreateNameLabel": MessageLookupByLibrary.simpleMessage("Team name"),
    "teamCreateNameRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a team name",
    ),
    "teamCreatePageNote": MessageLookupByLibrary.simpleMessage(
      "Team name and description can be changed later in team settings.",
    ),
    "teamCreatePending": MessageLookupByLibrary.simpleMessage(
      "Create team flow is not connected yet",
    ),
    "teamCreateScreenSubtitle": MessageLookupByLibrary.simpleMessage(
      "Add the basics, then invite members by user ID after creating the team.",
    ),
    "teamCreateScreenTitle": MessageLookupByLibrary.simpleMessage(
      "Create your team",
    ),
    "teamCreateSubmit": MessageLookupByLibrary.simpleMessage("Create"),
    "teamCreateSubtitle": MessageLookupByLibrary.simpleMessage(
      "Set up a new workspace",
    ),
    "teamCreateSuccess": MessageLookupByLibrary.simpleMessage("Team created"),
    "teamCreateTitle": MessageLookupByLibrary.simpleMessage("Create a team"),
    "teamDetailAddMember": MessageLookupByLibrary.simpleMessage(
      "Invite member",
    ),
    "teamDetailAddMemberDescription": MessageLookupByLibrary.simpleMessage(
      "Enter a user ID, email, or phone number to send a team invitation.",
    ),
    "teamDetailAddMemberPending": MessageLookupByLibrary.simpleMessage(
      "Adding members is not connected yet",
    ),
    "teamDetailAllTasks": MessageLookupByLibrary.simpleMessage("All tasks"),
    "teamDetailAssignees": MessageLookupByLibrary.simpleMessage("Assignees"),
    "teamDetailCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "teamDetailCreateTask": MessageLookupByLibrary.simpleMessage("Create task"),
    "teamDetailCreatorBadge": MessageLookupByLibrary.simpleMessage("Creator"),
    "teamDetailDeadline": MessageLookupByLibrary.simpleMessage("Due"),
    "teamDetailIntroduction": MessageLookupByLibrary.simpleMessage(
      "Team introduction",
    ),
    "teamDetailMemberAdded": MessageLookupByLibrary.simpleMessage(
      "Team invitation sent",
    ),
    "teamDetailMemberUserIdHint": MessageLookupByLibrary.simpleMessage(
      "User ID / email / international phone",
    ),
    "teamDetailMemberUserIdRequired": MessageLookupByLibrary.simpleMessage(
      "Enter a user ID, email, or international phone",
    ),
    "teamDetailNoIntroduction": MessageLookupByLibrary.simpleMessage(
      "No team introduction",
    ),
    "teamDetailNoTaskDescription": MessageLookupByLibrary.simpleMessage(
      "No task description",
    ),
    "teamDetailNoTasks": MessageLookupByLibrary.simpleMessage(
      "No team tasks yet",
    ),
    "teamDetailPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "teamDetailProgress": MessageLookupByLibrary.simpleMessage("Completion"),
    "teamDetailSelectAssignees": MessageLookupByLibrary.simpleMessage(
      "Select assignees (multiple allowed)",
    ),
    "teamDetailTaskClearStartTime": MessageLookupByLibrary.simpleMessage(
      "Clear start time",
    ),
    "teamDetailTaskCreated": MessageLookupByLibrary.simpleMessage(
      "Task created",
    ),
    "teamDetailTaskDate": MessageLookupByLibrary.simpleMessage("Due date"),
    "teamDetailTaskDateHint": MessageLookupByLibrary.simpleMessage(
      "Select a date",
    ),
    "teamDetailTaskDescription": MessageLookupByLibrary.simpleMessage(
      "Task description",
    ),
    "teamDetailTaskDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Describe the task details",
    ),
    "teamDetailTaskEndTime": MessageLookupByLibrary.simpleMessage(
      "End time (required)",
    ),
    "teamDetailTaskInfo": MessageLookupByLibrary.simpleMessage(
      "Task information",
    ),
    "teamDetailTaskPastTime": MessageLookupByLibrary.simpleMessage(
      "The end time cannot be earlier than now",
    ),
    "teamDetailTaskRequired": MessageLookupByLibrary.simpleMessage(
      "Complete the task details, select an end time, and choose assignees",
    ),
    "teamDetailTaskSelectEndTime": MessageLookupByLibrary.simpleMessage(
      "Select end time",
    ),
    "teamDetailTaskSelectStartTime": MessageLookupByLibrary.simpleMessage(
      "Select start time",
    ),
    "teamDetailTaskStartPastTime": MessageLookupByLibrary.simpleMessage(
      "The start time cannot be earlier than now",
    ),
    "teamDetailTaskStartTime": MessageLookupByLibrary.simpleMessage(
      "Start time (optional)",
    ),
    "teamDetailTaskTime": MessageLookupByLibrary.simpleMessage("Task time"),
    "teamDetailTaskTimeHint": MessageLookupByLibrary.simpleMessage(
      "Select a time",
    ),
    "teamDetailTaskTimeRangeInvalid": MessageLookupByLibrary.simpleMessage(
      "The end time must be later than the start time",
    ),
    "teamDetailTaskTitle": MessageLookupByLibrary.simpleMessage("Task name"),
    "teamDetailTaskTitleHint": MessageLookupByLibrary.simpleMessage(
      "Enter a task name",
    ),
    "teamDetailTasks": MessageLookupByLibrary.simpleMessage("Team tasks"),
    "teamDetailViewAll": MessageLookupByLibrary.simpleMessage("View all"),
    "teamGuidePending": MessageLookupByLibrary.simpleMessage(
      "Team guide is not connected yet",
    ),
    "teamGuideQuestion": MessageLookupByLibrary.simpleMessage(
      "Not sure what to choose?",
    ),
    "teamJoinDescription": MessageLookupByLibrary.simpleMessage(
      "Join a workspace your teammates already created through an invitation or team code.",
    ),
    "teamJoinSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter an existing workspace",
    ),
    "teamJoinTitle": MessageLookupByLibrary.simpleMessage("Join a team"),
    "teamListCreatedAt": MessageLookupByLibrary.simpleMessage("Created on"),
    "teamListCreator": MessageLookupByLibrary.simpleMessage("Created by"),
    "teamListEmpty": MessageLookupByLibrary.simpleMessage("No teams yet"),
    "teamListLongTerm": MessageLookupByLibrary.simpleMessage("Ongoing"),
    "teamListMembers": MessageLookupByLibrary.simpleMessage("Team members"),
    "teamListPeriod": MessageLookupByLibrary.simpleMessage("Schedule"),
    "teamMemberAddPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Only the team creator can invite members",
    ),
    "teamMemberAlreadyJoined": MessageLookupByLibrary.simpleMessage(
      "Already joined",
    ),
    "teamMemberSearchAction": MessageLookupByLibrary.simpleMessage("Search"),
    "teamMemberSearchGuide": MessageLookupByLibrary.simpleMessage(
      "Search by user ID, registered email, or full international phone",
    ),
    "teamMemberSearchNoResult": MessageLookupByLibrary.simpleMessage(
      "No user found. Check the user ID, email, or international phone and try again",
    ),
    "teamMemberSearchNoResultTitle": MessageLookupByLibrary.simpleMessage(
      "User not found",
    ),
    "teamMemberSearchResult": MessageLookupByLibrary.simpleMessage(
      "Search result",
    ),
    "teamOnboardingSuccess": MessageLookupByLibrary.simpleMessage(
      "Team setup complete",
    ),
    "teamPassiveJoinDescription": MessageLookupByLibrary.simpleMessage(
      "No request is needed. When an admin adds your user ID, the team will appear here automatically.",
    ),
    "teamSkip": MessageLookupByLibrary.simpleMessage("Skip"),
    "teamStartSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to work",
    ),
    "teamStartTitle": MessageLookupByLibrary.simpleMessage(
      "Start team collaboration",
    ),
    "teamViewGuide": MessageLookupByLibrary.simpleMessage("View guide"),
  };
}
