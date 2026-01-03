import 'package:serverpod/serverpod.dart';

/// A page widget that displays the Serverpod version and the current run mode.
class BuiltWithServerpodPage extends WebWidget {
  final DateTime servedAt = DateTime.now();
  final String runMode = Serverpod.instance.runMode.toString();

  BuiltWithServerpodPage();

  /// Returns the HTML content for this page.
  String getHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daily Productivity Assistant</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <div class="container">
    <h1>Daily Productivity Assistant</h1>
    <p>Powered by <strong>Serverpod 3.1.0</strong></p>
    <p>Served at: <code>$servedAt</code></p>
    <p>Run mode: <code>$runMode</code></p>
    <p><a href="/">Back to Home</a></p>
  </div>
</body>
</html>
''';
  }
}
