import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/core/host/work_host_bridge.dart';
import 'package:work_module/core/model/user.dart';
import 'package:work_module/core/network/auth/profile.target.dart';
import 'package:work_module/core/network/auth/update.profile.target.dart';
import 'package:work_module/core/network/core/http.method.dart';
import 'package:work_module/core/network/task/add.task.assignees.target.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('profile response preserves editable Worker fields', () {
    final user = User.fromJson({
      'id': 'worker-1',
      'displayName': 'Cohere User',
      'avatarUrl': 'https://example.com/avatar.png',
      'gender': 'female',
      'birthday': '2000-08-11',
      'email': 'cohere@example.com',
      'hasTeam': true,
    });

    expect(user.id, 'worker-1');
    expect(user.displayName, 'Cohere User');
    expect(user.gender, 'female');
    expect(user.birthday, '2000-08-11');
    expect(user.primaryAccount, 'cohere@example.com');
  });

  test('profile target uses protected profile endpoint', () {
    final target = ProfileTarget();

    expect(target.method, HttpMethod.post);
    expect(target.path, '/v1/auth/profile');
  });

  test('update profile target sends every editable field', () {
    final target = UpdateProfileTarget(
      displayName: 'New name',
      avatarUrl: 'https://example.com/new.png',
      gender: 'unspecified',
      birthday: '1999-01-02',
    );

    expect(target.method, HttpMethod.patch);
    expect(target.path, '/v1/auth/profile/update');
    expect(target.task.parameters, {
      'displayName': 'New name',
      'avatarUrl': 'https://example.com/new.png',
      'gender': 'unspecified',
      'birthday': '1999-01-02',
    });
  });

  test('profile bridge sends IM name and avatar bytes to CandyTalk', () async {
    const channel = MethodChannel('test.cohere/profile');
    MethodCall? profileCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'updateCurrentUserProfile') {
            profileCall = call;
            return {'avatarUrl': 'candy/avatar/new.jpg'};
          }
          return true;
        });
    final bridge = WorkHostBridge(channel: channel);
    final avatarBytes = Uint8List.fromList([1, 2, 3]);

    final avatarUrl = await bridge.updateCurrentUserProfile(
      displayName: 'New IM name',
      avatarBytes: avatarBytes,
      avatarFileName: 'avatar.jpg',
    );

    expect(profileCall?.method, 'updateCurrentUserProfile');
    expect(profileCall?.arguments, {
      'displayName': 'New IM name',
      'avatarBytes': avatarBytes,
      'avatarFileName': 'avatar.jpg',
    });
    expect(avatarUrl, 'candy/avatar/new.jpg');
    bridge.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('add task assignees target sends task and worker user ids', () {
    final target = AddTaskAssigneesTarget(
      taskId: 'task-1',
      assigneeIds: const ['worker-2', 'worker-3'],
    );

    expect(target.method, HttpMethod.post);
    expect(target.path, '/v1/tasks/assignees');
    expect(target.task.parameters, {
      'taskId': 'task-1',
      'assigneeIds': ['worker-2', 'worker-3'],
    });
  });
}
