import 'package:flutter/foundation.dart';
import 'package:daily_productivity_assistant_client/daily_productivity_assistant_client.dart';

export 'package:daily_productivity_assistant_client/daily_productivity_assistant_client.dart'
    show NextBestTaskResult;

late Client client;

void initServerpod() {
  // Use production API host in release; keep localhost for debug/dev.
  const localBaseUrl = 'http://localhost:8088';
  const prodBaseUrl = 'https://todoapp.api.serverpod.space';

  client = Client(kReleaseMode ? prodBaseUrl : localBaseUrl);
}
