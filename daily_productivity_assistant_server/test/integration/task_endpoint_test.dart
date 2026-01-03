import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';
import 'package:daily_productivity_assistant_server/src/endpoints/task_endpoint.dart';

void main() {
  group('TaskEndpoint', () {
    late Session session;
    late Serverpod pod;

    setUpAll(() async {
      // Bootstrap Serverpod for testing with migrations enabled
      pod = Serverpod(
        ['--mode', 'test', '--apply-migrations'],
        Protocol(),
        Endpoints(),
      );
      await pod.start();
    });

    setUp(() async {
      // Create a fresh session for each test
      session = await pod.createSession();
    });

    tearDown(() async {
      await session.close();
    });

    tearDownAll(() async {
      await pod.shutdown(exitProcess: false);
    });

    test('updateTaskStatus updates status correctly', () async {
      // Create a test task
      var task = Task(
        goalId: 1,
        title: 'Test Task',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'medium',
        status: 'pending',
        updatedAt: DateTime.now(),
      );

      // Insert task into database
      var insertedTask = await Task.db.insert(session, [task]);

      // Get the ID from the inserted task
      int taskId = insertedTask.first.id!;
      expect(taskId, isNotNull);

      // Call endpoint to update status
      final endpoint = TaskEndpoint();
      await endpoint.updateTaskStatus(
        session,
        taskId,
        'completed',
      );

      // Refetch from DB to verify persistence
      var persistedTask = await Task.db.findById(session, taskId);

      // Verify task was refetched
      expect(persistedTask, isNotNull);

      // Verify update
      expect(persistedTask!.status, 'completed');
      expect(persistedTask.completedAt, isNotNull);
      expect(persistedTask.updatedAt, isNotNull);

      // Cleanup: delete the task
      await Task.db.delete(session, [persistedTask]);
    });
  });
}
