import 'package:daily_productivity_assistant_client/daily_productivity_assistant_client.dart';

late Client client;

void initServerpod() {
  client = Client(
    'http://localhost:8082/',
  );
}
