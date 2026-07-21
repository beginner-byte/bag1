import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:worker/core/model/auth/auth.identity.dart';

/// 开发阶段的 Mock 后端，集中模拟账号、团队、任务和设置接口状态。
final class MockAuthBackend {
  MockAuthBackend._();

  /// 当前 Mock 数据文件结构版本，用于识别并迁移旧的仅账号密码格式。
  static const _schemaVersion = 6;

  /// Mock 密码摘要记录前缀，用于识别旧版明文数据并执行一次性迁移。
  static const _passwordRecordPrefix = 'sha256-v1';

  /// 全局唯一 mock 后端实例，让注册和登录接口共享同一份临时用户数据。
  static final MockAuthBackend instance = MockAuthBackend._();

  /// 固定验证码，用于本地开发时完成短信或邮箱验证码注册链路。
  static const verificationCode = '123456';

  /// 内存用户表，key 是标准化账号，value 是带随机盐的 Mock 密码摘要记录。
  final Map<String, String> _users = {};

  /// 按手机号账号保存 ISO 国家或地区码，区分共享同一国际区号的地区。
  final Map<String, String> _phoneRegionCodes = {};

  /// 开发阶段保存用户修改后的昵称，不改变现有 mock 用户文件结构。
  final Map<String, String> _displayNames = {};

  /// 开发阶段保存用户修改后的头像地址，后续接入上传接口后可直接替换。
  final Map<String, String> _avatarUrls = {};

  /// 按账号保存用户选择的性别代码，模拟个人资料接口的服务端状态。
  final Map<String, String> _genders = {};

  /// 按账号保存 YYYY-MM-DD 格式生日，空值表示用户尚未设置。
  final Map<String, String> _birthdays = {};

  /// 按账号保存通知偏好，模拟需要跨设备同步的服务端设置。
  final Map<String, Map<String, dynamic>> _notificationPreferences = {};

  /// 按创建者账号保存全部团队；成员关系决定其他账号是否可见。
  final Map<String, List<Map<String, dynamic>>> _createdTeams = {};

  /// 按创建者账号保存全部任务，查询时再按团队和负责人关系过滤。
  final Map<String, List<Map<String, dynamic>>> _createdTasks = {};

  /// 按账号和任务标识保存快捷状态更新，保证列表刷新后仍保持完成或延后结果。
  final Map<String, Map<String, String>> _taskStatusOverrides = {};

  /// 按账号和任务标识保存可选情况说明，模拟状态操作备注的服务端持久化。
  final Map<String, Map<String, String>> _taskStatusNotes = {};

  /// 按接收账号保存团队邀请和任务完成确认，处理后保留最终状态供通知中心展示。
  final Map<String, List<Map<String, dynamic>>> _notifications = {};

  /// 按账号保存最近一次 Mock 登录提交的设备名称，用于兼容设备列表页面。
  final Map<String, String> _loginDeviceNames = {};

  /// 按账号保存最近一次 Mock 登录提交的平台代码。
  final Map<String, String> _loginDevicePlatforms = {};

  /// 按账号保存 15 天后永久删除的 UTC 时间，缺少键表示没有待执行预约。
  final Map<String, DateTime> _deletionScheduledAt = {};

  /// Mock 数据文件，初始化后指向应用文档目录下的可写 JSON 文件。
  File? _file;

  /// 是否已经完成文件创建和内存用户表加载，避免每次请求重复读盘。
  bool _initialized = false;

  /// 初始化 Mock 数据文件；文件不存在时创建版本化空数据结构。
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // 应用文档目录负责保存跨启动周期仍需存在的模拟服务端数据。
    final directory = await getApplicationDocumentsDirectory();
    // 沿用原文件名，避免升级后出现新旧两份 Mock 账号数据。
    final file = File('${directory.path}/mock_auth_users.json');

    if (!await file.exists()) {
      await file.writeAsString(_encodeState());
    }

