// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Co Here`
  String get appName {
    return Intl.message('Co Here', name: 'appName', desc: '', args: []);
  }

  /// `WORK BETTER TOGETHER`
  String get description {
    return Intl.message(
      'WORK BETTER TOGETHER',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get authLoginTitle {
    return Intl.message('Login', name: 'authLoginTitle', desc: '', args: []);
  }

  /// `Email`
  String get authEmailLabel {
    return Intl.message('Email', name: 'authEmailLabel', desc: '', args: []);
  }

  /// `name@company.com`
  String get authEmailHint {
    return Intl.message(
      'name@company.com',
      name: 'authEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Phone login`
  String get authPhoneLogin {
    return Intl.message(
      'Phone login',
      name: 'authPhoneLogin',
      desc: '',
      args: [],
    );
  }

  /// `Email login`
  String get authEmailLogin {
    return Intl.message(
      'Email login',
      name: 'authEmailLogin',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get authPhoneLabel {
    return Intl.message('Phone', name: 'authPhoneLabel', desc: '', args: []);
  }

  /// `Enter local phone number`
  String get authPhoneHint {
    return Intl.message(
      'Enter local phone number',
      name: 'authPhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid international phone number`
  String get authInvalidPhone {
    return Intl.message(
      'Please enter a valid international phone number',
      name: 'authInvalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get authPasswordLabel {
    return Intl.message(
      'Password',
      name: 'authPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `••••••••`
  String get authPasswordHint {
    return Intl.message(
      '••••••••',
      name: 'authPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get authForgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'authForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Verify your registered phone or email and choose a new password.`
  String get resetPasswordSubtitle {
    return Intl.message(
      'Verify your registered phone or email and choose a new password.',
      name: 'resetPasswordSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get resetPasswordAction {
    return Intl.message(
      'Reset password',
      name: 'resetPasswordAction',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code and both new password fields`
  String get resetPasswordRequired {
    return Intl.message(
      'Enter the code and both new password fields',
      name: 'resetPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password reset. Sign in with your new password`
  String get resetPasswordSuccess {
    return Intl.message(
      'Password reset. Sign in with your new password',
      name: 'resetPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `The verification code is incorrect or expired`
  String get resetPasswordAccountNotFound {
    return Intl.message(
      'The verification code is incorrect or expired',
      name: 'resetPasswordAccountNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get authSignIn {
    return Intl.message('Sign In', name: 'authSignIn', desc: '', args: []);
  }

  /// `OR`
  String get authOr {
    return Intl.message('OR', name: 'authOr', desc: '', args: []);
  }

  /// `Sign in with enterprise account`
  String get authEnterpriseLogin {
    return Intl.message(
      'Sign in with enterprise account',
      name: 'authEnterpriseLogin',
      desc: '',
      args: [],
    );
  }

  /// `No account yet?`
  String get authNoAccount {
    return Intl.message(
      'No account yet?',
      name: 'authNoAccount',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get authRegister {
    return Intl.message('Register', name: 'authRegister', desc: '', args: []);
  }

  /// `Please enter a valid email`
  String get authInvalidEmail {
    return Intl.message(
      'Please enter a valid email',
      name: 'authInvalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get authEmptyPassword {
    return Intl.message(
      'Please enter your password',
      name: 'authEmptyPassword',
      desc: '',
      args: [],
    );
  }

  /// `I have read and agree to`
  String get authLegalAcceptancePrefix {
    return Intl.message(
      'I have read and agree to',
      name: 'authLegalAcceptancePrefix',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get authLegalAcceptanceAnd {
    return Intl.message(
      'and',
      name: 'authLegalAcceptanceAnd',
      desc: '',
      args: [],
    );
  }

  /// `Please read and accept the User agreement and Privacy policy`
  String get authLegalAcceptanceRequired {
    return Intl.message(
      'Please read and accept the User agreement and Privacy policy',
      name: 'authLegalAcceptanceRequired',
      desc: '',
      args: [],
    );
  }

  /// `Unable to open the document link. Please try again later`
  String get legalDocumentOpenFailed {
    return Intl.message(
      'Unable to open the document link. Please try again later',
      name: 'legalDocumentOpenFailed',
      desc: '',
      args: [],
    );
  }

  /// `Login flow is not connected yet`
  String get authLoginPending {
    return Intl.message(
      'Login flow is not connected yet',
      name: 'authLoginPending',
      desc: '',
      args: [],
    );
  }

  /// `Login successful`
  String get authLoginSuccess {
    return Intl.message(
      'Login successful',
      name: 'authLoginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect account or password`
  String get authAccountNotFound {
    return Intl.message(
      'Incorrect account or password',
      name: 'authAccountNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect account or password`
  String get authInvalidPassword {
    return Intl.message(
      'Incorrect account or password',
      name: 'authInvalidPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get registerTitle {
    return Intl.message(
      'Create account',
      name: 'registerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start with your work email and a secure password.`
  String get registerSubtitle {
    return Intl.message(
      'Start with your work email and a secure password.',
      name: 'registerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Verification code`
  String get registerEmailCodeLabel {
    return Intl.message(
      'Verification code',
      name: 'registerEmailCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `6-digit code`
  String get registerEmailCodeHint {
    return Intl.message(
      '6-digit code',
      name: 'registerEmailCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Send code`
  String get registerSendEmailCode {
    return Intl.message(
      'Send code',
      name: 'registerSendEmailCode',
      desc: '',
      args: [],
    );
  }

  /// `Send code`
  String get registerSendCode {
    return Intl.message(
      'Send code',
      name: 'registerSendCode',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get registerConfirmPasswordLabel {
    return Intl.message(
      'Confirm password',
      name: 'registerConfirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Repeat your password`
  String get registerConfirmPasswordHint {
    return Intl.message(
      'Repeat your password',
      name: 'registerConfirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get registerCreateAccount {
    return Intl.message(
      'Create Account',
      name: 'registerCreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get registerHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'registerHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Back to login`
  String get registerBackToLogin {
    return Intl.message(
      'Back to login',
      name: 'registerBackToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code`
  String get registerEmptyEmailCode {
    return Intl.message(
      'Please enter the verification code',
      name: 'registerEmptyEmailCode',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send verification code. Please try again.`
  String get registerEmailCodePending {
    return Intl.message(
      'Failed to send verification code. Please try again.',
      name: 'registerEmailCodePending',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent`
  String get registerCodeSent {
    return Intl.message(
      'Verification code sent',
      name: 'registerCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get registerEmptyConfirmPassword {
    return Intl.message(
      'Please confirm your password',
      name: 'registerEmptyConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `The verification code is incorrect or expired`
  String get registerInvalidEmailCode {
    return Intl.message(
      'The verification code is incorrect or expired',
      name: 'registerInvalidEmailCode',
      desc: '',
      args: [],
    );
  }

  /// `Email is already registered`
  String get registerEmailAlreadyRegistered {
    return Intl.message(
      'Email is already registered',
      name: 'registerEmailAlreadyRegistered',
      desc: '',
      args: [],
    );
  }

  /// `This phone or email is already registered`
  String get registerAccountAlreadyRegistered {
    return Intl.message(
      'This phone or email is already registered',
      name: 'registerAccountAlreadyRegistered',
      desc: '',
      args: [],
    );
  }

  /// `The two passwords do not match`
  String get registerPasswordMismatch {
    return Intl.message(
      'The two passwords do not match',
      name: 'registerPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Registration successful`
  String get registerSuccess {
    return Intl.message(
      'Registration successful',
      name: 'registerSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Register flow is not connected yet`
  String get registerPending {
    return Intl.message(
      'Register flow is not connected yet',
      name: 'registerPending',
      desc: '',
      args: [],
    );
  }

  /// `Start team collaboration`
  String get teamStartTitle {
    return Intl.message(
      'Start team collaboration',
      name: 'teamStartTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose how you want to work`
  String get teamStartSubtitle {
    return Intl.message(
      'Choose how you want to work',
      name: 'teamStartSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create a team`
  String get teamCreateTitle {
    return Intl.message(
      'Create a team',
      name: 'teamCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new workspace`
  String get teamCreateSubtitle {
    return Intl.message(
      'Set up a new workspace',
      name: 'teamCreateSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Invite members, manage projects, and start collaborating from one shared space.`
  String get teamCreateDescription {
    return Intl.message(
      'Invite members, manage projects, and start collaborating from one shared space.',
      name: 'teamCreateDescription',
      desc: '',
      args: [],
    );
  }

  /// `Join a team`
  String get teamJoinTitle {
    return Intl.message(
      'Join a team',
      name: 'teamJoinTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter an existing workspace`
  String get teamJoinSubtitle {
    return Intl.message(
      'Enter an existing workspace',
      name: 'teamJoinSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Join a workspace your teammates already created through an invitation or team code.`
  String get teamJoinDescription {
    return Intl.message(
      'Join a workspace your teammates already created through an invitation or team code.',
      name: 'teamJoinDescription',
      desc: '',
      args: [],
    );
  }

  /// `No request is needed. When an admin adds your user ID, the team will appear here automatically.`
  String get teamPassiveJoinDescription {
    return Intl.message(
      'No request is needed. When an admin adds your user ID, the team will appear here automatically.',
      name: 'teamPassiveJoinDescription',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get teamContinue {
    return Intl.message('Continue', name: 'teamContinue', desc: '', args: []);
  }

  /// `Skip`
  String get teamSkip {
    return Intl.message('Skip', name: 'teamSkip', desc: '', args: []);
  }

  /// `Not sure what to choose?`
  String get teamGuideQuestion {
    return Intl.message(
      'Not sure what to choose?',
      name: 'teamGuideQuestion',
      desc: '',
      args: [],
    );
  }

  /// `View guide`
  String get teamViewGuide {
    return Intl.message(
      'View guide',
      name: 'teamViewGuide',
      desc: '',
      args: [],
    );
  }

  /// `Team setup complete`
  String get teamOnboardingSuccess {
    return Intl.message(
      'Team setup complete',
      name: 'teamOnboardingSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Team guide is not connected yet`
  String get teamGuidePending {
    return Intl.message(
      'Team guide is not connected yet',
      name: 'teamGuidePending',
      desc: '',
      args: [],
    );
  }

  /// `Create team`
  String get teamCreateDialogTitle {
    return Intl.message(
      'Create team',
      name: 'teamCreateDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add the basics now. The image can be added later.`
  String get teamCreateDialogSubtitle {
    return Intl.message(
      'Add the basics now. The image can be added later.',
      name: 'teamCreateDialogSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Team image (optional)`
  String get teamCreateImageLabel {
    return Intl.message(
      'Team image (optional)',
      name: 'teamCreateImageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tap to choose a team image`
  String get teamCreateImageHint {
    return Intl.message(
      'Tap to choose a team image',
      name: 'teamCreateImageHint',
      desc: '',
      args: [],
    );
  }

  /// `Image picker is not connected yet. You can create without it.`
  String get teamCreateImageOptional {
    return Intl.message(
      'Image picker is not connected yet. You can create without it.',
      name: 'teamCreateImageOptional',
      desc: '',
      args: [],
    );
  }

  /// `Team image selected`
  String get teamCreateImageSelected {
    return Intl.message(
      'Team image selected',
      name: 'teamCreateImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `Team name`
  String get teamCreateNameLabel {
    return Intl.message(
      'Team name',
      name: 'teamCreateNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter a team name`
  String get teamCreateNameHint {
    return Intl.message(
      'Enter a team name',
      name: 'teamCreateNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a team name`
  String get teamCreateNameRequired {
    return Intl.message(
      'Please enter a team name',
      name: 'teamCreateNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Team description`
  String get teamCreateDescriptionLabel {
    return Intl.message(
      'Team description',
      name: 'teamCreateDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Briefly describe what this team works on`
  String get teamCreateDescriptionHint {
    return Intl.message(
      'Briefly describe what this team works on',
      name: 'teamCreateDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get teamCreateCancel {
    return Intl.message('Cancel', name: 'teamCreateCancel', desc: '', args: []);
  }

  /// `Create`
  String get teamCreateSubmit {
    return Intl.message('Create', name: 'teamCreateSubmit', desc: '', args: []);
  }

  /// `Create your team`
  String get teamCreateScreenTitle {
    return Intl.message(
      'Create your team',
      name: 'teamCreateScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add the basics, then invite members by user ID after creating the team.`
  String get teamCreateScreenSubtitle {
    return Intl.message(
      'Add the basics, then invite members by user ID after creating the team.',
      name: 'teamCreateScreenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `A team image helps members recognize the workspace. You can add it later.`
  String get teamCreateImagePageHint {
    return Intl.message(
      'A team image helps members recognize the workspace. You can add it later.',
      name: 'teamCreateImagePageHint',
      desc: '',
      args: [],
    );
  }

  /// `You can add this later`
  String get teamCreateImageCaption {
    return Intl.message(
      'You can add this later',
      name: 'teamCreateImageCaption',
      desc: '',
      args: [],
    );
  }

  /// `Team name and description can be changed later in team settings.`
  String get teamCreatePageNote {
    return Intl.message(
      'Team name and description can be changed later in team settings.',
      name: 'teamCreatePageNote',
      desc: '',
      args: [],
    );
  }

  /// `Image picker is not connected yet`
  String get teamCreateImagePickerPending {
    return Intl.message(
      'Image picker is not connected yet',
      name: 'teamCreateImagePickerPending',
      desc: '',
      args: [],
    );
  }

  /// `Create team flow is not connected yet`
  String get teamCreatePending {
    return Intl.message(
      'Create team flow is not connected yet',
      name: 'teamCreatePending',
      desc: '',
      args: [],
    );
  }

  /// `Team created`
  String get teamCreateSuccess {
    return Intl.message(
      'Team created',
      name: 'teamCreateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get mainTabHome {
    return Intl.message('Home', name: 'mainTabHome', desc: '', args: []);
  }

  /// `Teams`
  String get mainTabTeams {
    return Intl.message('Teams', name: 'mainTabTeams', desc: '', args: []);
  }

  /// `Profile`
  String get mainTabProfile {
    return Intl.message('Profile', name: 'mainTabProfile', desc: '', args: []);
  }

  /// `Workspace`
  String get dashboardWorkplace {
    return Intl.message(
      'Workspace',
      name: 'dashboardWorkplace',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboardTitle {
    return Intl.message(
      'Dashboard',
      name: 'dashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Galaxy Team`
  String get dashboardTeamName {
    return Intl.message(
      'Galaxy Team',
      name: 'dashboardTeamName',
      desc: '',
      args: [],
    );
  }

  /// `Star Team`
  String get dashboardTeamSubtitle {
    return Intl.message(
      'Star Team',
      name: 'dashboardTeamSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Alex`
  String get dashboardUserName {
    return Intl.message('Alex', name: 'dashboardUserName', desc: '', args: []);
  }

  /// `READY FOR TODAY?`
  String get dashboardReadyForToday {
    return Intl.message(
      'READY FOR TODAY?',
      name: 'dashboardReadyForToday',
      desc: '',
      args: [],
    );
  }

  /// `My tasks`
  String get dashboardMyTasks {
    return Intl.message(
      'My tasks',
      name: 'dashboardMyTasks',
      desc: '',
      args: [],
    );
  }

  /// `Due today`
  String get dashboardDueToday {
    return Intl.message(
      'Due today',
      name: 'dashboardDueToday',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get dashboardInProgress {
    return Intl.message(
      'In progress',
      name: 'dashboardInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Unread`
  String get dashboardUnread {
    return Intl.message('Unread', name: 'dashboardUnread', desc: '', args: []);
  }

  /// `Today’s Tasks`
  String get dashboardTodayTasks {
    return Intl.message(
      'Today’s Tasks',
      name: 'dashboardTodayTasks',
      desc: '',
      args: [],
    );
  }

  /// `Today’s Tasks`
  String get dashboardTodayTasksSubtitle {
    return Intl.message(
      'Today’s Tasks',
      name: 'dashboardTodayTasksSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get dashboardViewAll {
    return Intl.message('All', name: 'dashboardViewAll', desc: '', args: []);
  }

  /// `High`
  String get dashboardPriorityHigh {
    return Intl.message(
      'High',
      name: 'dashboardPriorityHigh',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get dashboardStatusInProgress {
    return Intl.message(
      'Active',
      name: 'dashboardStatusInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Urgent`
  String get dashboardStatusUrgent {
    return Intl.message(
      'Urgent',
      name: 'dashboardStatusUrgent',
      desc: '',
      args: [],
    );
  }

  /// `Galaxy 2.0 UI design review`
  String get dashboardTaskDesignReview {
    return Intl.message(
      'Galaxy 2.0 UI design review',
      name: 'dashboardTaskDesignReview',
      desc: '',
      args: [],
    );
  }

  /// `Customer feedback docs`
  String get dashboardTaskFeedbackDocs {
    return Intl.message(
      'Customer feedback docs',
      name: 'dashboardTaskFeedbackDocs',
      desc: '',
      args: [],
    );
  }

  /// `Quarter report draft`
  String get dashboardTaskQuarterReport {
    return Intl.message(
      'Quarter report draft',
      name: 'dashboardTaskQuarterReport',
      desc: '',
      args: [],
    );
  }

  /// `Due today 06:00 PM`
  String get dashboardTaskQuarterReportTime {
    return Intl.message(
      'Due today 06:00 PM',
      name: 'dashboardTaskQuarterReportTime',
      desc: '',
      args: [],
    );
  }

  /// `Search is not connected yet`
  String get dashboardSearchPending {
    return Intl.message(
      'Search is not connected yet',
      name: 'dashboardSearchPending',
      desc: '',
      args: [],
    );
  }

  /// `All tasks is not connected yet`
  String get dashboardViewAllPending {
    return Intl.message(
      'All tasks is not connected yet',
      name: 'dashboardViewAllPending',
      desc: '',
      args: [],
    );
  }

  /// `No tasks match this filter`
  String get taskEmpty {
    return Intl.message(
      'No tasks match this filter',
      name: 'taskEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Task details`
  String get taskDetailTitle {
    return Intl.message(
      'Task details',
      name: 'taskDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start time`
  String get taskDetailStartTime {
    return Intl.message(
      'Start time',
      name: 'taskDetailStartTime',
      desc: '',
      args: [],
    );
  }

  /// `End time`
  String get taskDetailEndTime {
    return Intl.message(
      'End time',
      name: 'taskDetailEndTime',
      desc: '',
      args: [],
    );
  }

  /// `No assignees`
  String get taskDetailNoAssignees {
    return Intl.message(
      'No assignees',
      name: 'taskDetailNoAssignees',
      desc: '',
      args: [],
    );
  }

  /// `Add assignees`
  String get taskDetailAddAssignees => Intl.message(
    'Add assignees',
    name: 'taskDetailAddAssignees',
    desc: '',
    args: [],
  );

  /// `Unable to load task details`
  String get taskDetailInvalid {
    return Intl.message(
      'Unable to load task details',
      name: 'taskDetailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Task group chat`
  String get taskDetailGroupChat =>
      Intl.message('Task group chat', name: 'taskDetailGroupChat', args: []);

  /// `Open group chat`
  String get taskDetailOpenGroup =>
      Intl.message('Open group chat', name: 'taskDetailOpenGroup', args: []);

  /// `Create group chat`
  String get taskDetailRetryGroup =>
      Intl.message('Create group chat', name: 'taskDetailRetryGroup', args: []);

  /// `Delete task`
  String get taskDetailDelete =>
      Intl.message('Delete task', name: 'taskDetailDelete', args: []);

  /// `Delete task?`
  String get taskDetailDeleteConfirmTitle => Intl.message(
    'Delete task?',
    name: 'taskDetailDeleteConfirmTitle',
    args: [],
  );

  /// `Deleting this task will also dissolve its group chat and requires the group owner's confirmation.`
  String get taskDetailDeleteConfirmMessage => Intl.message(
    'Deleting this task will also dissolve its group chat and requires the group owner\'s confirmation.',
    name: 'taskDetailDeleteConfirmMessage',
    args: [],
  );

  /// `Cancel`
  String get taskDetailCancel =>
      Intl.message('Cancel', name: 'taskDetailCancel', args: []);

  /// `Delete`
  String get taskDetailConfirmDelete =>
      Intl.message('Delete', name: 'taskDetailConfirmDelete', args: []);

  /// `Task deleted`
  String get taskDetailDeleteSuccess =>
      Intl.message('Task deleted', name: 'taskDetailDeleteSuccess', args: []);

  /// `View details`
  String get taskActionViewDetails {
    return Intl.message(
      'View details',
      name: 'taskActionViewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get taskActionComplete {
    return Intl.message(
      'Complete',
      name: 'taskActionComplete',
      desc: '',
      args: [],
    );
  }

  /// `Postpone`
  String get taskActionPostpone {
    return Intl.message(
      'Postpone',
      name: 'taskActionPostpone',
      desc: '',
      args: [],
    );
  }

  /// `Updating task status...`
  String get taskActionUpdating {
    return Intl.message(
      'Updating task status...',
      name: 'taskActionUpdating',
      desc: '',
      args: [],
    );
  }

  /// `Completion submitted`
  String get taskActionCompletedSuccess {
    return Intl.message(
      'Completion submitted',
      name: 'taskActionCompletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Task postponed`
  String get taskActionPostponedSuccess {
    return Intl.message(
      'Task postponed',
      name: 'taskActionPostponedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Task update (optional)`
  String get taskActionNoteLabel {
    return Intl.message(
      'Task update (optional)',
      name: 'taskActionNoteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add completion details or a reason for postponing`
  String get taskActionNoteHint {
    return Intl.message(
      'Add completion details or a reason for postponing',
      name: 'taskActionNoteHint',
      desc: '',
      args: [],
    );
  }

  /// `Created by`
  String get teamListCreator {
    return Intl.message(
      'Created by',
      name: 'teamListCreator',
      desc: '',
      args: [],
    );
  }

  /// `Created on`
  String get teamListCreatedAt {
    return Intl.message(
      'Created on',
      name: 'teamListCreatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Team members`
  String get teamListMembers {
    return Intl.message(
      'Team members',
      name: 'teamListMembers',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get teamListPeriod {
    return Intl.message('Schedule', name: 'teamListPeriod', desc: '', args: []);
  }

  /// `Ongoing`
  String get teamListLongTerm {
    return Intl.message(
      'Ongoing',
      name: 'teamListLongTerm',
      desc: '',
      args: [],
    );
  }

  /// `No teams yet`
  String get teamListEmpty {
    return Intl.message(
      'No teams yet',
      name: 'teamListEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Signed in`
  String get profileSignedIn {
    return Intl.message(
      'Signed in',
      name: 'profileSignedIn',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get profileUserId {
    return Intl.message('User ID', name: 'profileUserId', desc: '', args: []);
  }

  /// `Used to add members to teams and projects`
  String get profileUserIdHelp {
    return Intl.message(
      'Used to add members to teams and projects',
      name: 'profileUserIdHelp',
      desc: '',
      args: [],
    );
  }

  /// `Copy user ID`
  String get profileCopyUserId {
    return Intl.message(
      'Copy user ID',
      name: 'profileCopyUserId',
      desc: '',
      args: [],
    );
  }

  /// `User ID copied`
  String get profileUserIdCopied {
    return Intl.message(
      'User ID copied',
      name: 'profileUserIdCopied',
      desc: '',
      args: [],
    );
  }

  /// `User ID is currently unavailable`
  String get profileUserIdUnavailable {
    return Intl.message(
      'User ID is currently unavailable',
      name: 'profileUserIdUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get profileAccountSection {
    return Intl.message(
      'Account',
      name: 'profileAccountSection',
      desc: '',
      args: [],
    );
  }

  /// `Account information`
  String get profileAccountInfo {
    return Intl.message(
      'Account information',
      name: 'profileAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get profileEditTitle {
    return Intl.message(
      'Edit profile',
      name: 'profileEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get profileAvatar {
    return Intl.message('Photo', name: 'profileAvatar', desc: '', args: []);
  }

  /// `Change photo`
  String get profileEditAvatar {
    return Intl.message(
      'Change photo',
      name: 'profileEditAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Display name`
  String get profileDisplayName {
    return Intl.message(
      'Display name',
      name: 'profileDisplayName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your display name`
  String get profileDisplayNameHint {
    return Intl.message(
      'Enter your display name',
      name: 'profileDisplayNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a display name`
  String get profileDisplayNameRequired {
    return Intl.message(
      'Please enter a display name',
      name: 'profileDisplayNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get profileGender {
    return Intl.message('Gender', name: 'profileGender', desc: '', args: []);
  }

  /// `Male`
  String get profileGenderMale {
    return Intl.message('Male', name: 'profileGenderMale', desc: '', args: []);
  }

  /// `Female`
  String get profileGenderFemale {
    return Intl.message(
      'Female',
      name: 'profileGenderFemale',
      desc: '',
      args: [],
    );
  }

  /// `Prefer not to say`
  String get profileGenderUnspecified {
    return Intl.message(
      'Prefer not to say',
      name: 'profileGenderUnspecified',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get profileBirthday {
    return Intl.message(
      'Birthday',
      name: 'profileBirthday',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get profileNotSet {
    return Intl.message('Not set', name: 'profileNotSet', desc: '', args: []);
  }

  /// `Save`
  String get profileSave {
    return Intl.message('Save', name: 'profileSave', desc: '', args: []);
  }

  /// `Profile updated`
  String get profileSaveSuccess {
    return Intl.message(
      'Profile updated',
      name: 'profileSaveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Photo selection and upload are not connected yet`
  String get profileAvatarEditPending {
    return Intl.message(
      'Photo selection and upload are not connected yet',
      name: 'profileAvatarEditPending',
      desc: '',
      args: [],
    );
  }

  /// `Uploads when saved`
  String get profileAvatarSelected {
    return Intl.message(
      'Uploads when saved',
      name: 'profileAvatarSelected',
      desc: '',
      args: [],
    );
  }

  /// `Uploading photo…`
  String get profileAvatarUploading {
    return Intl.message(
      'Uploading photo…',
      name: 'profileAvatarUploading',
      desc: '',
      args: [],
    );
  }

  /// `Photo upload failed. Try again.`
  String get profileAvatarUploadFailed {
    return Intl.message(
      'Photo upload failed. Try again.',
      name: 'profileAvatarUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Photo must be 5 MB or smaller`
  String get profileAvatarTooLarge {
    return Intl.message(
      'Photo must be 5 MB or smaller',
      name: 'profileAvatarTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the selected photo. Check photo access and try again.`
  String get profileAvatarPickFailed {
    return Intl.message(
      'Could not read the selected photo. Check photo access and try again.',
      name: 'profileAvatarPickFailed',
      desc: '',
      args: [],
    );
  }

  /// `Account & security`
  String get profileAccountSecurity {
    return Intl.message(
      'Account & security',
      name: 'profileAccountSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get profileChangePassword {
    return Intl.message(
      'Change password',
      name: 'profileChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Login devices`
  String get profileLoginDevices {
    return Intl.message(
      'Login devices',
      name: 'profileLoginDevices',
      desc: '',
      args: [],
    );
  }

  /// `Account status`
  String get profileAccountStatus {
    return Intl.message(
      'Account status',
      name: 'profileAccountStatus',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get profileAccountActive {
    return Intl.message(
      'Active',
      name: 'profileAccountActive',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get profileDeleteAccount {
    return Intl.message(
      'Delete account',
      name: 'profileDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Couldn’t load deletion status. Tap to retry`
  String get profileDeletionStatusRetry {
    return Intl.message(
      'Couldn’t load deletion status. Tap to retry',
      name: 'profileDeletionStatusRetry',
      desc: '',
      args: [],
    );
  }

  /// `Choose when to permanently delete your account. Your account, photo, personal data, and teams and tasks you created will be removed.`
  String get profileDeletionChoiceMessage {
    return Intl.message(
      'Choose when to permanently delete your account. Your account, photo, personal data, and teams and tasks you created will be removed.',
      name: 'profileDeletionChoiceMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete after 15 days`
  String get profileDeleteAfterFifteenDays {
    return Intl.message(
      'Delete after 15 days',
      name: 'profileDeleteAfterFifteenDays',
      desc: '',
      args: [],
    );
  }

  /// `A 15-day grace period starts now. You can cancel before the displayed deletion time.`
  String get profileDeleteAfterFifteenDaysDescription {
    return Intl.message(
      'A 15-day grace period starts now. You can cancel before the displayed deletion time.',
      name: 'profileDeleteAfterFifteenDaysDescription',
      desc: '',
      args: [],
    );
  }

  /// `Delete immediately`
  String get profileDeleteImmediately {
    return Intl.message(
      'Delete immediately',
      name: 'profileDeleteImmediately',
      desc: '',
      args: [],
    );
  }

  /// `Permanently deletes the account now. This cannot be undone.`
  String get profileDeleteImmediatelyDescription {
    return Intl.message(
      'Permanently deletes the account now. This cannot be undone.',
      name: 'profileDeleteImmediatelyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Account deletion scheduled`
  String get profileDeletionScheduledTitle {
    return Intl.message(
      'Account deletion scheduled',
      name: 'profileDeletionScheduledTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your account will be permanently deleted on $deletionTime. You can cancel before then or delete it immediately.`
  String profileDeletionScheduledMessage(Object deletionTime) {
    return Intl.message(
      'Your account will be permanently deleted on $deletionTime. You can cancel before then or delete it immediately.',
      name: 'profileDeletionScheduledMessage',
      desc: '',
      args: [deletionTime],
    );
  }

  /// `Account deletion scheduled`
  String get profileDeletionScheduledSuccess {
    return Intl.message(
      'Account deletion scheduled',
      name: 'profileDeletionScheduledSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Cancel deletion`
  String get profileCancelDeletion {
    return Intl.message(
      'Cancel deletion',
      name: 'profileCancelDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Account deletion cancelled`
  String get profileDeletionCancelledSuccess {
    return Intl.message(
      'Account deletion cancelled',
      name: 'profileDeletionCancelledSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete account?`
  String get profileDeleteImmediatelyTitle {
    return Intl.message(
      'Permanently delete account?',
      name: 'profileDeleteImmediatelyTitle',
      desc: '',
      args: [],
    );
  }

  /// `This immediately and permanently deletes your account, photo, personal data, and teams and tasks you created. It cannot be undone.`
  String get profileDeleteImmediatelyConfirmMessage {
    return Intl.message(
      'This immediately and permanently deletes your account, photo, personal data, and teams and tasks you created. It cannot be undone.',
      name: 'profileDeleteImmediatelyConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get profileConfirmPermanentDeletion {
    return Intl.message(
      'Delete permanently',
      name: 'profileConfirmPermanentDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get profileCurrentPassword {
    return Intl.message(
      'Current password',
      name: 'profileCurrentPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get profileNewPassword {
    return Intl.message(
      'New password',
      name: 'profileNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get profileConfirmNewPassword {
    return Intl.message(
      'Confirm new password',
      name: 'profileConfirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `The new password must contain at least 6 characters.`
  String get profilePasswordRequirement {
    return Intl.message(
      'The new password must contain at least 6 characters.',
      name: 'profilePasswordRequirement',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all three password fields`
  String get profilePasswordRequired {
    return Intl.message(
      'Please complete all three password fields',
      name: 'profilePasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `The new password must be at least 6 characters`
  String get profilePasswordTooShort {
    return Intl.message(
      'The new password must be at least 6 characters',
      name: 'profilePasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `The new passwords do not match`
  String get profilePasswordMismatch {
    return Intl.message(
      'The new passwords do not match',
      name: 'profilePasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `The new password must differ from the current password`
  String get profilePasswordUnchanged {
    return Intl.message(
      'The new password must differ from the current password',
      name: 'profilePasswordUnchanged',
      desc: '',
      args: [],
    );
  }

  /// `The current password is incorrect`
  String get profileCurrentPasswordIncorrect {
    return Intl.message(
      'The current password is incorrect',
      name: 'profileCurrentPasswordIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get profileConfirmChangePassword {
    return Intl.message(
      'Change password',
      name: 'profileConfirmChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Password changed. Sign in again with your new password`
  String get profilePasswordChanged {
    return Intl.message(
      'Password changed. Sign in again with your new password',
      name: 'profilePasswordChanged',
      desc: '',
      args: [],
    );
  }

  /// `Current device`
  String get profileCurrentDevice {
    return Intl.message(
      'Current device',
      name: 'profileCurrentDevice',
      desc: '',
      args: [],
    );
  }

  /// `Login devices are managed by the server. A signed-out device must sign in again.`
  String get profileDeviceDescription {
    return Intl.message(
      'Login devices are managed by the server. A signed-out device must sign in again.',
      name: 'profileDeviceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Loading login devices`
  String get profileDeviceLoading {
    return Intl.message(
      'Loading login devices',
      name: 'profileDeviceLoading',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load login devices`
  String get profileDeviceLoadFailed {
    return Intl.message(
      'Unable to load login devices',
      name: 'profileDeviceLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `There are no active login devices`
  String get profileDeviceEmpty {
    return Intl.message(
      'There are no active login devices',
      name: 'profileDeviceEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Last active`
  String get profileDeviceLastActive {
    return Intl.message(
      'Last active',
      name: 'profileDeviceLastActive',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get profileDeviceLogout {
    return Intl.message(
      'Sign out',
      name: 'profileDeviceLogout',
      desc: '',
      args: [],
    );
  }

  /// `Device signed out`
  String get profileDeviceLoggedOut {
    return Intl.message(
      'Device signed out',
      name: 'profileDeviceLoggedOut',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get profileRetry {
    return Intl.message('Retry', name: 'profileRetry', desc: '', args: []);
  }

  /// `Sign out this device`
  String get profileLogoutCurrentDevice {
    return Intl.message(
      'Sign out this device',
      name: 'profileLogoutCurrentDevice',
      desc: '',
      args: [],
    );
  }

  /// `App settings`
  String get profileAppSettings {
    return Intl.message(
      'App settings',
      name: 'profileAppSettings',
      desc: '',
      args: [],
    );
  }

  /// `Notification settings`
  String get appSettingsNotificationSection {
    return Intl.message(
      'Notification settings',
      name: 'appSettingsNotificationSection',
      desc: '',
      args: [],
    );
  }

  /// `Loading notification settings`
  String get appSettingsLoadingNotifications {
    return Intl.message(
      'Loading notification settings',
      name: 'appSettingsLoadingNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive notifications`
  String get appSettingsNotificationsEnabled {
    return Intl.message(
      'Receive notifications',
      name: 'appSettingsNotificationsEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Turn this off to pause all Co Here notifications`
  String get appSettingsNotificationsEnabledDescription {
    return Intl.message(
      'Turn this off to pause all Co Here notifications',
      name: 'appSettingsNotificationsEnabledDescription',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get appSettingsStatusOn {
    return Intl.message('On', name: 'appSettingsStatusOn', desc: '', args: []);
  }

  /// `Off`
  String get appSettingsStatusOff {
    return Intl.message(
      'Off',
      name: 'appSettingsStatusOff',
      desc: '',
      args: [],
    );
  }

  /// `Task assignment notifications`
  String get appSettingsTaskAssigned {
    return Intl.message(
      'Task assignment notifications',
      name: 'appSettingsTaskAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Due date reminders`
  String get appSettingsDueReminder {
    return Intl.message(
      'Due date reminders',
      name: 'appSettingsDueReminder',
      desc: '',
      args: [],
    );
  }

  /// `Team collaboration messages`
  String get appSettingsCollaborationMessages {
    return Intl.message(
      'Team collaboration messages',
      name: 'appSettingsCollaborationMessages',
      desc: '',
      args: [],
    );
  }

  /// `App language`
  String get appSettingsLanguageSection {
    return Intl.message(
      'App language',
      name: 'appSettingsLanguageSection',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get appSettingsFollowSystem {
    return Intl.message(
      'Follow system',
      name: 'appSettingsFollowSystem',
      desc: '',
      args: [],
    );
  }

  /// `Automatically use the device language`
  String get appSettingsFollowSystemDescription {
    return Intl.message(
      'Automatically use the device language',
      name: 'appSettingsFollowSystemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Simplified Chinese`
  String get appSettingsSimplifiedChinese {
    return Intl.message(
      'Simplified Chinese',
      name: 'appSettingsSimplifiedChinese',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get appSettingsThemeSection {
    return Intl.message(
      'Dark mode',
      name: 'appSettingsThemeSection',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get appSettingsThemeSystem {
    return Intl.message(
      'Follow system',
      name: 'appSettingsThemeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Light mode`
  String get appSettingsThemeLight {
    return Intl.message(
      'Light mode',
      name: 'appSettingsThemeLight',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get appSettingsThemeDark {
    return Intl.message(
      'Dark mode',
      name: 'appSettingsThemeDark',
      desc: '',
      args: [],
    );
  }

  /// `Cache management`
  String get appSettingsCacheSection {
    return Intl.message(
      'Cache management',
      name: 'appSettingsCacheSection',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get appSettingsClearCache {
    return Intl.message(
      'Clear cache',
      name: 'appSettingsClearCache',
      desc: '',
      args: [],
    );
  }

  /// `Calculating cache size`
  String get appSettingsCalculatingCache {
    return Intl.message(
      'Calculating cache size',
      name: 'appSettingsCalculatingCache',
      desc: '',
      args: [],
    );
  }

  /// `Current cache`
  String get appSettingsCacheSize {
    return Intl.message(
      'Current cache',
      name: 'appSettingsCacheSize',
      desc: '',
      args: [],
    );
  }

  /// `Only temporary files are removed. Your session, account data, and app settings remain intact.`
  String get appSettingsCacheDescription {
    return Intl.message(
      'Only temporary files are removed. Your session, account data, and app settings remain intact.',
      name: 'appSettingsCacheDescription',
      desc: '',
      args: [],
    );
  }

  /// `Clear temporary cache?`
  String get appSettingsClearCacheConfirmTitle {
    return Intl.message(
      'Clear temporary cache?',
      name: 'appSettingsClearCacheConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Some images and data may need to reload, but you will remain signed in.`
  String get appSettingsClearCacheConfirmMessage {
    return Intl.message(
      'Some images and data may need to reload, but you will remain signed in.',
      name: 'appSettingsClearCacheConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get appSettingsClearCacheAction {
    return Intl.message(
      'Clear',
      name: 'appSettingsClearCacheAction',
      desc: '',
      args: [],
    );
  }

  /// `Cache cleared`
  String get appSettingsCacheCleared {
    return Intl.message(
      'Cache cleared',
      name: 'appSettingsCacheCleared',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get profileOtherSection {
    return Intl.message(
      'Other',
      name: 'profileOtherSection',
      desc: '',
      args: [],
    );
  }

  /// `About us`
  String get profileAbout {
    return Intl.message('About us', name: 'profileAbout', desc: '', args: []);
  }

  /// `Team task assignment and collaboration management`
  String get aboutDescription {
    return Intl.message(
      'Team task assignment and collaboration management',
      name: 'aboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.0 (Build 1)`
  String get aboutVersion {
    return Intl.message(
      'Version 1.0.0 (Build 1)',
      name: 'aboutVersion',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get profileLogout {
    return Intl.message('Sign out', name: 'profileLogout', desc: '', args: []);
  }

  /// `Sign out?`
  String get profileLogoutConfirmTitle {
    return Intl.message(
      'Sign out?',
      name: 'profileLogoutConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will need to sign in again to continue using Co Here.`
  String get profileLogoutConfirmMessage {
    return Intl.message(
      'You will need to sign in again to continue using Co Here.',
      name: 'profileLogoutConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get profileCancel {
    return Intl.message('Cancel', name: 'profileCancel', desc: '', args: []);
  }

  /// `Sign out`
  String get profileConfirmLogout {
    return Intl.message(
      'Sign out',
      name: 'profileConfirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get profileEmail {
    return Intl.message('Email', name: 'profileEmail', desc: '', args: []);
  }

  /// `Phone`
  String get profilePhone {
    return Intl.message('Phone', name: 'profilePhone', desc: '', args: []);
  }

  /// `Team status`
  String get profileTeamStatus {
    return Intl.message(
      'Team status',
      name: 'profileTeamStatus',
      desc: '',
      args: [],
    );
  }

  /// `Joined a team`
  String get profileHasTeam {
    return Intl.message(
      'Joined a team',
      name: 'profileHasTeam',
      desc: '',
      args: [],
    );
  }

  /// `No team yet`
  String get profileNoTeam {
    return Intl.message(
      'No team yet',
      name: 'profileNoTeam',
      desc: '',
      args: [],
    );
  }

  /// `PROFILE`
  String get profilePageSubtitle {
    return Intl.message(
      'PROFILE',
      name: 'profilePageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `MY TEAMS`
  String get profileMyTeamsSubtitle {
    return Intl.message(
      'MY TEAMS',
      name: 'profileMyTeamsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `My projects`
  String get profileMyProjects {
    return Intl.message(
      'My projects',
      name: 'profileMyProjects',
      desc: '',
      args: [],
    );
  }

  /// `MY PROJECTS`
  String get profileMyProjectsSubtitle {
    return Intl.message(
      'MY PROJECTS',
      name: 'profileMyProjectsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `MY TASKS`
  String get profileMyTasksSubtitle {
    return Intl.message(
      'MY TASKS',
      name: 'profileMyTasksSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get profileSettings {
    return Intl.message(
      'Settings',
      name: 'profileSettings',
      desc: '',
      args: [],
    );
  }

  /// `SETTINGS`
  String get profileSettingsSubtitle {
    return Intl.message(
      'SETTINGS',
      name: 'profileSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get profilePrivacy {
    return Intl.message(
      'Privacy policy',
      name: 'profilePrivacy',
      desc: '',
      args: [],
    );
  }

  /// `PRIVACY POLICY`
  String get profilePrivacySubtitle {
    return Intl.message(
      'PRIVACY POLICY',
      name: 'profilePrivacySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `User agreement`
  String get profileTerms {
    return Intl.message(
      'User agreement',
      name: 'profileTerms',
      desc: '',
      args: [],
    );
  }

  /// `USER AGREEMENT`
  String get profileTermsSubtitle {
    return Intl.message(
      'USER AGREEMENT',
      name: 'profileTermsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `LOG OUT`
  String get profileLogoutSubtitle {
    return Intl.message(
      'LOG OUT',
      name: 'profileLogoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Search is not connected yet`
  String get profileSearchPending {
    return Intl.message(
      'Search is not connected yet',
      name: 'profileSearchPending',
      desc: '',
      args: [],
    );
  }

  /// `Creator`
  String get teamDetailCreatorBadge {
    return Intl.message(
      'Creator',
      name: 'teamDetailCreatorBadge',
      desc: '',
      args: [],
    );
  }

  /// `Team introduction`
  String get teamDetailIntroduction {
    return Intl.message(
      'Team introduction',
      name: 'teamDetailIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `No team introduction`
  String get teamDetailNoIntroduction {
    return Intl.message(
      'No team introduction',
      name: 'teamDetailNoIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `Completion`
  String get teamDetailProgress {
    return Intl.message(
      'Completion',
      name: 'teamDetailProgress',
      desc: '',
      args: [],
    );
  }

  /// `All tasks`
  String get teamDetailAllTasks {
    return Intl.message(
      'All tasks',
      name: 'teamDetailAllTasks',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get teamDetailCompleted {
    return Intl.message(
      'Completed',
      name: 'teamDetailCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get teamDetailPending {
    return Intl.message(
      'Pending',
      name: 'teamDetailPending',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get teamDetailViewAll {
    return Intl.message(
      'View all',
      name: 'teamDetailViewAll',
      desc: '',
      args: [],
    );
  }

  /// `Invite member`
  String get teamDetailAddMember {
    return Intl.message(
      'Invite member',
      name: 'teamDetailAddMember',
      desc: '',
      args: [],
    );
  }

  /// `Adding members is not connected yet`
  String get teamDetailAddMemberPending {
    return Intl.message(
      'Adding members is not connected yet',
      name: 'teamDetailAddMemberPending',
      desc: '',
      args: [],
    );
  }

  /// `Enter a user ID, email, or phone number to send a team invitation.`
  String get teamDetailAddMemberDescription {
    return Intl.message(
      'Enter a user ID, email, or phone number to send a team invitation.',
      name: 'teamDetailAddMemberDescription',
      desc: '',
      args: [],
    );
  }

  /// `User ID / email / international phone`
  String get teamDetailMemberUserIdHint {
    return Intl.message(
      'User ID / email / international phone',
      name: 'teamDetailMemberUserIdHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter a user ID, email, or international phone`
  String get teamDetailMemberUserIdRequired {
    return Intl.message(
      'Enter a user ID, email, or international phone',
      name: 'teamDetailMemberUserIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Team invitation sent`
  String get teamDetailMemberAdded {
    return Intl.message(
      'Team invitation sent',
      name: 'teamDetailMemberAdded',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get teamMemberSearchAction {
    return Intl.message(
      'Search',
      name: 'teamMemberSearchAction',
      desc: '',
      args: [],
    );
  }

  /// `Search by user ID, registered email, or full international phone`
  String get teamMemberSearchGuide {
    return Intl.message(
      'Search by user ID, registered email, or full international phone',
      name: 'teamMemberSearchGuide',
      desc: '',
      args: [],
    );
  }

  /// `Search result`
  String get teamMemberSearchResult {
    return Intl.message(
      'Search result',
      name: 'teamMemberSearchResult',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get teamMemberSearchNoResultTitle {
    return Intl.message(
      'User not found',
      name: 'teamMemberSearchNoResultTitle',
      desc: '',
      args: [],
    );
  }

  /// `No user found. Check the user ID, email, or international phone and try again`
  String get teamMemberSearchNoResult {
    return Intl.message(
      'No user found. Check the user ID, email, or international phone and try again',
      name: 'teamMemberSearchNoResult',
      desc: '',
      args: [],
    );
  }

  /// `Already joined`
  String get teamMemberAlreadyJoined {
    return Intl.message(
      'Already joined',
      name: 'teamMemberAlreadyJoined',
      desc: '',
      args: [],
    );
  }

  /// `Only the team creator can invite members`
  String get teamMemberAddPermissionDenied {
    return Intl.message(
      'Only the team creator can invite members',
      name: 'teamMemberAddPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Team tasks`
  String get teamDetailTasks {
    return Intl.message(
      'Team tasks',
      name: 'teamDetailTasks',
      desc: '',
      args: [],
    );
  }

  /// `No team tasks yet`
  String get teamDetailNoTasks {
    return Intl.message(
      'No team tasks yet',
      name: 'teamDetailNoTasks',
      desc: '',
      args: [],
    );
  }

  /// `Create task`
  String get teamDetailCreateTask {
    return Intl.message(
      'Create task',
      name: 'teamDetailCreateTask',
      desc: '',
      args: [],
    );
  }

  /// `Assignees`
  String get teamDetailAssignees {
    return Intl.message(
      'Assignees',
      name: 'teamDetailAssignees',
      desc: '',
      args: [],
    );
  }

  /// `Due`
  String get teamDetailDeadline {
    return Intl.message('Due', name: 'teamDetailDeadline', desc: '', args: []);
  }

  /// `Task name`
  String get teamDetailTaskTitle {
    return Intl.message(
      'Task name',
      name: 'teamDetailTaskTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter a task name`
  String get teamDetailTaskTitleHint {
    return Intl.message(
      'Enter a task name',
      name: 'teamDetailTaskTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Task information`
  String get teamDetailTaskInfo {
    return Intl.message(
      'Task information',
      name: 'teamDetailTaskInfo',
      desc: '',
      args: [],
    );
  }

  /// `Task description`
  String get teamDetailTaskDescription {
    return Intl.message(
      'Task description',
      name: 'teamDetailTaskDescription',
      desc: '',
      args: [],
    );
  }

  /// `Describe the task details`
  String get teamDetailTaskDescriptionHint {
    return Intl.message(
      'Describe the task details',
      name: 'teamDetailTaskDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `No task description`
  String get teamDetailNoTaskDescription {
    return Intl.message(
      'No task description',
      name: 'teamDetailNoTaskDescription',
      desc: '',
      args: [],
    );
  }

  /// `Task time`
  String get teamDetailTaskTime {
    return Intl.message(
      'Task time',
      name: 'teamDetailTaskTime',
      desc: '',
      args: [],
    );
  }

  /// `Start time (optional)`
  String get teamDetailTaskStartTime {
    return Intl.message(
      'Start time (optional)',
      name: 'teamDetailTaskStartTime',
      desc: '',
      args: [],
    );
  }

  /// `End time (required)`
  String get teamDetailTaskEndTime {
    return Intl.message(
      'End time (required)',
      name: 'teamDetailTaskEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Select start time`
  String get teamDetailTaskSelectStartTime {
    return Intl.message(
      'Select start time',
      name: 'teamDetailTaskSelectStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Select end time`
  String get teamDetailTaskSelectEndTime {
    return Intl.message(
      'Select end time',
      name: 'teamDetailTaskSelectEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Clear start time`
  String get teamDetailTaskClearStartTime {
    return Intl.message(
      'Clear start time',
      name: 'teamDetailTaskClearStartTime',
      desc: '',
      args: [],
    );
  }

  /// `The start time cannot be earlier than now`
  String get teamDetailTaskStartPastTime {
    return Intl.message(
      'The start time cannot be earlier than now',
      name: 'teamDetailTaskStartPastTime',
      desc: '',
      args: [],
    );
  }

  /// `The end time must be later than the start time`
  String get teamDetailTaskTimeRangeInvalid {
    return Intl.message(
      'The end time must be later than the start time',
      name: 'teamDetailTaskTimeRangeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Due date`
  String get teamDetailTaskDate {
    return Intl.message(
      'Due date',
      name: 'teamDetailTaskDate',
      desc: '',
      args: [],
    );
  }

  /// `Select a date`
  String get teamDetailTaskDateHint {
    return Intl.message(
      'Select a date',
      name: 'teamDetailTaskDateHint',
      desc: '',
      args: [],
    );
  }

  /// `Select a time`
  String get teamDetailTaskTimeHint {
    return Intl.message(
      'Select a time',
      name: 'teamDetailTaskTimeHint',
      desc: '',
      args: [],
    );
  }

  /// `The end time cannot be earlier than now`
  String get teamDetailTaskPastTime {
    return Intl.message(
      'The end time cannot be earlier than now',
      name: 'teamDetailTaskPastTime',
      desc: '',
      args: [],
    );
  }

  /// `Select assignees (multiple allowed)`
  String get teamDetailSelectAssignees {
    return Intl.message(
      'Select assignees (multiple allowed)',
      name: 'teamDetailSelectAssignees',
      desc: '',
      args: [],
    );
  }

  /// `Complete the task details, select an end time, and choose assignees`
  String get teamDetailTaskRequired {
    return Intl.message(
      'Complete the task details, select an end time, and choose assignees',
      name: 'teamDetailTaskRequired',
      desc: '',
      args: [],
    );
  }

  /// `Task created`
  String get teamDetailTaskCreated {
    return Intl.message(
      'Task created',
      name: 'teamDetailTaskCreated',
      desc: '',
      args: [],
    );
  }

  /// `Notification center`
  String get notificationCenterTitle {
    return Intl.message(
      'Notification center',
      name: 'notificationCenterTitle',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get notificationEmpty {
    return Intl.message(
      'No notifications',
      name: 'notificationEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Team invitation`
  String get notificationTeamInvitation {
    return Intl.message(
      'Team invitation',
      name: 'notificationTeamInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Completion confirmation`
  String get notificationTaskCompletion {
    return Intl.message(
      'Completion confirmation',
      name: 'notificationTaskCompletion',
      desc: '',
      args: [],
    );
  }

  /// `{actorName} invited you to join "{teamName}"`
  String notificationInvitationMessage(Object actorName, Object teamName) {
    return Intl.message(
      '$actorName invited you to join "$teamName"',
      name: 'notificationInvitationMessage',
      desc: '',
      args: [actorName, teamName],
    );
  }

  /// `{actorName} submitted "{taskTitle}" as complete`
  String notificationTaskMessage(Object actorName, Object taskTitle) {
    return Intl.message(
      '$actorName submitted "$taskTitle" as complete',
      name: 'notificationTaskMessage',
      desc: '',
      args: [actorName, taskTitle],
    );
  }

  /// `Note: {note}`
  String notificationTaskNote(Object note) {
    return Intl.message(
      'Note: $note',
      name: 'notificationTaskNote',
      desc: '',
      args: [note],
    );
  }

  /// `Pending`
  String get notificationPending {
    return Intl.message(
      'Pending',
      name: 'notificationPending',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get notificationAccepted {
    return Intl.message(
      'Accepted',
      name: 'notificationAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get notificationRejected {
    return Intl.message(
      'Rejected',
      name: 'notificationRejected',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get notificationConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'notificationConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Processed`
  String get notificationProcessed {
    return Intl.message(
      'Processed',
      name: 'notificationProcessed',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get notificationReject {
    return Intl.message(
      'Reject',
      name: 'notificationReject',
      desc: '',
      args: [],
    );
  }

  /// `Accept invitation`
  String get notificationAcceptInvitation {
    return Intl.message(
      'Accept invitation',
      name: 'notificationAcceptInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm completion`
  String get notificationConfirmTask {
    return Intl.message(
      'Confirm completion',
      name: 'notificationConfirmTask',
      desc: '',
      args: [],
    );
  }

  /// `Notification updated`
  String get notificationHandled {
    return Intl.message(
      'Notification updated',
      name: 'notificationHandled',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
