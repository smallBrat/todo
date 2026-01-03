import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/web/widgets/built_with_serverpod_page.dart';

class RouteRoot extends Route {
  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    final html = BuiltWithServerpodPage().getHtml();

    return Response.ok(
      body: Body.fromString(
        html,
        mimeType: MimeType.html, // Use MimeType enum instead of string
      ),
    );
  }
}
