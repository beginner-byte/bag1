import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/core/model/team/team.item.model.dart';

void main() {
  test('team group command parses the complete Worker member set', () {
    final command = TeamGroupCommand.fromJson({
      'action': 'create',
      'teamId': 'team-1',
      'title': 'Design',
      'operationId': 'operation-1',
      'members': [
        {
          'id': 'member-1',
          'candyUserUid': 'candy-1',
          'name': 'One',
          'avatarUrl': '',
        },
        {
          'id': 'member-2',
          'candyUserUid': 'candy-2',
          'name': 'Two',
          'avatarUrl': '',
        },
        {
          'id': 'member-3',
          'candyUserUid': 'candy-3',
          'name': 'Three',
          'avatarUrl': '',
        },
      ],
    });

    expect(command.action, 'create');
    expect(command.teamId, 'team-1');
    expect(command.members.map((member) => member.candyUserUid), [
      'candy-1',
      'candy-2',
      'candy-3',
    ]);
  });

  test('legacy team payload remains non-actionable', () {
    final team = TeamItem.fromJson({
      'id': 'team-legacy',
      'name': 'Legacy',
      'creator': {'id': 'creator', 'name': 'Creator', 'avatarUrl': ''},
      'members': const [],
    });

    expect(team.groupStatus, 'legacy');
    expect(team.groupAction, 'none');
    expect(team.groupId, isEmpty);
  });

  test('member invite command identifies exactly one new team member', () {
    final command = TeamGroupMemberCommand.fromJson({
      'action': 'invite_member',
      'teamId': 'team-1',
      'groupId': 'group-1',
      'operationId': 'operation-2',
      'member': {
        'id': 'member-4',
        'candyUserUid': 'candy-4',
        'name': 'Four',
        'avatarUrl': '',
      },
    });

    expect(command.action, 'invite_member');
    expect(command.groupId, 'group-1');
    expect(command.member.candyUserUid, 'candy-4');
  });
}
