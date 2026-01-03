import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';

Future<void> main(List<String> args) async {
  // Bootstrap a Serverpod instance
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );
  await pod.start();

  try {
    final session = await Serverpod.instance.createSession();

    print('🗑️  Deleting all tasks...');
    
    // Get all tasks
    final allTasks = await Task.db.find(session);
    print('Found ${allTasks.length} tasks to delete');

    // Delete each task
    int deletedCount = 0;
    for (final task in allTasks) {
      try {
        await Task.db.deleteRow(session, task);
        deletedCount++;
        print('✅ Deleted task: ${task.id} - ${task.title}');
      } catch (e) {
        print('❌ Failed to delete task ${task.id}: $e');
      }
    }

    print('\n✨ Cleanup complete: $deletedCount tasks deleted');
    
  } catch (e) {
    print('❌ Error during cleanup: $e');
  } finally {
    await Serverpod.instance.shutdown();
  }
}
