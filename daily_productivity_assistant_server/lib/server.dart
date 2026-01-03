import 'package:daily_productivity_assistant_server/src/birthday_reminder.dart';
import 'package:serverpod/serverpod.dart';

import 'package:daily_productivity_assistant_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

void main(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  
  // Comment out the static route - not needed since you're using custom routes
  // pod.webServer.addRoute(
  //   StaticRoute.directory(Directory('static')),
  //   '/',
  // );

  // Start the server.
  await pod.start();

  pod.registerFutureCall(
    BirthdayReminder(),
    FutureCallNames.birthdayReminder.name,
  );

  await pod.futureCallWithDelay(
    FutureCallNames.birthdayReminder.name,
    Greeting(
      message: 'Hello!',
      author: 'Serverpod Server',
      timestamp: DateTime.now(),
    ),
    Duration(seconds: 5),
  );
}

enum FutureCallNames { birthdayReminder }
