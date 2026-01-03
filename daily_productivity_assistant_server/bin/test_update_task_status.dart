import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';
import 'package:daily_productivity_assistant_server/src/endpoints/task_endpoint.dart';

Future<void> main(List<String> args) async {
  // Bootstrap a Serverpod instance so Serverpod.instance is available
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );
  await pod.start();

  try {
    final session = await Serverpod.instance.createSession();

    const taskId = 1; // 👈 put a REAL task id from DB
    const newStatus = 'completed';

    final endpoint = TaskEndpoint();

    await endpoint.updateTaskStatus(
      session,
      taskId,
      newStatus,
    );

    final updatedTask = await Task.db.findById(session, taskId);

    print('Updated task:');
    print('Status: ${updatedTask?.status}');
    print('CompletedAt: ${updatedTask?.completedAt}');
    print('UpdatedAt: ${updatedTask?.updatedAt}');

    await session.close();
  } finally {
    // Cleanly shut down the embedded Serverpod
    await pod.shutdown(exitProcess: false);
  }
}
