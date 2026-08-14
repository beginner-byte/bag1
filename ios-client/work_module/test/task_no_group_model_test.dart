import 'package:flutter_test/flutter_test.dart';
import 'package:work_module/core/model/task/task.item.model.dart';

void main() {
  test('groupless task payload remains non-actionable', () {
    final task = TaskItem.fromJson({
      'id': 'task-1',
      'teamId': 'team-1',
      'title': 'Prepare release',
      'description': 'No task-owned group',
      'status': 'inProgress',
      'assignees': const [],
    });

    expect(task.groupId, isEmpty);
    expect(task.groupAction, 'none');
    expect(task.groupOperationId, isEmpty);
  });
}