    _file = file;
    await _loadState();
    _initialized = true;
  }

  /// 根据接口路径生成动态 mock 响应，返回 null 表示当前后端不处理该接口。
  Future<Map<String, dynamic>?> resolve({
    required String path,
    required Object? body,
    required Map<String, dynamic> queryParameters,
    required Map<String, dynamic> headers,
  }) async {
    await initialize();

    if (path == '/v1/auth/avatar') {
      return _uploadAvatar(body, headers);
    }

    final parameters = _readParameters(body);

    if (path == '/v1/auth/account') {
      return await _deleteAccountNow(headers);
    }
    if (path == '/v1/auth/account/deletion') {
      return switch (parameters['action']?.toString()) {
        'schedule' => await _scheduleAccountDeletion(headers),
        'cancel' => await _cancelAccountDeletion(headers),
        _ => _accountDeletionStatus(headers),
      };
    }
    if (path == '/v1/auth/devices') {
      return _loginDevices(headers);
    }
    if (path.startsWith('/v1/auth/devices/')) {
      return _logoutDevice(path, headers);
    }

    return switch (path) {
      '/v1/auth/code' => _sendCode(parameters),
      '/v1/auth/register' => await _register(parameters),
      '/v1/auth/login' => _login(parameters),
      '/v1/auth/profile' => _profile(headers),
      '/v1/auth/profile/update' => await _updateProfile(parameters, headers),
      '/v1/auth/password' => await _changePassword(parameters, headers),
      '/v1/auth/password/reset' => await _resetPassword(parameters),
      '/v1/settings/notifications' => switch (parameters.isEmpty) {
        true => _getNotificationPreferences(headers),
        false => await _updateNotificationPreferences(parameters, headers),
      },
      '/v1/notifications' => _notificationList(headers),
      '/v1/notifications/action' => await _handleNotification(
        parameters,
        headers,
      ),
      '/v1/task/summary' => _dashboardSummary(headers),
      '/v1/tasks' =>
        parameters.isEmpty
            ? _tasks(queryParameters, headers)
            : await _createTask(parameters, headers),
      '/v1/tasks/status' => await _updateTaskStatus(parameters, headers),
      '/v1/tasks/today' => _todayTasks(headers),
      '/v1/users/search' => _searchUser(queryParameters, headers),
      '/v1/teams/members' => await _addTeamMember(parameters, headers),
      '/v1/teams' =>
        parameters.isEmpty
            ? _teams(headers)
            : await _createTeam(parameters, headers),
      _ => null,
    };
  }

  /// 模拟 multipart 头像上传并返回可跨启动读取的本地文件路径。
  ///
  /// [body] 必须是 Dio FormData 且包含 file；[headers] 用于识别当前 Mock
  /// 账号。失败返回与真实服务一致的业务响应，不覆盖原头像文件。
  Future<Map<String, dynamic>> _uploadAvatar(
    Object? body,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);
    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }
    if (!_users.containsKey(email)) {
      return {'code': 4003, 'message': '登录已失效'};
    }
    if (body is! FormData || body.files.isEmpty) {
      return {'code': 400, 'message': '请选择需要上传的头像图片'};
    }

    // avatarPart 只接受服务端约定的 file 字段，防止错误字段被静默保存。
    final avatarParts = body.files.where((entry) => entry.key == 'file');
    if (avatarParts.isEmpty) {
      return {'code': 400, 'message': '请选择需要上传的头像图片'};
    }
    final avatarPart = avatarParts.first.value;
    // byteBuilder 收集一次性 multipart 流，行为与 Dio 真实发送时保持一致。
    final byteBuilder = await avatarPart.finalize().fold<BytesBuilder>(
      BytesBuilder(copy: false),
      (builder, chunk) {
        builder.add(chunk);
        return builder;
      },
    );
    final avatarBytes = byteBuilder.takeBytes();
    if (avatarBytes.isEmpty) {
      return {'code': 400, 'message': '头像文件不能为空'};
    }
    if (avatarBytes.length > 5 * 1024 * 1024) {
      return {'code': 400, 'message': '头像图片不能超过 5 MB'};
    }
    if (!_isSupportedAvatarBytes(avatarBytes)) {
      return {'code': 400, 'message': '头像仅支持 JPEG、PNG 或 WebP 图片'};
    }

    // stateFileDirectory 与 Mock 状态文件同属应用文档目录，重启后路径仍然有效。
    final stateFileDirectory = _file?.parent;
    if (stateFileDirectory == null) {
      return {'code': 500, 'message': '头像上传失败，请稍后重试'};
    }
    // avatarFileName 使用稳定用户 ID，让新上传原子覆盖旧 Mock 头像而不产生垃圾文件。
    final avatarFileName = 'mock_avatar_${_userIdForEmail(email)}';
    final avatarFile = File('${stateFileDirectory.path}/$avatarFileName');
    await avatarFile.writeAsBytes(avatarBytes, flush: true);

    _avatarUrls[email] = avatarFile.path;
    await _writeState();
    return {
      'code': 0,
      'message': 'success',
      'data': {'avatarUrl': avatarFile.path},
    };
  }

  /// 判断 [bytes] 是否具有 JPEG、PNG 或 WebP 的标准文件签名。
  bool _isSupportedAvatarBytes(Uint8List bytes) {
    // isJpeg checks the SOI marker shared by valid JPEG encodings.
    final isJpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    // isPng checks the complete fixed eight-byte PNG signature.
    final isPng =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    // isWebp checks the RIFF container and WEBP format identifier.
    final isWebp =
        bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    return isJpeg || isPng || isWebp;
  }

  /// 通过用户 ID、注册邮箱或完整国际手机号查询账号，只返回公开摘要。
  Map<String, dynamic> _searchUser(
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> headers,
  ) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final keyword = queryParameters['keyword']?.toString().trim() ?? '';

    if (keyword.isEmpty) {
      return {'code': 4001, 'message': '请输入用户 ID、邮箱或手机号'};
    }

    final normalizedKeyword = keyword.toLowerCase();
    // 手机号搜索允许用户输入空格、横线或括号，但必须包含完整国际区号。
    final normalizedPhoneKeyword = _normalizePhoneAccount(keyword);

    for (final candidateEmail in _users.keys) {
      final matchesUserId =
          _userIdForEmail(candidateEmail).toLowerCase() == normalizedKeyword;
      final matchesAccount =
          candidateEmail.toLowerCase() == normalizedKeyword ||
          candidateEmail == normalizedPhoneKeyword;

      if (matchesUserId || matchesAccount) {
        return {
          'code': 0,
          'message': 'success',
          'data': _memberForEmail(candidateEmail),
        };
      }
    }

    return {'code': 4041, 'message': '用户 ID、邮箱或手机号不存在'};
  }

  /// 从 Mock 文件恢复完整状态；旧格式会保留账号并补入原有演示数据。
  Future<void> _loadState() async {
    final file = _file;

    if (file == null) {
      return;
    }

    try {
      final content = await file.readAsString();
      // 文件内容必须是 JSON 对象，其他结构按损坏数据处理。
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        await _writeState();
        return;
      }

      // 所有内存集合先清空，避免异常重入时混入上一轮状态。
      _clearState();
      // users 数组兼容旧邮箱结构与双账号结构，资料字段缺失时使用安全默认值。
      final users = decoded['users'];

      if (users is! List) {
        await _writeState();
        return;
      }

      for (final user in users.whereType<Map<String, dynamic>>()) {
        // v2 只有 email；v3 使用 identityType + account，并保留展示字段。
        final rawIdentityType = user['identityType'];
        // v2 没有 identityType 且只支持邮箱，不能跟随新页面的手机号默认值。
        final inferredType = user['phone']?.toString().isNotEmpty == true
            ? AuthIdentityType.phone
            : rawIdentityType?.toString() == AuthIdentityType.phone.wireValue
            ? AuthIdentityType.phone
            : AuthIdentityType.email;
        final rawAccount =
            user['account'] ??
            (inferredType == AuthIdentityType.phone
                ? user['phone']
                : user['email']);
        final account = inferredType == AuthIdentityType.phone
            ? _normalizePhoneAccount(rawAccount)
            : _normalizeEmail(rawAccount);
        // v4 使用 passwordDigest；旧版本 password 字段会在本次加载时转为摘要。
        final persistedPassword =
            user['passwordDigest']?.toString() ??
            user['password']?.toString() ??
            '';

        if (account.isEmpty || persistedPassword.isEmpty) {
          continue;
        }

        _users[account] = _isPasswordRecord(persistedPassword)
            ? persistedPassword
            : _createPasswordRecord(persistedPassword);
        if (inferredType == AuthIdentityType.phone) {
          _restoreOptionalString(
            _phoneRegionCodes,
            account,
            user['phoneRegionCode'],
          );
        }
        _restoreOptionalString(_displayNames, account, user['displayName']);
        _restoreOptionalString(_avatarUrls, account, user['avatarUrl']);
        _restoreOptionalString(_genders, account, user['gender']);
        _restoreOptionalString(_birthdays, account, user['birthday']);
        // deletionScheduledAt 缺失时表示旧账号没有预约删除。
        final deletionScheduledAt = DateTime.tryParse(
          user['deletionScheduledAt']?.toString() ?? '',
        )?.toUtc();
        if (deletionScheduledAt != null) {
          _deletionScheduledAt[account] = deletionScheduledAt;
        }

        // 通知偏好属于账号数据，存在时恢复完整布尔字段集合。
        final preferences = user['notificationPreferences'];
        if (preferences is Map) {
          _notificationPreferences[account] = preferences.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      }

      // 新版结构中的业务集合均由独立恢复函数执行类型清洗。
      _restoreRecordLists(decoded['createdTeams'], _createdTeams);
      _restoreRecordLists(decoded['createdTasks'], _createdTasks);
      _restoreStringMaps(decoded['taskStatusOverrides'], _taskStatusOverrides);
      _restoreStringMaps(decoded['taskStatusNotes'], _taskStatusNotes);
      _restoreRecordLists(decoded['notifications'], _notifications);

      // v1 没有持久化业务集合，需要补入旧演示数据；v2 已有完整业务集合，
      // 升级双账号结构时只重写用户字段，不能覆盖用户已经创建的团队和任务。
      final rawSchemaVersion = decoded['schemaVersion'];
      final schemaVersion = rawSchemaVersion is int ? rawSchemaVersion : 1;
      if (schemaVersion < 2) {
        for (final email in _users.keys) {
          _createdTeams.putIfAbsent(
            email,
            () => _cloneRecords(_seededTeams(email)),
          );
          _createdTasks.putIfAbsent(
            email,
            () => _cloneRecords(_seededTasks(email)),
          );
        }
      }

      if (schemaVersion < _schemaVersion) {
        await _writeState();
      }
    } on FormatException {
      _clearState();
      await _writeState();
    }
  }

  /// 把完整 Mock 状态写回文件，让业务操作在 App 重启后保持一致。
  Future<void> _writeState() async {
    final file = _file;

    if (file == null) {
      return;
    }

    await file.writeAsString(_encodeState());
  }

  /// 编码版本化 Mock 状态，保持文件可读并方便后续服务器字段对照。
  String _encodeState() {
    const encoder = JsonEncoder.withIndent('  ');

    return encoder.convert({
      'schemaVersion': _schemaVersion,
      'users': _users.entries
          .map((entry) {
            final isPhone = entry.key.startsWith('+');
            return {
              'identityType': isPhone ? 'phone' : 'email',
              'account': entry.key,
              'email': isPhone ? '' : entry.key,
              'phone': isPhone ? entry.key : '',
              'phoneRegionCode': _phoneRegionCodes[entry.key] ?? '',
              'passwordDigest': entry.value,
              'displayName': _displayNames[entry.key] ?? '',
              'avatarUrl': _avatarUrls[entry.key] ?? '',
              'gender': _genders[entry.key] ?? 'unspecified',
              'birthday': _birthdays[entry.key] ?? '',
              'deletionScheduledAt':
                  _deletionScheduledAt[entry.key]?.toIso8601String() ?? '',
              'notificationPreferences':
                  _notificationPreferences[entry.key] ?? const {},
            };
          })
          .toList(growable: false),
      'createdTeams': _createdTeams,
      'createdTasks': _createdTasks,
      'taskStatusOverrides': _taskStatusOverrides,
      'taskStatusNotes': _taskStatusNotes,
      'notifications': _notifications,
    });
  }

  /// 清空所有内存状态，供损坏数据恢复和重新加载共同使用。
  void _clearState() {
    _users.clear();
    _phoneRegionCodes.clear();
    _displayNames.clear();
    _avatarUrls.clear();
    _genders.clear();
    _birthdays.clear();
    _notificationPreferences.clear();
    _createdTeams.clear();
    _createdTasks.clear();
    _taskStatusOverrides.clear();
    _taskStatusNotes.clear();
    _notifications.clear();
    _deletionScheduledAt.clear();
  }

  /// 恢复非空字符串字段，避免缺失值覆盖业务默认值。
  void _restoreOptionalString(
    Map<String, String> target,
    String email,
    Object? value,
  ) {
    // 标准化后的字段值为空时由读取方继续使用默认内容。
    final normalizedValue = value?.toString() ?? '';
    if (normalizedValue.isNotEmpty) {
      target[email] = normalizedValue;
    }
  }

  /// 恢复按账号分组的 JSON 记录数组，并过滤掉非对象元素。
  void _restoreRecordLists(
    Object? source,
    Map<String, List<Map<String, dynamic>>> target,
  ) {
    if (source is! Map) {
      return;
    }

    for (final entry in source.entries) {
      // 每个键表示创建者账号，每个值表示该账号创建的业务记录。
      final email = _normalizeEmail(entry.key);
      final records = entry.value;

      if (email.isEmpty || records is! List) {
        continue;
      }

      target[email] = records
          .whereType<Map>()
          .map(
            (record) =>
                record.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList();
    }
  }

  /// 恢复按账号分组的字符串映射，用于任务状态及备注覆盖。
  void _restoreStringMaps(
    Object? source,
    Map<String, Map<String, String>> target,
  ) {
    if (source is! Map) {
      return;
    }

    for (final entry in source.entries) {
      // 外层键为标准化账号，内层键为任务 ID。
      final email = _normalizeEmail(entry.key);
      final values = entry.value;

      if (email.isEmpty || values is! Map) {
        continue;
      }

      target[email] = values.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
  }

  /// 深拷贝 JSON 记录，防止迁移后的持久化数据继续引用演示模板。
  List<Map<String, dynamic>> _cloneRecords(List<Map<String, dynamic>> records) {
    // JSON 编解码可完整复制当前仅包含基础 JSON 类型的 Mock 记录。
    final encodedRecords = jsonEncode(records);
    final decodedRecords = jsonDecode(encodedRecords) as List<dynamic>;
    return decodedRecords.cast<Map<String, dynamic>>();
  }

  /// 解析 Dio 请求体参数，避免 mock 逻辑依赖具体 Map 泛型实现。
  Map<String, dynamic> _readParameters(Object? body) {
    if (body is! Map) {
      return const {};
    }

    return body.map((key, value) => MapEntry(key.toString(), value));
  }

  /// 创建仅用于本地 Mock 数据的带盐密码摘要记录。
  ///
  /// [password] 是用户输入的原始密码；返回值只保存算法、随机盐和摘要。
  String _createPasswordRecord(String password) {
    // 每个账号独立随机盐，避免相同密码在 Mock 文件中产生相同摘要。
    final random = Random.secure();
    final saltBytes = List<int>.generate(
      16,
      // 当前索引用于生成固定长度随机字节，不参与业务含义计算。
      (_) => random.nextInt(256),
      growable: false,
    );
    final salt = base64UrlEncode(saltBytes);
    final digest = _passwordDigest(password: password, salt: salt);
    return '$_passwordRecordPrefix:$salt:$digest';
  }

  /// 校验用户输入与已保存的 Mock 密码摘要是否一致。
  ///
  /// [password] 是本次登录输入；[record] 必须是当前版本摘要记录。
  bool _verifyPassword({required String password, required String record}) {
    final parts = record.split(':');
    if (parts.length != 3 || parts.first != _passwordRecordPrefix) {
      return false;
    }

    final expectedDigest = parts[2];
    final actualDigest = _passwordDigest(password: password, salt: parts[1]);
    if (expectedDigest.length != actualDigest.length) {
      return false;
    }

    // 使用固定次数比较摘要，避免在首个不同字符处提前返回。
    var difference = 0;
    for (var index = 0; index < expectedDigest.length; index++) {
      // index 仅定位两个等长摘要中的同一字符位置。
      difference |=
          expectedDigest.codeUnitAt(index) ^ actualDigest.codeUnitAt(index);
    }
    return difference == 0;
  }

  /// 计算本地 Mock 密码摘要，不作为真实服务端密码算法使用。
  ///
  /// [password] 是原始密码；[salt] 是记录中保存的随机盐。
  String _passwordDigest({required String password, required String salt}) {
    final digestInput = utf8.encode('$salt:$password');
    return sha256.convert(digestInput).toString();
  }

  /// 判断持久化字符串是否已经是当前 Mock 密码摘要格式。
  bool _isPasswordRecord(String value) {
    return value.startsWith('$_passwordRecordPrefix:');
  }

  /// 模拟发送短信或邮箱验证码，当前固定返回成功供开发阶段展示。
  Map<String, dynamic> _sendCode(Map<String, dynamic> parameters) {
    final identityType = AuthIdentityType.fromValue(parameters['identityType']);
    final account = _normalizeIdentityAccount(
      identityType,
      parameters['account'],
    );

    if (account.isEmpty) {
      return {'code': 4000, 'message': '账号不能为空'};
    }

    return {
      'code': 0,
      'message': 'success',
      'data': {'code': verificationCode},
    };
  }

  /// 模拟注册接口，校验验证码并持久化没有团队的新账号。
  Future<Map<String, dynamic>> _register(
    Map<String, dynamic> parameters,
  ) async {
    final identityType = AuthIdentityType.fromValue(parameters['identityType']);
    final account = _normalizeIdentityAccount(
      identityType,
      parameters['account'],
    );
    final phoneRegionCode =
        parameters['phoneRegionCode']?.toString().trim().toUpperCase() ?? '';
    final password = parameters['password']?.toString() ?? '';
    final code = parameters['code']?.toString().trim() ?? '';

    if (account.isEmpty || password.length < 6) {
      return {'code': 4000, 'message': '注册参数不完整'};
    }

    if (identityType == AuthIdentityType.phone &&
        (phoneRegionCode.isEmpty || !AuthIdentity.isValidPhone(account))) {
      return {'code': 4000, 'message': '手机号参数无效'};
    }

    if (code != verificationCode) {
      return {'code': 4001, 'message': '验证码错误'};
    }

    if (_users.containsKey(account)) {
      return {'code': 4002, 'message': '账号已注册'};
    }

    _users[account] = _createPasswordRecord(password);
    if (identityType == AuthIdentityType.phone) {
      _phoneRegionCodes[account] = phoneRegionCode;
    }
    // 新账号使用邮箱前缀或完整手机号作为初始昵称，不自动附加演示业务数据。
    _displayNames[account] = _defaultDisplayName(account);
    _rememberLoginDevice(account, parameters);
    await _writeState();

    return {'code': 0, 'message': 'success', 'data': _buildSession(account)};
  }

  /// 模拟登录接口，使用内存用户表校验账号和密码。
  ///
  /// 账号缺失和密码错误返回同一业务响应，避免暴露账号注册状态。
  Map<String, dynamic> _login(Map<String, dynamic> parameters) {
    final identityType = AuthIdentityType.fromValue(parameters['identityType']);
    final account = _normalizeIdentityAccount(
      identityType,
      parameters['account'],
    );
    final password = parameters['password']?.toString() ?? '';
    final storedPasswordRecord = _users[account];

    if (storedPasswordRecord == null) {
      return {'code': 4004, 'message': '账号或密码错误'};
    }

    if (!_verifyPassword(password: password, record: storedPasswordRecord)) {
      return {'code': 4004, 'message': '账号或密码错误'};
    }

    _rememberLoginDevice(account, parameters);
    return {'code': 0, 'message': 'success', 'data': _buildSession(account)};
  }

  /// 保存 Mock 登录请求中的非敏感设备展示信息，仅用于保持接口契约一致。
  void _rememberLoginDevice(String account, Map<String, dynamic> parameters) {
    // deviceName 缺失时回退通用名称，兼容升级前的调用方。
    final deviceName = parameters['deviceName']?.toString().trim() ?? '';
    // platform 缺失时使用 unknown，让 UI 选择通用设备图标。
    final platform = parameters['platform']?.toString().trim() ?? '';
    _loginDeviceNames[account] = deviceName.isEmpty
        ? 'Current device'
        : deviceName;
    _loginDevicePlatforms[account] = platform.isEmpty ? 'unknown' : platform;
  }

  /// 返回当前 Mock 账号的一条本机会话，供开发模式验证真实设备 UI。
  Map<String, dynamic> _loginDevices(Map<String, dynamic> headers) {
    // account 从 Mock Token 恢复，未登录请求保持与真实服务端一致。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }
    return {
      'code': 0,
      'message': 'success',
      'data': [
        {
          'id': 'mock-device-${_userIdForEmail(account)}',
          'deviceName': _loginDeviceNames[account] ?? 'Current device',
          'platform': _loginDevicePlatforms[account] ?? 'unknown',
          'lastActiveAt': DateTime.now().toUtc().toIso8601String(),
          'current': true,
        },
      ],
    };
  }

  /// 模拟撤销当前账号设备会话；客户端随后会清理本地 Mock Token。
  Map<String, dynamic> _logoutDevice(
    String path,
    Map<String, dynamic> headers,
  ) {
    // account 只用于验证当前请求确实包含有效 Mock 登录态。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }
    // sessionID 必须和当前 Mock 账号公开设备标识一致，避免吞掉错误路径。
    final sessionID = path.substring('/v1/auth/devices/'.length);
    if (sessionID != 'mock-device-${_userIdForEmail(account)}') {
      return {'code': 4003, 'message': '登录设备不存在或已退出'};
    }
    return {'code': 0, 'message': 'success', 'data': <String, dynamic>{}};
  }

  /// 返回当前 Mock 账号的 15 天删除预约状态。
  ///
  /// [headers] 用于从 Mock Token 恢复账号；未预约时 scheduledAt 为空。
  Map<String, dynamic> _accountDeletionStatus(Map<String, dynamic> headers) {
    // account 是标准化手机号或邮箱账号，用于隔离每个用户的预约时间。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty || !_users.containsKey(account)) {
      return {'code': 401, 'message': '登录已失效'};
    }
    // scheduledAt 为 UTC 时间，保持与真实服务端响应格式一致。
    final scheduledAt = _deletionScheduledAt[account];
    return {
      'code': 0,
      'message': 'success',
      'data': {
        'scheduled': scheduledAt != null,
        'scheduledAt': scheduledAt?.toIso8601String() ?? '',
      },
    };
  }

  /// 为当前 Mock 账号预约固定 15 天后的永久删除。
  ///
  /// [headers] 用于识别账号；重复请求保留首次期限并写入本地 Mock 状态文件。
  Future<Map<String, dynamic>> _scheduleAccountDeletion(
    Map<String, dynamic> headers,
  ) async {
    // account 是标准化手机号或邮箱账号，用于隔离删除预约。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty || !_users.containsKey(account)) {
      return {'code': 401, 'message': '登录已失效'};
    }
    // requestedDeadline 仅在首次申请时保存，防止重复点击延长冷静期。
    final requestedDeadline = DateTime.now().toUtc().add(
      const Duration(days: 15),
    );
    _deletionScheduledAt.putIfAbsent(account, () => requestedDeadline);
    await _writeState();
    return _accountDeletionStatus(headers);
  }

  /// 撤销当前 Mock 账号尚未执行的删除预约。
  ///
  /// [headers] 用于识别账号；没有预约或期限已到时返回与真实服务一致的冲突。
  Future<Map<String, dynamic>> _cancelAccountDeletion(
    Map<String, dynamic> headers,
  ) async {
    // account 是标准化手机号或邮箱账号，用于移除准确的预约记录。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty || !_users.containsKey(account)) {
      return {'code': 401, 'message': '登录已失效'};
    }
    // scheduledAt 决定当前是否仍处于允许撤销的 15 天冷静期。
    final scheduledAt = _deletionScheduledAt[account];
    if (scheduledAt == null || !scheduledAt.isAfter(DateTime.now().toUtc())) {
      return {'code': 4090, 'message': '删除预约不存在或期限已到，无法撤销'};
    }
    _deletionScheduledAt.remove(account);
    await _writeState();
    return {'code': 0, 'message': 'success', 'data': <String, dynamic>{}};
  }

  /// 立即永久删除当前 Mock 账号及其本地个人与协作数据。
  ///
  /// [headers] 用于识别账号；成功后原 Mock Token 不再能恢复有效用户。
  Future<Map<String, dynamic>> _deleteAccountNow(
    Map<String, dynamic> headers,
  ) async {
    // account 是即将从所有 Mock 集合和持久化文件中移除的账号。
    final account = _emailFromHeaders(headers);
    if (account.isEmpty || !_users.containsKey(account)) {
      return {'code': 401, 'message': '登录已失效'};
    }
    // userId 对应团队成员、任务负责人和通知行为人的公开标识。
    final userId = _userIdForEmail(account);
    // avatarPath 指向 Mock 上传保存的本地个人头像文件。
    final avatarPath = _avatarUrls[account] ?? '';
    if (avatarPath.isNotEmpty) {
      // avatarFile 只来自 Mock 自己保存的应用文档目录路径。
      final avatarFile = File(avatarPath);
      if (await avatarFile.exists()) {
        await avatarFile.delete();
      }
    }

    // ownedTeams 是当前账号创建的协作根数据，删除后其任务也必须移除。
    final ownedTeams = _createdTeams.remove(account) ?? const [];
    // deletedTeamIds 用于从其他账号可见集合和通知中清除被删除团队。
    final deletedTeamIds = ownedTeams
        .map((team) => team['id']?.toString() ?? '')
        .where((teamId) => teamId.isNotEmpty)
        .toSet();
    _createdTasks.remove(account);

    for (final teams in _createdTeams.values) {
      for (final team in teams) {
        // members 可能包含当前账号，需要从其他创建者的团队中解除成员关系。
        final members = team['members'];
        if (members is List) {
          members.removeWhere(
            (member) => member is Map && member['id']?.toString() == userId,
          );
        }
      }
    }
    for (final tasks in _createdTasks.values) {
      tasks.removeWhere((task) {
        // teamId 标识任务所属协作根，被删除团队的全部任务必须一并清除。
        final team = task['team'];
        final teamId = team is Map ? team['id']?.toString() ?? '' : '';
        return deletedTeamIds.contains(teamId);
      });
      for (final task in tasks) {
        // assignees 可能包含当前账号，需要从其他团队任务中解除负责人关系。
        final assignees = task['assignees'];
        if (assignees is List) {
          assignees.removeWhere(
            (member) => member is Map && member['id']?.toString() == userId,
          );
        }
      }
    }
    _notifications.remove(account);
    for (final notifications in _notifications.values) {
      notifications.removeWhere((notification) {
        // actorId 用于清除由被删除账号产生的共享通知内容。
        final actor = notification['actor'];
        final actorId = actor is Map ? actor['id']?.toString() ?? '' : '';
        // teamId 用于清除已删除团队对应的邀请和任务通知。
        final team = notification['team'];
        final teamId = team is Map ? team['id']?.toString() ?? '' : '';
        return actorId == userId || deletedTeamIds.contains(teamId);
      });
    }

    _users.remove(account);
    _phoneRegionCodes.remove(account);
    _displayNames.remove(account);
    _avatarUrls.remove(account);
    _genders.remove(account);
    _birthdays.remove(account);
    _notificationPreferences.remove(account);
    _taskStatusOverrides.remove(account);
    _taskStatusNotes.remove(account);
    _loginDeviceNames.remove(account);
    _loginDevicePlatforms.remove(account);
    _deletionScheduledAt.remove(account);
    await _writeState();
    return {'code': 0, 'message': 'success', 'data': <String, dynamic>{}};
  }

  /// 模拟当前用户信息接口，通过 Authorization 中的 mock session 找回账号。
  Map<String, dynamic> _profile(Map<String, dynamic> headers) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    if (!_users.containsKey(email)) {
      return {'code': 4003, 'message': '登录已失效'};
    }

    return {
      'code': 0,
      'message': 'success',
      'data': {
        'id': _userIdForEmail(email),
        'displayName': _displayNames[email] ?? _defaultDisplayName(email),
        'avatarUrl': _avatarUrls[email] ?? '',
        'gender': _genders[email] ?? 'unspecified',
        'birthday': _birthdays[email] ?? '',
        'email': email.startsWith('+') ? '' : email,
        'phone': email.startsWith('+') ? email : '',
        'phoneRegionCode': _phoneRegionCodes[email] ?? '',
        'hasTeam': _createdTeamsForUser(email).isNotEmpty,
      },
    };
  }

  /// 模拟更新当前用户可编辑资料，并返回保存后的完整用户信息。
  Future<Map<String, dynamic>> _updateProfile(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    if (!_users.containsKey(email)) {
      return {'code': 4003, 'message': '登录已失效'};
    }

    final displayName = parameters['displayName']?.toString().trim() ?? '';
    final avatarUrl = parameters['avatarUrl']?.toString().trim() ?? '';
    final gender = parameters['gender']?.toString().trim() ?? 'unspecified';
    final birthday = parameters['birthday']?.toString().trim() ?? '';

    if (displayName.isEmpty) {
      return {'code': 4000, 'message': '昵称不能为空'};
    }

    if (!const {'male', 'female', 'unspecified'}.contains(gender)) {
      return {'code': 4000, 'message': '性别参数无效'};
    }

    if (birthday.isNotEmpty && DateTime.tryParse(birthday) == null) {
      return {'code': 4000, 'message': '生日格式无效'};
    }

    _displayNames[email] = displayName;
    _avatarUrls[email] = avatarUrl;
    _genders[email] = gender;
    _birthdays[email] = birthday;
    await _writeState();

    return _profile(headers);
  }

  /// 模拟修改密码，验证当前密码后持久化新密码供下次登录使用。
  Future<Map<String, dynamic>> _changePassword(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final storedPasswordRecord = _users[email];

    if (storedPasswordRecord == null) {
      return {'code': 4003, 'message': '登录已失效'};
    }

    final currentPassword = parameters['currentPassword']?.toString() ?? '';
    final newPassword = parameters['newPassword']?.toString() ?? '';

    if (currentPassword.isEmpty || newPassword.length < 6) {
      return {'code': 4000, 'message': '密码参数不完整'};
    }

    if (!_verifyPassword(
      password: currentPassword,
      record: storedPasswordRecord,
    )) {
      return {'code': 4004, 'message': '当前密码错误'};
    }

    _users[email] = _createPasswordRecord(newPassword);
    await _writeState();

    return {'code': 0, 'message': 'success'};
  }

  /// 模拟未登录场景的密码重置，校验统一账号和固定验证码后保存新密码。
  ///
  /// 账号缺失和验证码无效返回同一业务响应，避免暴露账号注册状态。
  Future<Map<String, dynamic>> _resetPassword(
    Map<String, dynamic> parameters,
  ) async {
    // 账号身份、验证码和新密码共同构成未登录重置凭证。
    final identityType = AuthIdentityType.fromValue(parameters['identityType']);
    final account = _normalizeIdentityAccount(
      identityType,
      parameters['account'],
    );
    final code = parameters['code']?.toString().trim() ?? '';
    final newPassword = parameters['newPassword']?.toString() ?? '';

    if (account.isEmpty || code.isEmpty || newPassword.length < 6) {
      return {'code': 4000, 'message': '重置密码参数不完整'};
    }

    if (!_users.containsKey(account)) {
      return {'code': 4001, 'message': '验证码错误或已过期'};
    }

    if (code != verificationCode) {
      return {'code': 4001, 'message': '验证码错误或已过期'};
    }

    _users[account] = _createPasswordRecord(newPassword);
    await _writeState();

    return {'code': 0, 'message': 'success'};
  }

  /// 返回当前账号的通知偏好，新账号默认开启全部提醒。
  Map<String, dynamic> _getNotificationPreferences(
    Map<String, dynamic> headers,
  ) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    if (!_users.containsKey(email)) {
      return {'code': 4003, 'message': '登录已失效'};
    }

    final preferences =
        _notificationPreferences[email] ??
        const {
          'enabled': true,
          'taskAssigned': true,
          'dueReminder': true,
          'collaborationMessages': true,
        };

    return {'code': 0, 'message': 'success', 'data': preferences};
  }

  /// 更新当前账号的通知偏好，并返回服务端保存后的完整状态。
  Future<Map<String, dynamic>> _updateNotificationPreferences(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    if (!_users.containsKey(email)) {
      return {'code': 4003, 'message': '登录已失效'};
    }

    final preferences = {
      'enabled': parameters['enabled'] as bool? ?? true,
      'taskAssigned': parameters['taskAssigned'] as bool? ?? true,
      'dueReminder': parameters['dueReminder'] as bool? ?? true,
      'collaborationMessages':
          parameters['collaborationMessages'] as bool? ?? true,
    };
    _notificationPreferences[email] = preferences;
    await _writeState();

    return {'code': 0, 'message': 'success', 'data': preferences};
  }

  /// 返回当前账号最近通知，待处理项目始终排在已处理项目之前。
  Map<String, dynamic> _notificationList(Map<String, dynamic> headers) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final notifications = (_notifications[email] ?? const [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    notifications.sort((left, right) {
      final leftPending = left['status'] == 'pending';
      final rightPending = right['status'] == 'pending';
      if (leftPending != rightPending) {
        return leftPending ? -1 : 1;
      }
      return (right['createdAt']?.toString() ?? '').compareTo(
        left['createdAt']?.toString() ?? '',
      );
    });

    return {'code': 0, 'message': 'success', 'data': notifications};
  }

  /// 处理当前账号的一条通知，并同步邀请成员关系或任务最终状态。
  Future<Map<String, dynamic>> _handleNotification(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final notificationId =
        parameters['notificationId']?.toString().trim() ?? '';
    final action = parameters['action']?.toString().trim() ?? '';
    final notifications = _notifications[email] ?? const [];
    Map<String, dynamic>? notification;

    for (final candidate in notifications) {
      if (candidate['id']?.toString() == notificationId &&
          candidate['status'] == 'pending') {
        notification = candidate;
        break;
      }
    }

    if (notification == null) {
      return {'code': 4040, 'message': '通知不存在或已经处理'};
    }

    switch (notification['type']) {
      case 'teamInvitation':
        if (!{'accept', 'reject'}.contains(action)) {
          return {'code': 4000, 'message': '邀请通知操作无效'};
        }
        if (action == 'accept') {
          final teamData = notification['team'];
          final teamId = teamData is Map
              ? teamData['id']?.toString() ?? ''
              : '';
          final team = _teamByIdGlobally(teamId);
          if (team == null) {
            return {'code': 4090, 'message': '邀请关联团队无效'};
          }
          final members = team['members'];
          final currentMember = _currentMember(email);
          final currentUserId = currentMember['id']?.toString() ?? '';
          if (members is List &&
              !members.whereType<Map>().any(
                (member) => member['id']?.toString() == currentUserId,
              )) {
            members.add(currentMember);
          }
        }
        notification['status'] = action == 'accept' ? 'accepted' : 'rejected';

      case 'taskCompletion':
        if (!{'confirm', 'reject'}.contains(action)) {
          return {'code': 4000, 'message': '任务确认操作无效'};
        }
        final taskData = notification['task'];
        final taskId = taskData is Map ? taskData['id']?.toString() ?? '' : '';
        final task = _taskById(taskId);
        if (task == null || task['filter'] != 'pendingConfirmation') {
          return {'code': 4090, 'message': '任务已经不处于待确认状态'};
        }
        if (action == 'confirm') {
          task
            ..['statusLabel'] = '已完成'
            ..['filter'] = 'completed'
            ..['completed'] = true;
          notification['status'] = 'confirmed';
        } else {
          task
            ..['statusLabel'] = '进行中'
            ..['filter'] = 'inProgress'
            ..['completed'] = false
            ..remove('statusNote');
          notification['status'] = 'rejected';
        }

      default:
        return {'code': 4000, 'message': '不支持的通知类型'};
    }

    await _writeState();
    return {'code': 0, 'message': 'success', 'data': null};
  }

  /// 模拟 Dashboard 汇总接口，根据当前账号可见任务动态计算数量。
  Map<String, dynamic> _dashboardSummary(Map<String, dynamic> headers) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    // Dashboard 只统计分配给当前账号的任务，状态字段与列表筛选保持一致。
    final tasks = _tasksForUser(email)
        .map((task) => _applyTaskStatusOverride(email, task))
        .toList(growable: false);
    final dueTodayCount = tasks.where(_isActiveDueTodayTask).length;
    final inProgressCount = tasks
        .where((task) => task['filter']?.toString() == 'inProgress')
        .length;
    // 未读数与真实服务一致，只统计仍需当前账号作出决定的通知。
    final unreadCount = (_notifications[email] ?? const [])
        .where((notification) => notification['status'] == 'pending')
        .length;

    return {
      'code': 0,
      'message': 'success',
      'data': {
        'myTaskCount': tasks.length,
        'dueTodayCount': dueTodayCount,
        'inProgressCount': inProgressCount,
        'unreadCount': unreadCount,
      },
    };
  }

  /// 模拟可筛选任务列表接口，同时支持按团队标识缩小范围。
  Map<String, dynamic> _tasks(
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> headers,
  ) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final filter = queryParameters['filter']?.toString() ?? 'all';
    final teamId = queryParameters['teamId']?.toString() ?? '';
    // 团队详情展示团队全部任务，普通任务列表只展示当前用户负责的任务。
    Iterable<Map<String, dynamic>> tasks = teamId.isEmpty
        ? _tasksForUser(email)
        : _tasksForTeam(email, teamId);
    tasks = tasks.map((task) => _applyTaskStatusOverride(email, task));

    if (filter != 'all') {
      tasks = tasks.where((task) => task['filter'] == filter);
    }

    if (teamId.isNotEmpty) {
      tasks = tasks.where((task) {
        final team = task['team'];
        return team is Map && team['id']?.toString() == teamId;
      });
    }

    return {'code': 0, 'message': 'success', 'data': tasks.toList()};
  }

  /// 返回带负责人和完成状态的固定任务数据。
  List<Map<String, dynamic>> _seededTasks(String email) {
    final currentMember = _currentMember(email);

    return [
      {
        'id': 'task-001',
        'title': '星河 2.0 界面设计评审',
        'description': '完成核心页面评审，记录交互问题并输出修改结论。',
        'time': '今天 10:00 AM - 11:30 AM',
        'statusLabel': '进行中',
        'filter': 'inProgress',
        'completed': false,
        'team': {'id': 'team-dev', 'name': '代码开发团队'},
        'assignees': [
          currentMember,
          {'id': 'user-002', 'name': '李四', 'avatarUrl': ''},
          {'id': 'user-003', 'name': '王五', 'avatarUrl': ''},
        ],
      },
      {
        'id': 'task-002',
        'title': '客户反馈文档整理',
        'description': '归类本周客户反馈，补充优先级并同步给产品团队。',
        'time': '今天截止 03:00 PM',
        'statusLabel': '紧迫',
        'filter': 'dueToday',
        'completed': false,
        'team': {'id': 'team-product', 'name': '产品设计团队'},
        'assignees': [
          {'id': 'user-008', 'name': '周宁', 'avatarUrl': ''},
        ],
      },
      {
        'id': 'task-003',
        'title': '季度报告初稿提交',
        'description': '汇总季度运营数据和阶段结论，提交第一版报告。',
        'time': '今天截止 06:00 PM',
        'statusLabel': '紧迫',
        'filter': 'dueToday',
        'completed': false,
        'team': {'id': 'team-operations', 'name': '运营管理团队'},
        'assignees': [
          {'id': 'user-010', 'name': '陈辰', 'avatarUrl': ''},
          {'id': 'user-011', 'name': '唐静', 'avatarUrl': ''},
        ],
      },
      {
        'id': 'task-004',
        'title': '新版任务流程联调',
        'description': '联调任务创建、负责人选择和状态流转的完整流程。',
        'time': '明天 09:30 AM',
        'statusLabel': '进行中',
        'filter': 'inProgress',
        'completed': false,
        'team': {'id': 'team-dev', 'name': '代码开发团队'},
        'assignees': [
          {'id': 'user-004', 'name': '赵六', 'avatarUrl': ''},
          {'id': 'user-005', 'name': '陈七', 'avatarUrl': ''},
        ],
      },
      {
        'id': 'task-005',
        'title': '团队周会纪要确认',
        'description': '核对周会行动项并确认各项工作的负责人和截止时间。',
        'time': '今天截止 08:00 PM',
        'statusLabel': '已完成',
        'filter': 'completed',
        'completed': true,
        'team': {'id': 'team-dev', 'name': '代码开发团队'},
        'assignees': [
          {'id': 'user-006', 'name': '刘八', 'avatarUrl': ''},
        ],
      },
      {
        'id': 'task-006',
        'title': '项目里程碑进度检查',
        'description': '检查当前里程碑完成情况并记录存在的风险。',
        'time': '本周五 04:00 PM',
        'statusLabel': '已完成',
        'filter': 'completed',
        'completed': true,
        'team': {'id': 'team-product', 'name': '产品设计团队'},
        'assignees': [
          {'id': 'user-007', 'name': '林晓', 'avatarUrl': ''},
          {'id': 'user-009', 'name': '苏菲', 'avatarUrl': ''},
        ],
      },
    ];
  }

  /// 模拟创建任务，并在服务端侧校验当前用户是否为团队创建者。
  Future<Map<String, dynamic>> _createTask(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final teamId = parameters['teamId']?.toString() ?? '';
    final title = parameters['title']?.toString().trim() ?? '';
    final description = parameters['description']?.toString().trim() ?? '';
    final time = parameters['time']?.toString().trim() ?? '';
    final rawAssigneeIds = parameters['assigneeIds'];
    final assigneeIds = rawAssigneeIds is List
        ? rawAssigneeIds.map((id) => id.toString()).toSet()
        : <String>{};
    final team = _teamById(teamId, email);

    if (team == null) {
      return {'code': 4040, 'message': '团队不存在'};
    }

    final creator = team['creator'];
    final creatorId = creator is Map ? creator['id']?.toString() ?? '' : '';

    if (creatorId != _userIdForEmail(email)) {
      return {'code': 4030, 'message': '只有团队创建者可以创建任务'};
    }

    final members = team['members'];
    final assignees = members is List
        ? members
              .whereType<Map<String, dynamic>>()
              .where((member) => assigneeIds.contains(member['id']?.toString()))
              .toList(growable: false)
        : <Map<String, dynamic>>[];

    if (title.isEmpty ||
        description.isEmpty ||
        time.isEmpty ||
        assignees.isEmpty) {
      return {'code': 4000, 'message': '请填写任务信息并选择负责人'};
    }

    final now = DateTime.now();
    final task = <String, dynamic>{
      'id': 'task-${now.microsecondsSinceEpoch}',
      'title': title,
      'description': description,
      'time': time,
      'statusLabel': '进行中',
      'filter': 'inProgress',
      'completed': false,
      'team': {'id': teamId, 'name': team['name']?.toString() ?? ''},
      'assignees': assignees,
    };

    _createdTasks.putIfAbsent(email, () => []).insert(0, task);
    await _writeState();

    return {'code': 0, 'message': 'success', 'data': task};
  }

  /// 模拟首页快捷更新任务状态，并持久化任务快照或演示数据覆盖结果。
  Future<Map<String, dynamic>> _updateTaskStatus(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final taskId = parameters['taskId']?.toString().trim() ?? '';
    final status = parameters['status']?.toString().trim() ?? '';
    final note = parameters['note']?.toString().trim() ?? '';

    if (taskId.isEmpty ||
        !{'completed', 'postponed'}.contains(status) ||
        note.length > 200) {
      return {'code': 4000, 'message': '任务状态参数无效'};
    }

    // 当前用户只能操作自己负责且可见的任务。
    final tasks = _tasksForUser(email);
    Map<String, dynamic>? matchedTask;

    for (final task in tasks) {
      if (task['id']?.toString() == taskId) {
        matchedTask = task;
        break;
      }
    }

    if (matchedTask == null) {
      return {'code': 4040, 'message': '任务不存在'};
    }

    // 所有任务已进入版本化存储，直接更新共享快照可保证不同成员看到一致状态。
    switch (status) {
      case 'completed':
        final creatorEmail = _taskCreatorEmail(taskId);
        if (creatorEmail != null && creatorEmail != email) {
          matchedTask
            ..['statusLabel'] = '待确认'
            ..['filter'] = 'pendingConfirmation'
            ..['completed'] = false;
          final now = DateTime.now();
          final team = matchedTask['team'];
          _notifications.putIfAbsent(creatorEmail, () => []).insert(0, {
            'id': 'notification-${now.microsecondsSinceEpoch}',
            'type': 'taskCompletion',
            'status': 'pending',
            'actor': _currentMember(email),
            'team': team is Map
                ? Map<String, dynamic>.from(team)
                : const <String, dynamic>{},
            'task': {
              'id': taskId,
              'title': matchedTask['title']?.toString() ?? '',
              if (note.isNotEmpty) 'note': note,
            },
            'createdAt': now.toIso8601String(),
          });
        } else {
          matchedTask
            ..['statusLabel'] = '已完成'
            ..['filter'] = 'completed'
            ..['completed'] = true;
        }
      case 'postponed':
        matchedTask
          ..['statusLabel'] = '已延后'
          ..['filter'] = 'postponed'
          ..['completed'] = false;
    }

    if (note.isEmpty) {
      matchedTask.remove('statusNote');
    } else {
      matchedTask['statusNote'] = note;
    }

    await _writeState();
    final updatedTask = Map<String, dynamic>.from(matchedTask);

    return {'code': 0, 'message': 'success', 'data': updatedTask};
  }

  /// 将当前账号保存的状态覆盖应用到任务副本，不污染预置任务模板。
  Map<String, dynamic> _applyTaskStatusOverride(
    String email,
    Map<String, dynamic> task,
  ) {
    final taskId = task['id']?.toString() ?? '';
    final status = _taskStatusOverrides[email]?[taskId];
    final note = _taskStatusNotes[email]?[taskId];
    final updatedTask = Map<String, dynamic>.from(task);

    switch (status) {
      case 'completed':
        updatedTask
          ..['statusLabel'] = '已完成'
          ..['filter'] = 'completed'
          ..['completed'] = true;
      case 'postponed':
        updatedTask
          ..['statusLabel'] = '已延后'
          ..['filter'] = 'postponed'
          ..['completed'] = false;
      default:
        break;
    }

    if (note != null && note.isNotEmpty) {
      updatedTask['statusNote'] = note;
    }

    return updatedTask;
  }

  /// 模拟今日待办接口，从当前账号任务中筛选今天且未结束的项目。
  Map<String, dynamic> _todayTasks(Map<String, dynamic> headers) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final tasks = _tasksForUser(email)
        .map((task) => _applyTaskStatusOverride(email, task))
        .where(_isActiveDueTodayTask)
        .toList(growable: false);

    return {'code': 0, 'message': 'success', 'data': tasks};
  }

  /// 判断任务是否仍处于活动状态且计划时间属于今天。
  ///
  /// [task] 可以使用中文演示时间或 YYYY-MM-DD 日期；完成、延后和待确认任务会被排除。
  bool _isActiveDueTodayTask(Map<String, dynamic> task) {
    final filter = task['filter']?.toString() ?? '';
    final time = task['time']?.toString() ?? '';
    final today = _dateOnly(DateTime.now());
    final active =
        filter != 'completed' &&
        filter != 'postponed' &&
        filter != 'pendingConfirmation';
    final dueToday = time.contains('今天') || time.contains(today);
    return active && dueToday;
  }

  /// 模拟创建团队，当前账号自动成为创建人和首位成员。
  Future<Map<String, dynamic>> _createTeam(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final name = parameters['name']?.toString().trim() ?? '';
    final description = parameters['description']?.toString().trim() ?? '';
    final avatarUrl = parameters['avatarUrl']?.toString().trim() ?? '';

    if (name.isEmpty) {
      return {'code': 4000, 'message': '团队名称不能为空'};
    }

    final creator = <String, dynamic>{
      'id': _userIdForEmail(email),
      'name': _displayNames[email] ?? _defaultDisplayName(email),
      'avatarUrl': _avatarUrls[email] ?? '',
    };
    final now = DateTime.now();
    final team = <String, dynamic>{
      // 时间戳仅用于 Mock 环境生成不重复标识，真实服务端应使用持久化主键。
      'id': 'team-${now.microsecondsSinceEpoch}',
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'creator': creator,
      'members': [creator],
      'createdAt': now.toIso8601String(),
      'startDate': _dateOnly(now),
      'endDate': null,
    };

    _createdTeams.putIfAbsent(email, () => []).insert(0, team);
    await _writeState();

    return {'code': 0, 'message': 'success', 'data': team};
  }

  /// 通过用户 ID 发送团队邀请，并校验创建者权限、用户存在性和重复关系。
  Future<Map<String, dynamic>> _addTeamMember(
    Map<String, dynamic> parameters,
    Map<String, dynamic> headers,
  ) async {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final teamId = parameters['teamId']?.toString().trim() ?? '';
    final userId = parameters['userId']?.toString().trim() ?? '';
    final team = _teamById(teamId, email);

    if (team == null) {
      return {'code': 4040, 'message': '团队不存在'};
    }

    final creator = team['creator'];
    final creatorId = creator is Map ? creator['id']?.toString() ?? '' : '';

    if (creatorId != _userIdForEmail(email)) {
      return {'code': 4030, 'message': '只有团队创建者可以邀请成员'};
    }

    String? memberEmail;

    for (final candidateEmail in _users.keys) {
      if (_userIdForEmail(candidateEmail) == userId) {
        memberEmail = candidateEmail;
        break;
      }
    }

    if (memberEmail == null) {
      return {'code': 4041, 'message': '用户 ID 不存在'};
    }

    final members = team['members'];
    final alreadyJoined =
        members is List &&
        members.whereType<Map>().any(
          (member) => member['id']?.toString() == userId,
        );

    if (alreadyJoined) {
      return {'code': 4090, 'message': '该用户已经是团队成员'};
    }

    final member = _memberForEmail(memberEmail);
    final recipientNotifications = _notifications.putIfAbsent(
      memberEmail,
      () => [],
    );
    final alreadyInvited = recipientNotifications.any((notification) {
      final relatedTeam = notification['team'];
      return notification['type'] == 'teamInvitation' &&
          notification['status'] == 'pending' &&
          relatedTeam is Map &&
          relatedTeam['id']?.toString() == teamId;
    });
    if (alreadyInvited) {
      return {'code': 4091, 'message': '已经向该用户发送过团队邀请'};
    }

    final now = DateTime.now();
    recipientNotifications.insert(0, {
      'id': 'notification-${now.microsecondsSinceEpoch}',
      'type': 'teamInvitation',
      'status': 'pending',
      'actor': _currentMember(email),
      'team': {'id': teamId, 'name': team['name']?.toString() ?? ''},
      'task': const <String, dynamic>{},
      'createdAt': now.toIso8601String(),
    });
    await _writeState();

    return {'code': 0, 'message': 'success', 'data': member};
  }

  /// 模拟当前用户的多团队列表，返回创建或被加入的持久化团队。
  Map<String, dynamic> _teams(Map<String, dynamic> headers) {
    final email = _emailFromHeaders(headers);

    if (email.isEmpty) {
      return {'code': 401, 'message': '登录已失效'};
    }

    final createdTeams = _createdTeamsForUser(email);

    return {'code': 0, 'message': 'success', 'data': createdTeams};
  }

  /// 返回固定团队数据，供列表、任务创建权限和负责人校验共同使用。
  List<Map<String, dynamic>> _seededTeams(String email) {
    final currentMember = _currentMember(email);

    return [
      {
        'id': 'team-dev',
        'name': '代码开发团队',
        'description': '负责产品研发、版本维护以及日常技术问题处理。',
        'avatarUrl': '',
        'creator': currentMember,
        'members': [
          currentMember,
          {'id': 'user-002', 'name': '李四', 'avatarUrl': ''},
          {'id': 'user-003', 'name': '王五', 'avatarUrl': ''},
          {'id': 'user-004', 'name': '赵六', 'avatarUrl': ''},
          {'id': 'user-005', 'name': '陈七', 'avatarUrl': ''},
          {'id': 'user-006', 'name': '刘八', 'avatarUrl': ''},
        ],
        'createdAt': '2026-01-12T09:30:00+08:00',
        'startDate': '2026-01-15',
        'endDate': '2026-12-31',
      },
      {
        'id': 'team-product',
        'name': '产品设计团队',
        'description': '围绕产品体验完成需求分析、交互设计和视觉交付。',
        'avatarUrl': '',
        'creator': {'id': 'user-007', 'name': '林晓', 'avatarUrl': ''},
        'members': [
          {'id': 'user-007', 'name': '林晓', 'avatarUrl': ''},
          {'id': 'user-008', 'name': '周宁', 'avatarUrl': ''},
          {'id': 'user-009', 'name': '苏菲', 'avatarUrl': ''},
        ],
        'createdAt': '2026-03-05T14:00:00+08:00',
        'startDate': '2026-03-10',
        'endDate': null,
      },
      {
        'id': 'team-operations',
        'name': '运营管理团队',
        'description': '负责活动运营、内容管理和阶段目标跟进。',
        'avatarUrl': '',
        'creator': {'id': 'user-010', 'name': '陈辰', 'avatarUrl': ''},
        'members': [
          {'id': 'user-010', 'name': '陈辰', 'avatarUrl': ''},
          {'id': 'user-011', 'name': '唐静', 'avatarUrl': ''},
          {'id': 'user-012', 'name': '方宇', 'avatarUrl': ''},
          {'id': 'user-013', 'name': '夏安', 'avatarUrl': ''},
        ],
        'createdAt': '2026-05-20T10:15:00+08:00',
        'startDate': '2026-06-01',
        'endDate': '2026-09-30',
      },
    ];
  }

  /// 根据团队标识查找当前用户可访问的团队。
  Map<String, dynamic>? _teamById(String teamId, String email) {
    final teams = _createdTeamsForUser(email);

    for (final team in teams) {
      if (team['id']?.toString() == teamId) {
        return team;
      }
    }

    return null;
  }

  /// 在所有创建者的团队中按 [teamId] 查找记录，供被邀请人接受前建立成员关系。
  Map<String, dynamic>? _teamByIdGlobally(String teamId) {
    for (final team in _createdTeams.values.expand((teams) => teams)) {
      if (team['id']?.toString() == teamId) {
        return team;
      }
    }

    return null;
  }

  /// 返回当前账号创建或被加入的运行期团队。
  List<Map<String, dynamic>> _createdTeamsForUser(String email) {
    final userId = _userIdForEmail(email);

    return _createdTeams.entries
        .expand((entry) => entry.value)
        .where((team) {
          final creator = team['creator'];
          final creatorId = creator is Map
              ? creator['id']?.toString() ?? ''
              : '';
          final members = team['members'];
          final isMember =
              members is List &&
              members.whereType<Map>().any(
                (member) => member['id']?.toString() == userId,
              );

          return creatorId == userId || isMember;
        })
        .toList(growable: false);
  }

  /// 返回分配给当前账号的任务，跨创建者汇总以模拟服务端成员查询。
  List<Map<String, dynamic>> _tasksForUser(String email) {
    // 当前用户 ID 用于匹配每条任务的负责人数组。
    final userId = _userIdForEmail(email);
    // 可访问团队集合阻止其他团队任务通过伪造负责人数据泄漏。
    final accessibleTeamIds = _createdTeamsForUser(email)
        .map((team) => team['id']?.toString() ?? '')
        .where((teamId) => teamId.isNotEmpty)
        .toSet();

    return _createdTasks.values
        .expand((tasks) => tasks)
        .where((task) {
          final team = task['team'];
          final teamId = team is Map ? team['id']?.toString() ?? '' : '';
          final assignees = task['assignees'];
          final isAssignee =
              assignees is List &&
              assignees.whereType<Map>().any(
                (member) => member['id']?.toString() == userId,
              );

          return accessibleTeamIds.contains(teamId) && isAssignee;
        })
        .toList(growable: false);
  }

  /// 返回当前账号可访问团队的全部任务，供团队详情展示整体进度。
  List<Map<String, dynamic>> _tasksForTeam(String email, String teamId) {
    // 先验证成员关系，避免直接通过团队 ID 读取其他团队数据。
    final hasAccess = _createdTeamsForUser(
      email,
    ).any((team) => team['id']?.toString() == teamId);

    if (!hasAccess) {
      return const [];
    }

    return _createdTasks.values
        .expand((tasks) => tasks)
        .where((task) {
          final team = task['team'];
          return team is Map && team['id']?.toString() == teamId;
        })
        .toList(growable: false);
  }

  /// 返回 [taskId] 对应的共享任务记录，通知确认后直接更新该对象。
  Map<String, dynamic>? _taskById(String taskId) {
    for (final task in _createdTasks.values.expand((tasks) => tasks)) {
      if (task['id']?.toString() == taskId) {
        return task;
      }
    }

    return null;
  }

  /// 返回创建 [taskId] 的账号，用于把他人提交的完成确认发送给任务创建者。
  String? _taskCreatorEmail(String taskId) {
    for (final entry in _createdTasks.entries) {
      if (entry.value.any((task) => task['id']?.toString() == taskId)) {
        return entry.key;
      }
    }

    return null;
  }

  /// 构建当前登录用户的成员摘要，保证预置自建团队与权限判断使用同一 ID。
  Map<String, dynamic> _currentMember(String email) {
    return _memberForEmail(email);
  }

  /// 根据账号构建成员摘要，添加成员和团队创建共用同一展示信息。
  Map<String, dynamic> _memberForEmail(String email) {
    return {
      'id': _userIdForEmail(email),
      'name': _displayNames[email] ?? _defaultDisplayName(email),
      'avatarUrl': _avatarUrls[email] ?? '',
    };
  }

  /// 将本地时间转换为 YYYY-MM-DD，避免 Mock 日期受时区序列化格式影响。
  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  /// 标准化邮箱，保证注册和登录用同一个 key 访问内存用户表。
  String _normalizeEmail(Object? value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  /// 标准化完整国际手机号，只接受带加号的号码并移除空格、横线和括号。
  ///
  /// [value] 可以来自请求或成员搜索；返回空字符串表示不是有效 E.164 结构。
  String _normalizePhoneAccount(Object? value) {
    final rawValue = value?.toString().trim() ?? '';
    if (!rawValue.startsWith('+')) {
      return '';
    }

    final normalized = '+${rawValue.replaceAll(RegExp(r'\D'), '')}';
    return AuthIdentity.isValidPhone(normalized) ? normalized : '';
  }

  /// 按认证类型标准化账号，避免手机号被错误套用邮箱小写规则。
  ///
  /// [identityType] 决定标准化策略；[value] 是接口提交的账号字段。
  String _normalizeIdentityAccount(
    AuthIdentityType identityType,
    Object? value,
  ) {
    return identityType == AuthIdentityType.phone
        ? _normalizePhoneAccount(value)
        : _normalizeEmail(value);
  }

  /// 生成 Mock 新账号的默认展示名，邮箱使用前缀，手机号保留完整国际格式。
  ///
  /// [account] 必须是已标准化账号；返回值始终可用于资料和成员卡片展示。
  String _defaultDisplayName(String account) {
    return account.startsWith('+') ? account : account.split('@').first;
  }

  /// 根据标准化账号生成稳定的开发用户 ID，保证重启和资料修改后标识不变。
  ///
  /// 正式环境必须由服务端数据库生成全局唯一 ID；该哈希只服务于 Mock 演示。
  String _userIdForEmail(String email) {
    var hash = 0x811C9DC5;

    for (final byte in utf8.encode(email)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    final value = hash.toRadixString(16).padLeft(8, '0').toUpperCase();
    return 'user-$value';
  }

  /// 从认证头中的 Mock session 反推出标准化账号，用于模拟后端识别当前用户。
  String _emailFromHeaders(Map<String, dynamic> headers) {
    final authorization = headers['Authorization']?.toString() ?? '';
    const bearerPrefix = 'Bearer ';
    const sessionPrefix = 'mock-session-';

    if (!authorization.startsWith(bearerPrefix)) {
      return '';
    }

    final session = authorization.substring(bearerPrefix.length);

    if (!session.startsWith(sessionPrefix)) {
      return '';
    }

    final account = session.substring(sessionPrefix.length);
    return account.startsWith('+')
        ? _normalizePhoneAccount(account)
        : _normalizeEmail(account);
  }

  /// 构造 Mock session，模拟真实后端登录成功后的统一账号响应。
  ///
  /// [email] 沿用现有内部参数名但可承载邮箱或 E.164 手机号；返回 token
  /// 可由认证头解析回同一账号。
  Map<String, dynamic> _buildSession(String email) {
    return {'token': 'mock-session-$email', 'account': email};
  }
}
